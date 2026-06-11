# BBS论坛系统 — BBS技术社区

基于 Jakarta Servlet 5.0 + JSP + MySQL 的 BBS 技术社区，五人团队协作课程设计项目。

---

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|:----:|
| 后端 | Jakarta Servlet + JSP + JSTL | 5.0 |
| 数据库 | MySQL + JDBC | 8.0+ |
| 前端 | Tailwind CSS (CDN) + Font Awesome | 4.7.0 |
| 图表 | Chart.js (CDN) | 4.x |
| 构建 | Maven（WAR + 可执行 JAR） | 3.6+ |
| 服务器 | 嵌入式 Apache Tomcat (embed-core) | 10.1.52 |
| JDK | Java 11+（推荐 Java 21） | |
| 密码加密 | jBCrypt | 0.4 |
| JSON 处理 | Gson | 2.10.1 |
| AI 接口 | 硅基流动 API (SiliconFlow) | Qwen2.5-7B-Instruct |

## 项目结构

```
BBSForum/
├── pom.xml
├── README.md
├── database/
│   └── init.sql                        # 完整建库建表脚本（含迁移补丁）
├── deploy/
│   ├── BBSForum-exec.jar               # 可执行胖 JAR（约 32MB）
│   └── webapp/                         # 生产环境 JSP 资源目录
├── src/
│   ├── main/
│   │   ├── java/com/bbs/
│   │   │   ├── Main.java               # 唯一启动入口（嵌入式 Tomcat）
│   │   │   ├── controller/             # 17 个 Servlet
│   │   │   │   ├── HomeServlet.java            # 首页帖子列表
│   │   │   │   ├── PostServlet.java            # 帖子 CRUD / 回复 / AI 总结 / 搜索 / 草稿
│   │   │   │   ├── InteractionServlet.java     # 关注 / 点赞 / 收藏
│   │   │   │   ├── HotServlet.java             # 热度榜
│   │   │   │   ├── CoverServlet.java           # SVG 封面图生成
│   │   │   │   ├── CategoryServlet.java        # 按板块过滤帖子
│   │   │   │   ├── UserServlet.java            # 注册 / 登录 / 登出 / 签到
│   │   │   │   ├── UserProfileServlet.java     # 个人中心 / 资料编辑 / 积分记录
│   │   │   │   ├── UserProfilePlaceholderServlet.java  # 我的帖子 / 需求 / 点赞 / 收藏
│   │   │   │   ├── DemandServlet.java          # 需求 CRUD / 回复 / 采纳
│   │   │   │   ├── ScoreServlet.java           # 积分排行榜 / 流水
│   │   │   │   ├── ReportServlet.java          # 用户举报 / 后台处理
│   │   │   │   ├── NotificationServlet.java    # 通知列表 / 详情 / 标记已读
│   │   │   │   ├── AdminCategoryServlet.java   # 后台板块管理
│   │   │   │   ├── AdminPostServlet.java       # 后台帖子管理（置顶 / 加精 / 删除）
│   │   │   │   ├── AdminUserServlet.java       # 后台用户管理
│   │   │   │   └── AdminDashboardServlet.java  # 后台图表数据（JSON）
│   │   │   ├── filter/
│   │   │   │   ├── AuthFilter.java        # Session 鉴权（登录拦截 + 后台角色校验）
│   │   │   │   ├── EncodingFilter.java    # 全局 UTF-8 编码
│   │   │   │   └── StatsFilter.java       # 实时数据缓存 + /api/stats JSON 接口
│   │   │   └── util/
│   │   │       ├── DBUtil.java            # 数据库连接（从 config.properties 读取）
│   │   │       ├── PasswordUtil.java      # BCrypt 密码加密 + 旧明文自动升级
│   │   │       ├── AiUtil.java            # AI 总结 API 调用（硅基流动）
│   │   │       ├── ContentUtil.java       # Markdown 渲染 / XSS 转义 / 摘要提取
│   │   │       └── PostMapper.java        # 帖子 ResultSet → Map 映射工具
│   │   ├── resources/
│   │   │   ├── config.properties          # 敏感配置（已 .gitignore）
│   │   │   └── config.properties.template # 配置模板
│   │   └── webapp/
│   │       ├── index.jsp                  # 首页入口
│   │       ├── admin/                     # 管理后台页面
│   │       ├── category/                  # 板块页面
│   │       ├── demand/                    # 需求页面
│   │       ├── error/                     # 404/500 错误页面
│   │       ├── layouts/main.jsp           # 全局布局模板（导航 + 侧栏 + 右侧面板）
│   │       ├── notification/              # 通知页面
│   │       ├── post/                      # 帖子页面
│   │       ├── score/                     # 积分页面
│   │       ├── user/                      # 用户页面
│   │       └── WEB-INF/                   # 受保护模板
│   └── test/
└── openapi.yaml                  # OpenAPI 接口文档
```

