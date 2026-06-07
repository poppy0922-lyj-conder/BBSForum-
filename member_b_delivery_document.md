# 成员B功能交付文档

## 概述

本文档描述了成员B在BBS论坛系统中实现的用户系统功能，包括用户注册、登录、退出、个人资料管理、每日签到、积分奖励与积分记录查询功能。这些功能为整个系统提供用户身份认证、权限管控、积分体系的基础支撑。

## 功能模块

### 1. 用户注册 (Registration)

**功能描述**：
- 新用户可以注册成为BBS用户，填写用户名、密码、联系方式、工作性质、工作地点等信息
- 密码使用BCrypt算法加密存储，不存明文
- 注册成功后跳转登录页并显示成功提示
- 后端校验用户名唯一、两次密码一致、用户名3-50字符、密码至少6位
- 注册操作开启数据库事务，异常回滚

**相关文件**：
- `src/main/java/com/bbs/controller/UserServlet.java` - 后端控制器
- `src/main/webapp/user/register.jsp` - 注册页面外壳
- `src/main/webapp/user/register_content.jsp` - 注册内容页面
- `src/main/java/com/bbs/util/PasswordUtil.java` - 密码加密工具类

### 2. 用户登录 (Login)

**功能描述**：
- 用户使用用户名和密码登录系统
- 登录成功后session中保存用户完整信息（用户名、角色、联系方式、工作性质、工作地点、积分等）
- 支持BCrypt hash校验和旧明文密码兼容
- 旧明文密码首次登录后自动升级为BCrypt加密
- 登录成功后执行 `request.changeSessionId()` 防御Session Fixation攻击
- 每日首次登录自动奖励 +2 积分，同步写入 score_logs 流水表

**相关文件**：
- `src/main/java/com/bbs/controller/UserServlet.java` - 后端控制器
- `src/main/webapp/user/login.jsp` - 登录页面外壳
- `src/main/webapp/user/login_content.jsp` - 登录内容页面

### 3. 退出登录 (Logout)

**功能描述**：
- 用户可以安全退出系统
- 清除当前session会话
- 退出后重定向到首页

**相关文件**：
- `src/main/java/com/bbs/controller/UserServlet.java` - 后端控制器

### 4. 个人中心 (Profile)

**功能描述**：
- 登录后可查看个人资料信息
- 显示用户名、联系方式、工作性质、工作地点、注册时间
- 左侧边栏导航：个人中心标题、二级菜单（基本信息/发布帖子/我的悬赏/我的关注/我的点赞/我的收藏/积分记录）、底部辅助功能（编辑资料）、最近积分记录模块
- 右侧显示基本信息卡片和当前积分模块（蓝色钻石图标+大号积分数字+签到按钮）
- 基本信息页面底部有「退出登录」按钮
- 顶部导航栏右上角显示「首页」按钮（返回首页）
- 每次访问从数据库刷新数据保证信息最新
- 资料更新后显示"资料已更新"提示
- 签到按钮通过Fetch AJAX调用签到接口，根据返回结果弹窗提示
- 公共边栏组件 `profile_sidebar.jsp` 统一所有个人中心页面的左侧导航

**相关文件**：
- `src/main/java/com/bbs/controller/UserProfileServlet.java` - 后端控制器
- `src/main/webapp/user/profile.jsp` - 个人中心页面外壳
- `src/main/webapp/user/profile_content.jsp` - 个人中心内容页面
- `src/main/webapp/user/profile_sidebar.jsp` - 公共边栏组件

### 5. 资料编辑 (Profile Edit)

**功能描述**：
- 用户可以修改联系方式、工作性质、工作地点
- 支持可选修改密码（非空时才更新，长度至少6位）
- 密码修改同样使用BCrypt加密
- 所有用户输入做HTML转义，防范XSS攻击
- 使用数据库事务确保资料更新和密码更新的原子性
- 前端HTML5校验 + 后端参数双重校验

**相关文件**：
- `src/main/java/com/bbs/controller/UserProfileServlet.java` - 后端控制器
- `src/main/webapp/user/profile_edit.jsp` - 编辑页面外壳
- `src/main/webapp/user/profile_edit_content.jsp` - 编辑内容页面

### 6. 发布帖子 (My Posts)

**功能描述**：
- 展示当前登录用户自己发布的所有帖子
- 显示帖子标题、摘要、所属板块、浏览量、点赞数、收藏数、发布时间
- 支持置顶/精华标识显示
- 空状态时提示用户去发布帖子
- 数据实时同步，从 posts 表按 user_id 查询

