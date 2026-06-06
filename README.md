# BBS论坛系统 — BBS技术社区

基于 Jakarta Servlet 5.0 + JSP + MySQL 的 BBS 技术社区，五人团队协作课程设计项目。

---

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|:----:|
| 后端 | Jakarta Servlet + JSP + JSTL | 5.0 |
| 数据库 | MySQL + JDBC | 8.0+ |
| 前端 | Tailwind CSS (CDN) + Font Awesome | 4.7.0 |
| 构建 | Maven（WAR + 可执行 JAR） | 3.6+ |
| 服务器 | 嵌入式 Tomcat (embed-core) | 10.1.52 |
| JDK | Java 11+（实际运行 Java 21） | |
| 密码加密 | jBCrypt | 0.4 |

## 项目结构

```
BBSForum/
├── pom.xml
├── README.md
├── database/
│   └── init.sql                        # 完整建库建表脚本（含迁移补丁）
├── src/
│   ├── main/
│   │   ├── java/com/bbs/
│   │   │   ├── Main.java               # 唯一启动入口（嵌入式Tomcat）
│   │   │   ├── controller/
│   │   │   │   ├── HomeServlet.java       # 首页帖子列表
│   │   │   │   ├── PostServlet.java       # 帖子CRUD / 回复 / AI总结 / 搜索 / 积分
│   │   │   │   ├── InteractionServlet.java# 关注/点赞/收藏
│   │   │   │   ├── HotServlet.java        # 热度榜
│   │   │   │   ├── CoverServlet.java      # SVG封面图生成
│   │   │   │   ├── CategoryServlet.java   # 板块帖子列表
│   │   │   │   ├── AdminCategoryServlet.java # 板块管理
│   │   │   │   ├── AdminPostServlet.java  # 置顶/加精管理
│   │   │   │   ├── UserServlet.java       # 注册/登录/登出/签到
│   │   │   │   ├── UserProfileServlet.java# 个人中心/资料编辑
│   │   │   │   ├── DemandServlet.java     # 需求CRUD / 回复 / 采纳
│   │   │   │   └── ScoreServlet.java      # 积分排行榜/流水
│   │   │   ├── filter/
│   │   │   │   ├── AuthFilter.java        # Session鉴权
│   │   │   │   ├── EncodingFilter.java    # UTF-8编码
│   │   │   │   └── StatsFilter.java       # 实时数据缓存
│   │   │   └── util/
│   │   │       ├── DBUtil.java            # 数据库连接
│   │   │       ├── PasswordUtil.java      # BCrypt密码加密
│   │   │       ├── AiUtil.java            # AI总结API调用
│   │   │       ├── ContentUtil.java       # Markdown渲染/XSS转义
│   │   │       └── PostMapper.java        # 帖子结果集映射
│   │   └── webapp/
│   │       ├── index.jsp
│   │       ├── WEB-INF/                  # 受保护模板
│   │       ├── layouts/main.jsp          # 全局布局（导航+侧栏+弹窗）
│   │       ├── post/                     # 帖子页面
│   │       ├── user/                     # 用户页面
│   │       ├── admin/                    # 管理后台页面
│   │       ├── demand/                   # 需求页面
│   │       ├── score/                    # 积分页面
│   │       ├── category/                 # 板块页面
│   │       └── error/                    # 错误页面
│   └── resources/
│       ├── config.properties             # 敏感配置（已 .gitignore）
│       └── config.properties.template    # 配置模板
```

## 快速开始

### 1. 初始化数据库

```bash
mysql -u root -p < database/init.sql
```

创建 `bbs_forum` 数据库，包含 11 张表、4 个板块、默认测试账号、8 条示例帖子。

### 2. 配置连接信息

编辑 `src/main/resources/config.properties`：

```properties
db.url=jdbc:mysql://localhost:3306/bbs_forum?useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
db.user=root
db.password=你的密码
ai.api.key=你的硅基流动API密钥（可选）
```

> 不配置 AI API Key 也能正常使用，只是 AI 总结功能不可用。

### 3. 编译启动

```bash
mvn clean compile
```

在 IDE 中运行 `src/main/java/com/bbs/Main.java`，控制台输出：

```
==========================================
  BBS技术社区 启动成功！
  http://localhost:8088/BBSForum/
==========================================
```

### 4. 访问

浏览器打开 `http://localhost:8088/BBSForum/`

| 账号 | 密码 | 角色 |
|------|------|------|
| admin | admin123 | 管理员 |
| test | test123 | 普通用户 |

## 功能清单

### 核心功能（已完成 ✓）

| 序号 | 功能 | 说明 |
|:----:|------|------|
| 1 | 发布帖子 | Markdown编辑器 + 封面图上传 + 关键词标签 |
| 2 | 回复帖子 | AJAX异步提交，按时间正序 |
| 3 | 板块分类 | 板块CRUD管理 + 侧边栏导航 |
| 4 | 置顶/加精 | 三级置顶循环 + 加精开关 |
| 5 | 用户系统 | 注册/登录/个人中心/资料编辑 |
| 6 | 需求悬赏 | 发布/编辑/回复/采纳 + 积分流转 |
| 7 | 积分系统 | 发帖+10 / 回复+2 / 点赞+3 / 签到+5 / 登录+2 |

### 创新功能（已完成 ✓）