## 快速开始

### 1. 初始化数据库

```bash
mysql -u root -p < database/init.sql
```

创建 `bbs_forum` 数据库，包含 13 张表、4 个板块、默认测试账号、8 条示例帖子。

### 2. 配置连接信息

编辑 `src/main/resources/config.properties`（从 template 复制）：

```properties
db.url=jdbc:mysql://localhost:3306/bbs_forum?useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
db.user=root
db.password=你的密码
ai.api.key=你的硅基流动API密钥（可选）
```

> 不配置 AI API Key 也能正常使用，只是 AI 总结功能不可用。

### 3. 编译运行

**开发模式（IDE）：**

```bash
mvn clean compile
```

在 IDE 中运行 `src/main/java/com/bbs/Main.java`，控制台输出：

```
==========================================
  BBS技术社区 启动成功！
  http://localhost:80/BBSForum/
==========================================
```

**生产部署（服务器）：**

```bash
# 构建
mvn clean package -DskipTests

# 上传到服务器
scp target/BBSForum-exec.jar root@服务器IP:/root/bbs/
scp -r deploy/webapp root@服务器IP:/root/bbs/

# 服务器上解压类文件
cd /root/bbs && unzip -o BBSForum-exec.jar "WEB-INF/classes/**/*" -d webapp/

# 启动
cd /root/bbs && nohup java -cp BBSForum-exec.jar:webapp/WEB-INF/classes com.bbs.Main > bbs.log 2>&1 &
```

### 4. 访问

浏览器打开 `http://localhost:80/BBSForum/`

| 账号 | 密码 | 角色 |
|------|------|------|
| admin | admin123 | 管理员 |
| test | test123 | 普通用户 |

## 功能清单

### 核心功能（已完成 ✓）

| 序号 | 功能 | 说明 |
|:----:|------|------|
| 1 | 发布帖子 | Markdown 编辑器 + 封面图上传 + 关键词标签 |
| 2 | 回复帖子 | 嵌套回复任意深度 + 回复后自动定位锚点 + 高亮提示 |
| 3 | 板块分类 | 板块 CRUD 管理 + 侧边栏导航 |
| 4 | 置顶/加精 | 三级置顶循环（0→1→2→0）+ 加精开关 |
| 5 | 用户系统 | 注册/登录/个人中心/资料编辑/头像上传 |
| 6 | 需求悬赏 | 发布/编辑/回复/采纳 + 积分转账（FOR UPDATE 行锁） |
| 7 | 积分系统 | 发帖+10 / 回复+2 / 被回复+3 / 被点赞+5 / 签到+5~15 / 登录+2 |
| 8 | 通知系统 | 回复/点赞/收藏/举报结果/采纳五种通知类型 + 详情页 |
| 9 | 右侧数据面板 | 实时统计列表式进度条 + 热门标签词云 |
| 10 | 帖子草稿箱 | 保存草稿/草稿列表/继续编辑发布 |
| 11 | 嵌套回复 | 回复内回复/缩进显示/@引用通知 |
| 12 | 通知跳转 | 点击通知直接跳转对应帖子 |
| 13 | 举报系统 | 用户提交举报 + 管理员预览/处理（软删除+通知） |
| 14 | 管理员后台 | 统计看板 + 帖子管理 + 用户管理 + 板块管理 + 举报处理 |
| 15 | 管理员仪表盘 | Chart.js 图表：各板块帖子统计 / 每日发帖量 / 用户增长 |
| 16 | 用户管理 | 角色切换（user/admin）+ 级联删除 |

### 创新功能（已完成 ✓）

| 难度 | 创新点 | 说明 |
|:----:|--------|------|
| 低 | 帖子搜索 | SQL LIKE 模糊匹配 + 分页 |
| 低 | 回帖不刷新 | AJAX 异步提交 |
| 低 | 点赞功能 | 实时计数 + 作者 +3 积分 |
| 中 | 收藏帖子 | 书签按钮 + 计数实时更新 |
| 中 | 关注用户 | 关注列表管理 + 取消关注 |
| 中 | 热门排行 | 按浏览量排序 + 金银铜标记 |
| 中 | AI 智能总结 | 调用大模型生成内容摘要 |
| 中 | 实时数据面板 | 帖子/评论/用户/需求统计 |
| 中 | 热门关键词 | 关键词聚合 + 点击搜索 |
| 高 | 图片上传 | 封面图 + 内联图片 + UUID 重命名 |
| 中 | 积分排行 | TOP100 + 当前用户高亮 |
| 高 | 通知提示 | 操作成功/失败浮层 + URL 参数 |
| 中 | 封面图自动生成 | 无封面帖子自动生成 SVG |
| 中 | 统一弹窗系统 | 自定义模态框替换原生 alert/confirm |
| 中 | 需求独立回复 | demand_replies 表与帖子回复分离 |
| 中 | 每日签到 | 连续签到递增奖励封顶 +15 |
| 中 | 事务保护 | 积分操作使用行锁（FOR UPDATE） |
| 中 | 通知系统 | 回复/点赞/收藏/举报结果五种通知类型 |
| 低 | 回复锚点定位 | 回复后自动滚动到该回复并高亮闪烁 |
| 高 | 三主题切换 | 默认/科技霓虹/手绘涂鸦，防闪白技术 |
| 中 | 主题风格联动 | 实时数据/排行榜/头像全组件主题统一 |