**相关文件**：
- `src/main/java/com/bbs/controller/UserProfilePlaceholderServlet.java` - 后端控制器（/user/profile/posts路由）
- `src/main/webapp/user/my_posts.jsp` - 页面外壳
- `src/main/webapp/user/my_posts_content.jsp` - 内容页面

### 7. 我的悬赏 (My Demands)

**功能描述**：
- 展示当前登录用户自己发布的所有悬赏需求
- 显示悬赏标题、描述、积分、状态（进行中/已结束）、回复数、发布时间
- 空状态时提示用户去发布悬赏
- 数据实时同步，从 demands 表按 user_id 查询

**相关文件**：
- `src/main/java/com/bbs/controller/UserProfilePlaceholderServlet.java` - 后端控制器（/user/profile/demands路由）
- `src/main/webapp/user/my_demands.jsp` - 页面外壳
- `src/main/webapp/user/my_demands_content.jsp` - 内容页面

### 8. 我的点赞 (My Likes)

**功能描述**：
- 展示当前登录用户点赞过的所有帖子
- 显示帖子标题、摘要、作者、板块、浏览量、点赞数、点赞时间
- 空状态时提示用户去浏览帖子
- 数据实时同步，联表查询 post_likes + posts + users + categories

**相关文件**：
- `src/main/java/com/bbs/controller/UserProfilePlaceholderServlet.java` - 后端控制器（/user/profile/likes路由）
- `src/main/webapp/user/my_likes.jsp` - 页面外壳
- `src/main/webapp/user/my_likes_content.jsp` - 内容页面

### 9. 我的收藏 (My Favorites)

**功能描述**：
- 展示当前登录用户收藏过的所有帖子
- 显示帖子标题、摘要、作者、板块、浏览量、收藏数、收藏时间
- 空状态时提示用户去浏览帖子
- 数据实时同步，联表查询 post_favorites + posts + users + categories

**相关文件**：
- `src/main/java/com/bbs/controller/UserProfilePlaceholderServlet.java` - 后端控制器（/user/profile/favorites路由）
- `src/main/webapp/user/my_favorites.jsp` - 页面外壳
- `src/main/webapp/user/my_favorites_content.jsp` - 内容页面

### 10. 积分记录 (Score Log)

**功能描述**：
- 展示用户所有积分流水记录
- 支持分页（每页15条），显示当前总积分
- 与个人中心边栏"查看全部"联动
- 积分变动带正负号颜色区分（绿色正数/红色负数）

**相关文件**：
- `src/main/java/com/bbs/controller/UserProfileServlet.java` - 后端控制器（/user/score-log路由）
- `src/main/webapp/user/score_log.jsp` - 积分记录页面外壳
- `src/main/webapp/user/score_log_content.jsp` - 积分记录内容页面

### 7. 每日签到 (Daily Checkin)

**功能描述**：
- AJAX-GET 接口 `/user/checkin`
- 单日仅可签到1次
- 连续签到5~15分逐步递增（第1天5分，第2天6分...封顶15分），断签重置为5分
- 积分变动开启数据库事务，异常回滚
- 同步写入 score_logs 流水表（备注：每日签到奖励）
- 返回固定JSON格式：`{"ok":true,"score":本次积分,"consecutive":连续天数}` 或 `{"ok":false,"msg":"错误提示"}`
- 签到成功后更新session中的积分值

**相关文件**：
- `src/main/java/com/bbs/controller/UserServlet.java` - 签到接口
- `src/main/webapp/user/profile_content.jsp` - 签到按钮与AJAX调用

### 8. 登录积分奖励 (Daily Login Bonus)

**功能描述**：
- 每日首次登录自动奖励 +2 积分
- 通过检查 score_logs 表中当日是否已有"每日首次登录奖励"记录来判定
- 积分变动开启数据库事务，异常回滚
- 同步写入 score_logs 流水表（备注：每日首次登录奖励）

**相关文件**：
- `src/main/java/com/bbs/controller/UserServlet.java` - awardDailyLoginScore方法

### 9. Session鉴权拦截 (AuthFilter)

**功能描述**：
- 拦截未登录用户访问个人中心（`/user/profile`、`/user/profile/*`、`/user/score-log`），重定向到登录页
- 拦截未登录用户访问后台（`/admin`、`/admin/*`），重定向到登录页
- 已登录但非管理员用户访问后台返回403禁止访问

