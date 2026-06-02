# BBS论坛系统-用户系统（B板块）实施计划

## Summary（摘要）
本计划面向当前仓库 `BBSForum`（Jakarta Servlet 5.0 + JSP + MySQL），补全“组员B：用户系统”所需的后端与鉴权能力：注册、登录、退出、个人中心查询、资料更新（可选修改密码）、Session 鉴权 Filter（保护 `/user/profile*` 与 `/admin/*`），并将密码存储升级为 BCrypt（兼容历史明文）。

---

## Current State Analysis（现状分析）

### 1) 技术栈与结构（从代码库读取）
- 后端：Jakarta Servlet 5.0 + JSP + JSTL（见 `README.md`、`pom.xml`）。
- 数据库：MySQL（`database/init.sql`、`DBUtil.java`）。
- 已存在的用户相关页面（JSP）：
  - `/user/login.jsp`、`/user/register.jsp`
  - `/user/profile.jsp`、`/user/profile_edit.jsp`（页面已存在，但缺少后端路由与数据加载/更新支持）
- 已存在的用户控制器：
  - `src/main/java/com/bbs/controller/UserServlet.java`：仅处理 `/user/login`、`/user/register`、`/logout`，且登录使用 **SQL 明文密码比对**。
- 现有项目对 Session 的约定：
  - 登录后在 `sessionScope.user` 存放用户信息（`Map<String,Object>`），其他模块（如 `PostServlet`）以此判断是否登录。
- 缺失项：
  - `/user/profile` 与 `/user/profile/edit` 的 Servlet 路由与业务逻辑
  - Session 鉴权 Filter（尤其是 `/admin/*` 的权限拦截）
  - 密码加密存储（需求中要求“加密密码”）

### 2) 外部参考（用于落地方案的依据）
- jBCrypt Maven 依赖坐标（用于在本项目引入 BCrypt）：Sonatype Maven Central 提供 `<groupId>org.mindrot</groupId><artifactId>jbcrypt</artifactId><version>0.4</version>` 片段。  
- BCrypt 使用方式（hashpw / checkpw / gensalt）：mindrot 的 jBCrypt 文档给出示例：`BCrypt.hashpw(plain, BCrypt.gensalt())` 与 `BCrypt.checkpw(candidate, stored_hash)`。
- Servlet Filter 的用途：可用于对请求做登录态/权限预处理与统一拦截（DigitalOcean Servlet Filter 教程说明了 Filter 可用于认证与授权，并可通过 `web.xml` 或注解配置）。

---

## Assumptions & Decisions（假设与决策）

1. **不更改现有“sessionScope.user 是 Map”这一约定**，避免影响已实现的发帖、回帖等模块；只补齐字段与刷新机制。
2. **密码加密采用 BCrypt（jBCrypt）**：
   - 新注册/修改密码：写入 BCrypt Hash；
   - 登录时：优先按 BCrypt 验证；若库中仍是旧明文，则走明文比对并支持“自动升级为 BCrypt”（减少对历史库依赖）。
3. `/user/profile*` 在 Servlet/Filter URL pattern 中用两条规则等价覆盖：`/user/profile` 与 `/user/profile/*`（Servlet 规范不支持 `/user/profile*` 这种写法）。
4. 管理员权限以 `sessionScope.user.role == "admin"` 判断；未满足权限时返回 403 或重定向回首页（二选一，执行期固定为一种策略）。

---

## Proposed Changes（改动方案：文件级别可执行说明）

> 下述每项都包含：改动文件、做什么、为什么、怎么做（关键逻辑/接口）。

### A. `pom.xml`：引入 BCrypt 依赖
- **文件**：`pom.xml`
- **做什么**：新增 `org.mindrot:jbcrypt:0.4` 依赖。
- **为什么**：满足“加密密码”要求，并提供 `BCrypt.hashpw/checkpw/gensalt`。
- **怎么做**：
  - 在 `<dependencies>` 中追加：
    ```xml
    <dependency>
      <groupId>org.mindrot</groupId>
      <artifactId>jbcrypt</artifactId>
      <version>0.4</version>
    </dependency>
    ```

### B. 新增密码工具类：封装 BCrypt + 旧明文兼容
- **文件（新增）**：`src/main/java/com/bbs/util/PasswordUtil.java`
- **做什么**：提供统一的 hash/verify/legacy-upgrade 方法。
- **为什么**：避免在多个 Servlet 中复制 BCrypt 与兼容逻辑，便于维护。
- **怎么做（建议接口）**：
  - `static boolean isBcrypt(String stored)`
  - `static String hash(String plain)`（可固定 `gensalt(10)` 或可配置 rounds）
  - `static boolean verify(String plain, String stored)`
  - `static boolean verifyAndUpgradeIfLegacy(Connection conn, int userId, String plain, String stored)`：
    - 若 `stored` 非 bcrypt 且明文匹配成功：`UPDATE users SET password=? WHERE id=?`

### C. 改造登录/注册/退出：升级 UserServlet
- **文件（改动）**：`src/main/java/com/bbs/controller/UserServlet.java`
- **做什么**：
  1) 登录：改为 **按 username 查用户（含 password）**，在 Java 里用 BCrypt/兼容校验；  
  2) 注册：写入 BCrypt hash；  
  3) 登录成功：`request.changeSessionId()`，并在 session 中保存必要字段；  
  4) 注册失败：用户名重复等错误提示保持。
- **为什么**：
  - 不能在 SQL 里做明文比对；
  - BCrypt 的校验应在应用层完成；
  - `changeSessionId` 可缓解 session fixation。