## 页面路由

| URL | 页面 | 负责人 |
|-----|------|--------|
| `/` `/index` `/home` | 首页（帖子列表+板块导航） | 组长 |
| `/post/detail?id=` | 帖子详情+回复+互动 | 组长 |
| `/post/create` | 发布帖子 | 组长 |
| `/post/edit?id=` | 编辑帖子 | 组员C |
| `/post/drafts` | 草稿箱 | 组长 |
| `/post/search?keyword=` | 帖子搜索 | 组员A |
| `/cover/{id}?title=` | SVG 封面图生成 | 组长 |
| `/category?id=` | 板块帖子列表 | 组员C |
| `/hot` | 热度榜 | 组长 |
| `/user/login` | 登录 | 组员B |
| `/user/register` | 注册 | 组员B |
| `/user/checkin` | 每日签到 | 组员B |
| `/user/profile` | 个人中心 | 组员B |
| `/user/profile/edit` | 编辑资料 | 组员B |
| `/user/profile/posts` | 我的帖子 | 组员B |
| `/user/profile/demands` | 我的需求 | 组员B |
| `/user/profile/likes` | 我的点赞 | 组员B |
| `/user/profile/favorites` | 我的收藏 | 组员B |
| `/user/profile/follows` | 关注列表 | 组长 |
| `/user/score-log` | 我的积分记录 | 组员B |
| `/interact/follow` | 关注/取消（AJAX） | 组长 |
| `/interact/like` | 点赞/取消（AJAX） | 组长 |
| `/interact/favorite` | 收藏/取消（AJAX） | 组长 |
| `/demand` | 需求列表 | 组员D |
| `/demand/detail?id=` | 需求详情+回复 | 组员D |
| `/demand/create` | 发布需求 | 组员D |
| `/demand/update?id=` | 编辑需求 | 组员D |
| `/score/rank` | 积分排行榜 | 组员D |
| `/score/record` | 积分流水 | 组员D |
| `/report/submit` | 提交举报 | 组员A |
| `/notification/list` | 通知列表 | 组员A+组长 |
| `/notification/detail?id=` | 通知详情 | 组员A |
| `/admin` | 管理员后台首页（含统计看板图表） | 组员C |
| `/admin/categories` | 板块管理 | 组员C |
| `/admin/post/manage` | 帖子管理（置顶/加精/搜索/删除） | 组员A |
| `/admin/users` | 用户管理 | 组员C |
| `/admin/report/list` | 举报列表 | 组员A |
| `/admin/report/handle` | 处理举报 | 组员A |
| `/api/stats` | 实时统计 JSON 接口 | 组长 |
| `/logout` | 退出登录 | 组员B |

## 模块分工

| 成员 | 模块 | 工作量 | 数据库 | 后端接口 | 前端页面 |
|------|------|:------:|:------:|:--------:|:--------:|
| **组长** | 帖子核心+公共架构+互动+创新+草稿箱+嵌套回复+通知跳转+主题切换+面板 | **25%** | 5 张 | 14 个 | 8 个 |
| **组员A** | 置顶/加精/搜索/热度榜/举报/软删除/通知/热门标签/首页列表 | **20%** | 3 张 | 8 个 | 7 个 |
| **组员B** | 用户系统+签到+头像+个人中心扩展+鉴权拦截 | **19%** | 3 张 | 10 个 | 10 个 |
| **组员C** | 板块管理+分板块展示+帖子编辑+用户管理+后台 UI+仪表盘图表 | **19%** | 2 张 | 10 个 | 8 个 |
| **组员D** | 需求悬赏+积分流转+排行榜 | **17%** | 3 张 | 6 个 | 5 个 |

## 数据库表