**相关文件**：
- `src/main/java/com/bbs/filter/AuthFilter.java` - 鉴权拦截器

## init.sql 修复记录

### 问题描述
执行 `init.sql` 时出现错误：`Duplicate entry 'admin' for key 'users.username'`

### 根因分析
1. **重复表定义**：`post_likes` 和 `post_favorites` 表被定义了两次（第158-179行和第182-203行），导致第二次执行时报表已存在的警告，且索引名冲突
2. **重复插入无防护**：`INSERT INTO users` 没有使用 `INSERT IGNORE`，当数据库已存在数据时重复执行会报错

### 修复措施
1. **删除重复的表定义**：移除第180-203行的重复 `post_likes` 和 `post_favorites` 定义
2. **使用 INSERT IGNORE**：将 `INSERT INTO users` 改为 `INSERT IGNORE INTO users`，重复执行时自动跳过已存在记录
3. **板块插入同样使用 INSERT IGNORE**：确保重复执行不会报错

### 修复后的 init.sql 验证
- 已重新执行SQL，数据库 `bbs_forum` 成功创建
- 所有11张表正常创建：users、categories、posts、replies、demands、demand_replies、score_logs、daily_checkins、post_likes、post_favorites、user_follows
- 默认账号 admin/test 成功插入
- 重复执行无报错

## API 端点说明

### 用户注册/登录 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/user/register` | GET | 显示注册页 | 无 | 注册表单 |
| `/user/register` | POST | 提交注册 | username, password, password2, phone, jobType, jobLocation | 重定向到登录页或返回注册页并显示错误 |
| `/user/login` | GET | 显示登录页 | 无 | 登录表单 |
| `/user/login` | POST | 提交登录 | username, password | 重定向首页并建立session或返回登录页并显示错误 |
| `/logout` | GET | 退出登录 | 无 | 清除session并重定向首页 |
| `/user/checkin` | GET | 每日签到 | 无（需登录） | JSON: {"ok":true,"score":n,"consecutive":n} |

### 个人中心 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/user/profile` | GET | 查看个人资料 | 无（需登录） | 个人资料页面 |
| `/user/profile/edit` | GET | 显示编辑表单 | 无（需登录） | 编辑表单（回显当前资料） |
| `/user/profile/edit` | POST | 保存修改 | phone, jobType, jobLocation, password(可选), password2 | 重定向到个人中心或返回编辑页并显示错误 |
| `/user/score-log` | GET | 积分记录查询 | page(可选) | 积分记录页面（分页） |
| `/user/profile/follows` | GET | 我的关注 | 无（需登录） | 关注列表页面 |
| `/user/profile/posts` | GET | 发布帖子 | 无（需登录） | 我的帖子列表页面 |
| `/user/profile/demands` | GET | 我的悬赏 | 无（需登录） | 我的悬赏列表页面 |
| `/user/profile/likes` | GET | 我的点赞 | 无（需登录） | 点赞帖子列表页面 |
| `/user/profile/favorites` | GET | 我的收藏 | 无（需登录） | 收藏帖子列表页面 |

### 鉴权拦截规则（AuthFilter）

| URL Pattern | 条件 | 响应 |
|-------------|------|------|
| `/user/profile`, `/user/profile/*`, `/user/score-log` | 未登录（session无user） | 重定向 `/user/login` |
| `/admin`, `/admin/*` | 未登录 | 重定向 `/user/login` |
| `/admin`, `/admin/*` | 已登录但非管理员 | HTTP 403 |

## 数据库表结构

### users 表