- **怎么做（关键 SQL 与 session 字段）**：
  - 登录查询：
    ```sql
    SELECT id, username, password, role, phone, job_type, job_location, created_at
    FROM users WHERE username = ?
    ```
  - session `user`（Map）建议字段：
    - `id`、`username`、`role`
    - `phone`、`jobType`、`jobLocation`
    - `createdAt`

### D. 新增个人中心/资料编辑：UserProfileServlet
- **文件（新增）**：`src/main/java/com/bbs/controller/UserProfileServlet.java`
- **做什么**：提供 `/user/profile` 与 `/user/profile/edit` 的 GET/POST 处理。
- **为什么**：仓库已有对应 JSP 页面与导航入口，但缺后端支撑。
- **怎么做（路由与行为）**：
  - `@WebServlet(urlPatterns={"/user/profile", "/user/profile/edit"})`
  - `GET /user/profile`：
    - 必须登录（也可交给 Filter 统一处理）
    - 从 session 取 userId → 查询 DB → `request.setAttribute("user", userMap)` → forward `/user/profile.jsp`
  - `GET /user/profile/edit`：
    - 查询 DB 并 forward `/user/profile_edit.jsp`（确保表单回显）
  - `POST /user/profile/edit`：
    - 更新 `phone/job_type/job_location`
    - 若 `password` 非空：校验（可选：二次确认）并写入 BCrypt hash
    - 更新成功后：刷新 sessionScope.user（至少 phone/jobType/jobLocation），并 redirect `/user/profile?updated=1`

### E. 新增鉴权 Filter：统一保护个人中心与后台
- **文件（新增）**：`src/main/java/com/bbs/filter/AuthFilter.java`
- **做什么**：拦截未登录访问 `/user/profile*`，拦截非 admin 访问 `/admin*`。
- **为什么**：
  - 目前 `AdminCategoryServlet` 等后台入口没有任何权限控制；
  - 在每个 Servlet 中重复校验会造成维护成本与遗漏风险。
- **怎么做（过滤规则与判定）**：
  - `@WebFilter(urlPatterns={"/user/profile","/user/profile/*","/admin","/admin/*"})`
  - 判断逻辑：
    - `session = request.getSession(false)` 且 `session.getAttribute("user") != null` 才算已登录
    - 对 `/admin` 与 `/admin/*`：额外校验 `((Map)user).get("role").equals("admin")`
  - 未登录：redirect 到 `/user/login`
  - 非管理员：`sendError(403)`（或 redirect `/`，执行期选其一并保持一致）

### F. （可选）JSP 小改动：更友好的提示
- **文件（可选改动）**：
  - `src/main/webapp/user/login_content.jsp`：支持 `registered=1`、`updated=1` 的成功提示
  - `src/main/webapp/user/profile_edit_content.jsp`：增加确认新密码 `password2`（避免误改）
- **为什么**：提升可用性与答辩演示效果。
- **怎么做**：保持 Tailwind 风格提示条，与现有 error 区块一致。

### G. `database/init.sql`：默认账号与“加密密码”策略对齐
- **文件（改动）**：`database/init.sql`
- **做什么（两种策略，执行期必须二选一）**：
  1) **推荐：保留默认账号明文**（便于同学本地快速初始化），由代码在首次登录成功后自动升级为 BCrypt；  
  2) 直接将默认账号写为 BCrypt hash（更“纯粹”，但需要预先生成 hash 并写死在 SQL）。
- **为什么**：既满足“加密密码”要求，又降低联调时的环境摩擦。
- **怎么做**：
  - 在 `users` 默认数据处增加注释，说明是否启用“旧明文自动升级”。

---

## Verification（验证步骤：可复现、可打勾）

### 1) 构建与启动
1. 执行 `database/init.sql` 初始化数据库（确保 MySQL 8.0+）。
2. 修改 `src/main/java/com/bbs/util/DBUtil.java` 中数据库密码。
3. 运行（Windows）：`.\mvnw.cmd clean compile`
4. IDE 运行 `src/main/java/com/bbs/Main.java`，打开控制台输出的本地地址（默认 README 为 `http://localhost:8088/BBSForum/`）。

### 2) 功能验收用例（浏览器）
1. 注册：`/user/register` → 成功后跳转登录页 → 数据库 `users.password` 应为 `$2...` 开头（BCrypt）。
2. 登录：`/user/login` → 成功后导航栏显示用户信息。
3. 个人中心拦截：
   - 未登录访问 `/user/profile` 应跳转到 `/user/login`（Filter 生效）。
4. 编辑资料：
   - 登录后访问 `/user/profile/edit` 修改联系方式/工作信息 → 回到 `/user/profile` 展示最新信息（session 刷新生效）。
   - 若填写新密码 → 退出后用新密码登录成功。
5. 后台拦截：
   - 普通用户访问 `/admin` 或 `/admin/categories` 应被拒绝（403 或重定向）。
   - admin 账号访问应可进入。
6. 旧明文兼容（若选择“自动升级”策略）：
   - 使用 init.sql 默认用户首次登录成功；
   - 登录成功后数据库中该用户 `password` 被升级为 BCrypt（再次登录仍可成功）。

---

## Notes（执行注意事项）
1. `EncodingFilter` 当前会将响应默认设为 `text/html;charset=UTF-8`；若 User 模块后续增加 JSON 接口，需在 Servlet 内显式覆盖 content-type。
2. 目前后台相关 Servlet 没有权限判断，Filter 是必须项，否则存在越权。