| 表名 | 说明 | 负责人 |
|------|------|--------|
| users | 用户表（用户名/密码/角色/积分） | 组员B |
| categories | 板块表（名称/描述/排序） | 组员C |
| posts | 帖子表（标题/内容/封面/置顶/加精/关键词/草稿） | 组长+组员A |
| replies | 回复表（内容/所属帖子/嵌套回复/parent_id） | 组长 |
| demands | 需求表（标题/内容/悬赏积分/状态/最佳回复） | 组员D |
| demand_replies | 需求回复表（独立于帖子回复） | 组员D |
| score_logs | 积分流水表（积分变动/原因/时间） | 组员D |
| daily_checkins | 签到表（用户/日期/连续天数/获得积分） | 组员B |
| post_likes | 点赞表（用户/帖子/时间） | 组长 |
| post_favorites | 收藏表（用户/帖子/时间） | 组长 |
| user_follows | 关注表（关注者/被关注者/时间） | 组长 |
| reports | 举报记录表（举报人/目标类型/原因/处理状态） | 组员A |
| notifications | 通知表（类型/内容/target_url/已读状态） | 组员A+组长 |

## 文档索引

| 文档 | 说明 |
|------|------|
| `整体需求分析.md` | 22 项功能需求 + 非功能需求 + 用例分析 |
| `数据库设计文档.md` | ER 图 + 13 张表结构 + 索引 + 事务设计 |
| `接口设计文档.md` | 全部 API 端点表格 + 参数 + 返回格式 |
| `设计文档.md` | 系统架构 + 模块设计 + 安全 + 并发 + 缓存策略 |
| `BBS论坛项目分工方案.md` | 详细分工 + 工作量占比 + 开发规范 |
| `测试文档.md` | 测试用例 + 测试结果 + 功能验证 |
| `member_s_delivery_document.md` | 组长功能交付说明 |
| `member_a_delivery_document.md` | 组员A功能交付说明 |
| `member_b_delivery_document.md` | 组员B功能交付说明 |
| `member_c_delivery_document.md` | 组员C功能交付说明 |
| `member_d_delivery_document.md` | 组员D功能交付说明 |

## 部署说明

### 环境要求

- JDK 11+（推荐 JDK 21）
- MySQL 8.0+
- Linux 服务器（推荐 CentOS 7+ / Ubuntu 20.04+）
- 开放端口：80（HTTP）、22（SSH）

### 部署命令速查

```bash
# 1. 导入数据库
mysql -u root -p bbs_forum < database/init.sql

# 2. 构建项目
mvn clean package -DskipTests

# 3. 上传到服务器
scp target/BBSForum-exec.jar root@服务器IP:/root/bbs/
scp -r deploy/webapp root@服务器IP:/root/bbs/

# 4. 服务器上解压类文件
cd /root/bbs && unzip -o BBSForum-exec.jar "WEB-INF/classes/**/*" -d webapp/

# 5. 启动服务
cd /root/bbs && nohup java -cp BBSForum-exec.jar:webapp/WEB-INF/classes com.bbs.Main > bbs.log 2>&1 &

# 6. 查看日志
tail -f /root/bbs/bbs.log

# 7. 停止服务
kill $(cat /root/bbs/bbs.pid)
```

> 详细部署步骤请参见 `部署文档.docx`（位于 `F:\第十八小组\过程材料\`）

## 前端说明

- **Tailwind CSS CDN** 实现现代化界面，无需编译步骤
- **全局布局模板** `layouts/main.jsp`：导航栏 + 侧边栏 + 右侧数据面板 + 底部栏
- **统一弹窗系统**：自定义模态框替代原生 alert/confirm，三种视觉风格
- **响应式设计**：侧边栏和右侧面板在中大屏显示，小屏自动隐藏
- **SVG 封面图**：无封面帖子自动生成彩色渐变封面
- **AJAX 交互**：关注/点赞/收藏/采纳/AI 总结均无页面刷新
- **三主题切换**：默认风 / 科技霓虹 Vaporwave / 手绘涂鸦，CSS 防闪白注入技术
- **右侧面板**：实时数据列表式进度条（四色区分）+ 热门标签圆角标签云
- **通知系统**：回复/点赞/收藏/举报结果通知，60s 轮询未读数
- **排行榜头像**：支持真实头像优先显示，无头像回退首字 + 主题联动

## 开发规范

- 缩进：4 空格
- Java 命名：驼峰（`PostServlet.java`）
- JSP 命名：小写+下划线（`detail_content.jsp`）
- 页面采用 `xxx.jsp`（外壳）+ `xxx_content.jsp`（内容）拆分
- 列表数据通过 Servlet 查询 → `request.setAttribute` → JSTL 渲染
- 所有请求使用 UTF-8 编码
- 每人一个 Git 分支：`feature/模块名`

## 安全说明

- 密码：BCrypt 加密存储，兼容旧明文自动升级
- SQL：全部 PreparedStatement 参数化查询
- XSS：用户输入 HTML 转义
- 鉴权：AuthFilter 保护 `/user/profile/*` 和 `/admin/*`
- 配置：敏感信息从 `config.properties` 读取，已 `.gitignore`
- 事务：积分操作使用行锁（FOR UPDATE）+ commit/rollback