```sql
CREATE TABLE IF NOT EXISTS users (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '用户名',
    password    VARCHAR(255) NOT NULL COMMENT '加密密码',
    phone       VARCHAR(20)  DEFAULT '' COMMENT '联系方式',
    job_type    VARCHAR(50)  DEFAULT '' COMMENT '工作性质',
    job_location VARCHAR(100) DEFAULT '' COMMENT '工作地点',
    role        ENUM('user','admin') NOT NULL DEFAULT 'user' COMMENT '角色',
    score       INT NOT NULL DEFAULT 0 COMMENT '积分',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

### daily_checkins 表

```sql
CREATE TABLE IF NOT EXISTS daily_checkins (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    user_id           INT NOT NULL,
    checkin_date      DATE NOT NULL,
    consecutive_days  INT NOT NULL DEFAULT 1,
    score_earned      INT NOT NULL DEFAULT 5,
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uk_user_date (user_id, checkin_date)
);
```

### score_logs 表

```sql
CREATE TABLE IF NOT EXISTS score_logs (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL,
    score       INT NOT NULL,
    reason      VARCHAR(100) DEFAULT '',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## 安全规范执行情况

### 1. SQL注入防护
- 所有数据库操作均使用 `PreparedStatement`，禁止SQL字符串拼接
- 用户输入的参数通过 `?` 占位符绑定

### 2. XSS攻击防护
- 所有用户输入做HTML转义（`escapeHtml`方法）
- JSP页面使用 `${}` EL表达式自动转义
- 资料编辑页面对 phone、jobType、jobLocation 字段做XSS过滤

### 3. 密码安全
- 新注册/改密使用 jBCrypt 加密存储（`PasswordUtil.hash()`）
- 系统默认明文测试账号（admin/test）首次登录自动升级为BCrypt密文
- 兼容明文/密文双重校验（`PasswordUtil.verifyAndUpgradeIfLegacy()`）

### 4. Session安全
- 登录成功后执行 `request.changeSessionId()` 防御Session Fixation攻击
- 退出时调用 `session.invalidate()` 完全清除会话

### 5. 事务安全
- 注册、资料编辑、密码修改、积分变更、签到等所有多表操作均开启数据库事务
- 异常时执行 `rollback()` 回滚

### 6. 权限控制
- AuthFilter统一拦截受保护路径
- 未登录用户访问个人中心相关路径重定向到登录页
- 普通用户访问/admin路径返回403

## 前端集成说明

### 1. 页面结构
所有用户相关页面采用「外壳页+内容页」拆分模式：
- 外壳页（`.jsp`）：设置 `pageTitle` 和 `contentPage`，引入 `layouts/main.jsp`
- 内容页（`_content.jsp`）：实际页面内容

### 2. 样式规范
- 仅使用 Tailwind CSS CDN + Font Awesome 图标
- 不新增自定义CSS（除main.jsp中统一弹窗样式外）
- 个人中心页面采用左右分栏布局，左侧边栏固定宽度60px，右侧内容自适应

### 3. 弹窗规范
- 禁用原生 alert/confirm
- 使用项目统一自定义模态框（main.jsp中定义）
- 签到结果通过 `alert()` 弹窗提示（已重写为Promise-based模态框）

### 4. 状态提示
- 通过URL参数传递状态：`registered=1`（注册成功）、`updated=1`（资料更新成功）、`success=1`（通用成功）、`error=xxx`（错误）
- 页面根据参数展示对应提示

### 5. 表单校验
- 前端HTML5校验（required、minlength、maxlength）
- 后端参数双重校验（用户名长度、密码长度、两次密码一致等）

## 配置说明

### 数据库配置
项目使用 `src/main/resources/config.properties` 配置数据库连接：

```properties
db.url=jdbc:mysql://localhost:3306/bbs_forum?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf8
db.user=root
db.password=
```

**注意**：请根据实际MySQL配置修改密码。若密码非空，需修改此配置文件。

## 测试建议

### 1. 注册测试
- 测试正常注册
- 测试重复用户名注册
- 测试两次密码不一致
- 测试空用户名或密码
- 测试用户名长度不足3位
- 测试密码长度不足6位

### 2. 登录测试
- 测试新注册用户登录
- 测试默认账号登录（admin/admin123, test/test123）
- 测试错误密码
- 测试退出后重新登录
- 验证每日首次登录+2积分

### 3. 个人中心测试
- 测试未登录访问被拦截
- 测试登录后正常查看信息
- 测试编辑资料后返回刷新
- 测试左侧边栏导航高亮
- 测试最近积分记录显示

### 4. 资料编辑测试
- 测试修改联系方式、工作性质、工作地点
- 测试修改密码后重新登录
- 测试两次新密码不一致
- 测试新密码长度不足6位
- 测试XSS输入过滤

### 5. 鉴权拦截测试
- 测试普通用户访问后台返回403
- 测试管理员访问后台正常
- 测试退出后访问个人中心被重定向
- 测试未登录访问 /user/score-log 被重定向

### 6. 签到测试
- 测试正常签到获得积分
- 测试连续签到积分递增
- 测试断签后重置为5分
- 测试今日已签到不能重复签到
- 验证积分流水同步写入

### 7. 积分记录测试
- 测试分页功能
- 测试积分变动正负号显示
- 测试与个人中心"查看全部"联动

### 8. init.sql 重复执行测试
- 测试首次执行成功
- 测试重复执行不报错（INSERT IGNORE）
- 验证所有表和初始数据正确

### 9. 首页侧边栏测试
- 验证板块列表无重复显示
- 验证各板块数据正常（名称、描述）
- 验证从首页切换到板块页面侧边栏保持一致

### 10. 发布帖子/我的悬赏/我的点赞/我的收藏测试
- 使用 test/admin 账号登录
- 发帖/点赞/收藏/发布悬赏后进入对应菜单查看
- 验证数据实时同步、正常展示
- 验证无404、无空白页面
- 验证空状态提示正确

## 依赖关系

### 对其他成员的影响

1. **对组长 (Team Leader)**：
   - 需要确保`users`表已创建
   - 需要保证导航栏和侧边栏可以访问`sessionScope.user`（如"管理"入口需要user.role判断）
   - 发帖和回帖功能依赖`sessionScope.user`判断登录态

2. **对成员A (Member A)**：
   - 帖子置顶和加精功能仅管理员可操作，可通过`sessionScope.user.role == 'admin'`判断
   - 搜索功能不受影响

3. **对成员C (Member C)**：
   - 板块管理功能（`/admin/*`）受AuthFilter统一鉴权保护
   - 不需要自行实现管理员权限校验

4. **对成员D (Member D)**：
   - 需求悬赏发布/采纳需要登录态，可通过`sessionScope.user`判断
   - 积分流水关联`user_id`字段，使用users表
   - daily_checkins 表由本模块操作，score_logs 表由本模块写入

## 本次修改记录

### 1. 个人中心4个菜单功能实现
- **发布帖子** (`/user/profile/posts`)：从 posts 表按 user_id 查询当前用户发布的所有帖子
- **我的悬赏** (`/user/profile/demands`)：从 demands 表按 user_id 查询当前用户发布的所有悬赏
- **我的点赞** (`/user/profile/likes`)：联表查询 post_likes + posts + users + categories
- **我的收藏** (`/user/profile/favorites`)：联表查询 post_favorites + posts + users + categories
- **数据同步**：所有查询均实时从数据库读取，确保数据同步
- **新增文件**：
  - `src/main/java/com/bbs/controller/UserProfilePlaceholderServlet.java`（重写为真实数据查询）
  - `src/main/webapp/user/profile_sidebar.jsp`（公共边栏组件）
  - `src/main/webapp/user/my_posts.jsp` + `my_posts_content.jsp`
  - `src/main/webapp/user/my_demands.jsp` + `my_demands_content.jsp`
  - `src/main/webapp/user/my_likes.jsp` + `my_likes_content.jsp`
  - `src/main/webapp/user/my_favorites.jsp` + `my_favorites_content.jsp`
- **删除文件**：占位页面 `profile_placeholder.jsp` + `profile_placeholder_content.jsp`

### 2. 个人中心UI优化
- 边栏底部仅保留「编辑资料」按钮
- 顶部导航栏右上角「退出」改为「首页」（带 home 图标，返回首页）
- 基本信息页面底部增加「退出登录」按钮（红色样式，带 sign-out 图标）
- 所有个人中心页面统一使用 `profile_sidebar.jsp` 公共边栏组件
- 边栏高亮状态通过 `activeMenu` 变量控制

## 注意事项

1. **密码安全**：新注册和改密均使用BCrypt加密（`org.mindrot:jbcrypt:0.4`）。`init.sql`中默认测试账号的密码为明文，首次登录时自动升级为BCrypt hash。
2. **Session结构**：登录后session中存储的user为`Map<String, Object>`格式，包含id、username、role、phone、jobType、jobLocation、score、createdAt等字段。其他模块均依赖此结构，修改时务必保证兼容。
3. **AuthFilter覆盖范围**：Filter保护`/user/profile*`、`/user/score-log`和`/admin/*`路径。发帖、回帖等功能的登录判断仍由各自Servlet自行处理。
4. **编码**：通过`EncodingFilter`统一处理UTF-8编码，后端和JSP页面均使用UTF-8。
5. **积分规则**：每日首次登录+2分，每日签到5~15分逐步递增（封顶15分），断签重置为5分。所有积分变动均写入score_logs流水表。
6. **init.sql 修复**：已修复重复表定义和重复插入问题，使用 `INSERT IGNORE` 和 `CREATE TABLE IF NOT EXISTS` 确保重复执行无报错。
7. **公共边栏组件**：`profile_sidebar.jsp` 统一了所有个人中心页面的左侧导航，通过设置 `activeMenu` request属性控制高亮。