| 难度 | 创新点 | 说明 |
|:----:|--------|------|
| 低 | 帖子搜索 | SQL LIKE 模糊匹配 + 分页 |
| 低 | 回帖不刷新 | AJAX 异步提交 |
| 低 | 点赞功能 | 实时计数 + 作者+3 积分 |
| 中 | 收藏帖子 | 书签按钮 + 计数实时更新 |
| 中 | 关注用户 | 关注列表管理 + 取消关注 |
| 中 | 热门排行 | 按浏览量排序 + 金银铜标记 |
| 中 | AI智能总结 | 调用大模型生成内容摘要 |
| 中 | 实时数据面板 | 帖子/评论/用户/需求统计 |
| 中 | 热门关键词 | 关键词聚合 + 点击搜索 |
| 高 | 图片上传 | 封面图 + 内联图片 + UUID重命名 |
| 中 | 积分排行 | TOP100 + 当前用户高亮 |
| 高 | 通知提示 | 操作成功/失败浮层 + URL参数 |
| 中 | 封面图自动生成 | 无封面帖子自动生成SVG |
| 中 | 统一弹窗系统 | 自定义模态框替换原生alert/confirm |
| 中 | 需求独立回复 | demand_replies表与帖子回复分离 |
| 中 | 每日签到 | 连续签到递增奖励封顶+15 |
| 中 | 事务保护 | 积分操作使用行锁（FOR UPDATE） |

## 页面路由

| URL | 页面 | 负责人 |
|-----|------|--------|
| `/` `/index` `/home` | 首页（帖子列表+板块导航） | 组长 |
| `/post/detail?id=` | 帖子详情+回复+互动 | 组长 |
| `/post/create` | 发布帖子 | 组长 |
| `/post/edit?id=` | 编辑帖子 | 组员C |
| `/post/search?keyword=` | 帖子搜索 | 组员A |
| `/cover/{id}?title=` | SVG封面图生成 | 组长 |
| `/category?id=` | 板块帖子列表 | 组员C |
| `/user/login` | 登录 | 组员B |
| `/user/register` | 注册 | 组员B |
| `/user/profile` | 个人中心 | 组员B |
| `/user/profile/edit` | 编辑资料 | 组员B |
| `/user/checkin` | 每日签到 | 组员B |
| `/user/profile/follows` | 关注列表 | 组长 |
| `/interact/follow` | 关注/取消（AJAX） | 组长 |
| `/interact/like` | 点赞/取消（AJAX） | 组长 |
| `/interact/favorite` | 收藏/取消（AJAX） | 组长 |
| `/hot` | 热度榜 | 组长 |
| `/admin` | 管理员后台首页 | 组员C |
| `/admin/categories` | 板块管理 | 组员C |
| `/admin/post/manage` | 帖子管理（置顶/加精） | 组员A |
| `/demand` | 需求列表 | 组员D |
| `/demand/detail?id=` | 需求详情+回复 | 组员D |
| `/demand/create` | 发布需求 | 组员D |
| `/demand/update?id=` | 编辑需求 | 组员D |
| `/score/rank` | 积分排行榜 | 组员D |
| `/score/record` | 积分流水 | 组员D |
| `/logout` | 退出登录 | 组员B |

## 模块分工

| 成员 | 模块 | 工作量 | 数据库 | 后端接口 | 前端页面 |
|------|------|:------:|:------:|:--------:|:--------:|
| **组长** | 帖子核心+公共架构+互动+创新 | **29%** | 5张 | 12个 | 6个 |
| **组员A** | 置顶/加精/搜索 | 15% | -- | 5个 | 3个 |
| **组员B** | 用户系统+签到+登录奖励 | 19% | 2张 | 7个 | 4个 |
| **组员C** | 板块管理+文章编辑+板块展示 | 19% | 1张 | 6个 | 4个 |
| **组员D** | 需求悬赏+积分流转+排行榜 | 18% | 3张 | 6个 | 5个 |

## 数据库表

| 表名 | 说明 | 记录数 | 负责人 |
|------|------|:------:|--------|
| users | 用户表（用户名/密码/角色/积分） | 2+ | 组员B |
| categories | 板块表（名称/描述/排序） | 4 | 组员C |
| posts | 帖子表（标题/内容/封面/置顶/加精/关键词） | 8+ | 组长+组员A |
| replies | 回复表（内容/所属帖子） | 0 | 组长 |
| demands | 需求表（标题/内容/悬赏积分/状态） | 1+ | 组员D |
| demand_replies | 需求回复表（独立于帖子回复） | 0 | 组员D |
| score_logs | 积分流水表（积分变动/原因） | 0 | 组员D |
| daily_checkins | 签到表（连续天数/获得积分） | 0 | 组员B |
| user_follows | 关注表（关注者/被关注者） | 0 | 组长 |
| post_likes | 点赞表（用户/帖子） | 0 | 组长 |
| post_favorites | 收藏表（用户/帖子） | 0 | 组长 |

## 文档索引

| 文档 | 说明 |
|------|------|
| `整体需求分析.md` | 15项功能需求 + 非功能需求 + 用例分析 |
| `数据库设计文档.md` | ER图 + 11张表结构 + 索引 + 事务设计 |
| `接口设计文档.md` | 全部API端点表格 + 参数 + 返回格式 |
| `设计文档.md` | 系统架构 + 模块设计 + 安全 + 并发 + 缓存策略 |
| `BBS论坛项目分工方案.md` | 详细分工 + 工作量占比 + 开发规范 |
| `member_s_delivery_document.md` | 组长功能交付说明 |

## 前端说明

- **Tailwind CSS CDN** 实现现代化界面，无需编译步骤
- **全局布局模板** `layouts/main.jsp`：导航栏 + 侧边栏 + 右侧数据面板 + 底部栏
- **统一弹窗系统**：自定义模态框替代原生 alert/confirm，三种视觉风格
- **响应式设计**：侧边栏和右侧面板在中大屏显示，小屏自动隐藏
- **SVG封面图**：无封面帖子自动生成彩色渐变封面
- **AJAX交互**：关注/点赞/收藏/采纳/AI总结均无页面刷新

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
