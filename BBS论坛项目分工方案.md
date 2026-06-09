# BBS论坛系统 项目分工方案

---

## 一、项目概述

**项目名称**：BBS论坛系统
**团队人数**：5人
**总分值**：80分
**开发模式**：每人全栈开发（前端页面 + 后端接口 + 数据库建表）
**技术栈**：Java Servlet + JSP + Tomcat + MySQL + Tailwind CSS

### 已实现功能清单

| 序号 | 功能 | 状态 |
|------|------|------|
| 1 | 发布帖子、回复帖子 | ✓ 已完成 |
| 2 | 置顶（板块置顶/全局置顶） | ✓ 已完成 |
| 3 | 帖子加精 | ✓ 已完成 |
| 4 | 发布需求信息（设置积分奖励） | ✓ 已完成 |
| 5 | 管理员或文章作者对文章进行修改 | ✓ 已完成 |
| 6 | 注册为BBS用户，维护个人资料 | ✓ 已完成 |
| 7 | 管理员设置板块 | ✓ 已完成 |
| 8 | 分板块展示 | ✓ 已完成 |

### 额外创新功能

| 难度 | 创新点 | 说明 | 状态 |
|------|--------|------|------|
| 低 | 帖子搜索 | SQL LIKE 关键词检索 | ✓ 已完成 |
| 低 | 回帖不刷新页面 | AJAX 异步提交 | ✓ 已完成 |
| 低 | 点赞功能 | 帖子点赞，计数实时更新 | ✓ 已完成 |
| 中 | 收藏帖子 | 用户收藏帖子，计数实时更新 | ✓ 已完成 |
| 中 | 关注用户 | 关注作者，关注列表管理 | ✓ 已完成 |
| 中 | 热门排行 | 按浏览量排序的热度榜 | ✓ 已完成 |
| 中 | AI智能总结 | 调用AI接口生成帖子摘要 | ✓ 已完成 |
| 中 | 实时数据面板 | 右侧栏展示帖子数/用户数/评论数/需求数 | ✓ 已完成 |
| 中 | 帖子草稿箱 | 保存草稿/草稿列表/继续编辑发布 | ✓ 已完成 |
| 中 | 嵌套回复 | 回复内回复/缩进显示/@引用通知 | ✓ 已完成 |
| 高 | 通知跳转 | 点击通知直接跳转对应帖子 | ✓ 已完成 |
| 高 | 仪表盘图表 | 管理员后台交互式Chart.js图表（板块分布环形图+发帖量折线图+注册量折线图） | ✓ 已完成 |
| 中 | 用户管理模块 | 管理员管理用户（分页/搜索/编辑/角色切换/删除） | ✓ 已完成 |
| 中 | 热门关键词 | 帖子关键词聚合展示，点击搜索 | ✓ 已完成 |
| 高 | 图片上传 | 发帖支持上传封面图 | ✓ 已完成 |
| 中 | 头像上传 | 用户头像上传、实时预览、格式校验、自动删除旧头像 | ✓ 已完成 |
| 中 | 积分排行 | 用户积分排行榜 | ✓ 已完成 |
| 高 | 通知提示 | 操作成功/失败浮层通知 | ✓ 已完成 |
| 高 | 举报系统 | 用户举报帖子/回复/需求，管理员审核处理 | ✓ 已完成 |
| 高 | 站内通知 | 举报处理结果通知、内容删除通知、AJAX轮询未读 | ✓ 已完成 |
| 中 | 软删除 | 帖子/回复/需求逻辑删除（is_deleted标记），保留数据可追溯 | ✓ 已完成 |
| 中 | 封面图自动生成 | 无封面帖子自动生成SVG彩色封面 | ✓ 已完成 |
| 中 | 统一弹窗系统 | 自定义模态框替换原生alert/confirm | ✓ 已完成 |
| 中 | 需求独立回复 | 需求回复独立表，与帖子回复分离 | ✓ 已完成 |
| 中 | 积分系统 | 发帖+10、回复+2、点赞+3、签到+5、登录+2 | ✓ 已完成 |
| 中 | 每日签到 | 连续签到奖励递增，封顶+15 | ✓ 已完成 |

---

## 二、角色与模块分工

### 组长：帖子核心功能 + 公共架构 + 创新功能 + 草稿箱 + 嵌套回复 + 通知跳转（25%）

| 开发层面 | 具体内容 |
|----------|----------|
| **涉及表** | 帖子表（posts）、回复表（replies）、关注表（user_follows）、点赞表（post_likes）、收藏表（post_favorites）建表。posts新增is_draft，replies新增parent_id |
| **后端接口** | 发布帖子、保存草稿、草稿箱列表、回复帖子（含嵌套回复parentId）、帖子列表/详情查询（过滤草稿）、删除帖子、关注/取消关注、点赞/取消点赞、收藏/取消收藏、AI总结、搜索结果、封面图生成(SVG)、积分操作(发帖+10/回复+2/点赞+3)、通知插入（new_reply/new_like/new_favorite/reply_reply类型携带target_url） |
| **前端页面** | 发帖页面（含"保存草稿"按钮）、帖子详情页（含嵌套回复缩进显示+回复按钮+@引用）、首页帖子列表、帖子搜索、草稿箱页面、布局模板（导航栏/侧边栏/底部栏）、统一弹窗系统、通知列表target_url跳转 |
| **公共架构** | 项目初始化、目录结构、数据库连接配置、全局样式、路由配置、代码合并、实时数据面板、热门关键词、config配置抽取 |
| **加分创新** | AI总结功能、关注/点赞/收藏互动系统、实时数据面板、热门关键词聚合、配置信息脱敏、封面图自动生成、统一弹窗系统、积分系统集成、帖子草稿箱、嵌套回复、通知跳转 |

**涉及文件清单**：

```
src/main/java/com/bbs/
  Main.java                    # Tomcat 嵌入式启动入口
  controller/
    HomeServlet.java           # 首页
    PostServlet.java           # 帖子CRUD + AI总结 + 搜索 + 积分(发帖+10/回复+2)
    InteractionServlet.java    # 关注/点赞/收藏 + 积分(点赞+3)
    CoverServlet.java          # SVG封面图生成(新增)
  util/
    DBUtil.java                # 数据库连接工具
    AiUtil.java                # AI接口调用
    ContentUtil.java           # 内容渲染（Markdown等）
    PostMapper.java            # 帖子结果集映射
    StatsFilter.java           # 实时数据统计缓存过滤器
    PasswordUtil.java          # 密码加密工具

src/main/webapp/
  layouts/
    main.jsp                   # 全局布局（导航栏+侧边栏+右侧面板+底部栏+统一弹窗）
  post/
    detail_content.jsp         # 帖子详情内容
    list.jsp                   # 帖子列表
    create.jsp                 # 发帖页面
```

---

### 组员A：置顶 + 加精 + 搜索 + 热度榜 + 举报系统 + 软删除 + 站内通知（20%）

| 开发层面 | 具体内容 |
|----------|----------|
| **涉及表** | posts（is_top/is_elite/搜索/热度）、reports（举报记录）、notifications（站内通知） |
| **后端接口** | 设置置顶（板块置顶/全局置顶）、取消置顶、设置加精、取消加精、帖子搜索（LIKE模糊匹配+分页+关键词）、管理员帖子管理列表、热度榜（按浏览量排序）、举报提交、举报管理列表、举报处理（审核通过/驳回）、通知列表、通知详情、通知未读数轮询、所有已有查询追加 is_deleted=0 软删除过滤 |
| **前端页面** | 管理员操作面板（置顶/加精/帖子管理）、举报管理页面（列表+处理）、通知列表页、通知详情页、帖子列表排序展示（置顶优先→加精次之→时间倒序）、搜索框及搜索结果展示、热度榜页面、帖子详情/需求详情举报按钮、顶部通知铃铛+轮询、置顶加精三级确认提示 |
| **积分协作** | 搜索结果列表中展示帖子作者的积分值 |

**涉及文件清单**：

```
src/main/java/com/bbs/controller/
  ReportServlet.java          # 举报处理（新增）
  NotificationServlet.java    # 站内通知（新增）
  AdminPostServlet.java       # 管理员帖子管理（置顶/加精）
  PostServlet.java            # 帖子搜索 + 软删除查询改造
  HotServlet.java             # 热度榜

src/main/webapp/
  admin/report_manage.jsp     # 举报管理页（新增）
  admin/report_manage_content.jsp # 举报管理内容（新增）
  notification/list.jsp       # 通知列表页（新增）
  notification/list_content.jsp # 通知列表内容（新增）
  notification/detail.jsp     # 通知详情页（新增）
  notification/detail_content.jsp # 通知详情内容（新增）
  admin/post_manage.jsp       # 帖子管理页面
  admin/post_manage_content.jsp # 管理内容页面
  layouts/main.jsp            # 搜索框 + 通知铃铛 + 举报管理菜单项 + 通知轮询
  post/list.jsp               # 搜索结果列表（复用首页模板）
  post/hot_content.jsp        # 热度榜页面
  post/detail_content.jsp     # 举报按钮
  demand/detail_content.jsp   # 举报按钮
```

**管理后台入口**：顶部导航栏用户名旁 → 管理 → 举报管理
**搜索入口**：顶部导航栏搜索框
**通知入口**：顶部导航栏通知铃铛

---

### 组员B：用户系统 + 签到 + 头像 + 个人中心扩展 + 鉴权拦截（19%）

| 开发层面 | 具体内容 |
|----------|----------|
| **涉及表** | 用户表（users）建表，字段包含：用户名、密码、角色、联系方式、工作性质、工作地点、头像路径、积分；签到表（daily_checkins）建表；积分流水表（score_logs）积分记录查询 |
| **后端接口** | 注册接口（BCrypt加密+事务）、登录接口（BCrypt/明文兼容+自动升级+Session Fixation防护）、退出登录、个人资料查询、个人资料更新（含头像上传JPG/PNG/GIF/WebP格式校验+自动删除旧头像）、密码修改、session鉴权拦截器（AuthFilter保护个人中心/后台/管理员校验）、每日签到接口（连续递增算法）、登录+2积分（防重复奖励）、积分流水查询（分页）、我的帖子查询、我的悬赏查询、我的点赞查询、我的收藏查询 |
| **前端页面** | 注册页（表单校验）、登录页（错误提示）、个人中心页（头像展示/首字母兜底/签到按钮AJAX/积分展示）、资料编辑页（头像上传实时预览FileReader+XSS过滤）、我的帖子列表、我的悬赏列表、我的点赞列表、我的收藏列表、积分流水记录（分页+正负号颜色）、公共边栏组件（导航高亮+最近积分记录5条）、头部栏头像展示 |
| **积分协作** | 登录成功当天首次+2分（事务+流水）、签到功能（连续签到5~15分递增封顶15、断签重置、事务+流水） |

**涉及文件清单**：

```
src/main/java/com/bbs/controller/
  UserServlet.java             # 注册/登录/登出/签到/登录+2分
  UserProfileServlet.java      # 个人中心/资料编辑/头像上传/积分记录
  UserProfilePlaceholderServlet.java  # 我的帖子/悬赏/点赞/收藏（新增）

src/main/java/com/bbs/filter/
  AuthFilter.java              # Session鉴权拦截器（新增）

src/main/webapp/user/
  login.jsp / login_content.jsp           # 登录页
  register.jsp / register_content.jsp     # 注册页
  profile.jsp / profile_content.jsp       # 个人中心
  profile_edit.jsp / profile_edit_content.jsp  # 资料编辑
  my_posts.jsp / my_posts_content.jsp     # 我的帖子（新增）
  my_demands.jsp / my_demands_content.jsp # 我的悬赏（新增）
  my_likes.jsp / my_likes_content.jsp     # 我的点赞（新增）
  my_favorites.jsp / my_favorites_content.jsp # 我的收藏（新增）
  score_log.jsp / score_log_content.jsp   # 积分记录（新增）
  profile_sidebar.jsp                     # 公共边栏组件（新增）

src/main/webapp/layouts/main.jsp          # 头部栏头像展示、登录/注册页隐藏搜索框
```

**个人中心入口**：顶部导航栏头像/用户名 → 个人中心
**签到入口**：个人中心右上角签到按钮

---

### 组员C：板块管理 + 文章编辑 + 分板块展示 + 用户管理 + 仪表盘图表 + 后台UI（19%）

| 开发层面 | 具体内容 |
|----------|----------|
| **涉及表** | 板块表（categories）建表、用户表（users）用户管理查询 |
| **后端接口** | 板块CRUD接口、按板块筛选帖子接口、帖子编辑接口（作者可改自己/管理员可改所有）、帖子删除接口、用户管理（分页+搜索+编辑+角色切换+删除受保护不能删自己/有帖子的用户）、仪表盘图表数据JSON接口（板块分布环形图+近30天发帖折线图+近7天注册折线图）、管理员帖子管理搜索排序增强（关键词/作者/板块筛选+ID升降序） |
| **前端页面** | 板块管理页（添加/编辑/删除）、首页分板块展示区、帖子编辑页、板块编辑页、用户管理列表页（分页+搜索）、用户编辑表单页、管理员帖子管理增强（搜索栏+排序按钮+筛选条件保持）、仪表盘交互式图表（Chart.js 4 环形图+折线图）、后台全局UI（返回首页按钮+底部固定布局+用户管理导航） |
| **积分协作** | 需求详情页回复列表"采纳"交互、编辑文章页显示作者积分 |

**涉及文件清单**：

```
src/main/java/com/bbs/controller/
  CategoryServlet.java          # 板块帖子列表
  AdminCategoryServlet.java     # 板块管理CRUD
  PostEditServlet.java          # 帖子编辑（新增）
  AdminUserServlet.java         # 用户管理（新增）
  AdminDashboardServlet.java    # 仪表盘图表数据JSON（新增）
  AdminPostServlet.java         # 帖子管理搜索排序增强（修改）

src/main/webapp/admin/
  categories.jsp / categories_content.jsp   # 板块管理
  category_edit.jsp / category_edit_content.jsp # 板块编辑
  users.jsp / users_content.jsp             # 用户管理（新增）
  user_edit.jsp / user_edit_content.jsp     # 用户编辑（新增）
  post_manage_content.jsp                   # 帖子管理增强（修改）
  index_content.jsp                         # 仪表盘图表（修改）

src/main/webapp/post/
  edit.jsp / edit_content.jsp               # 帖子编辑

src/main/webapp/layouts/main.jsp           # 后台全局UI（修改：返回首页+底部固定+导航）
src/main/java/com/bbs/util/PostMapper.java # 新增mapUserRow方法（修改）
database/init.sql                          # 新增列和表定义（修改）
```

---

### 组员D：需求悬赏 + 积分流转 + 排行榜（17%）

| 开发层面 | 具体内容 |
|----------|----------|
| **涉及表** | 需求表（demands）、需求回复表（demand_replies）、积分流水表（score_logs） |
| **后端接口** | 发布需求接口（积分校验score≥悬赏分+事务扣分）、需求列表接口（分页）、需求详情接口、采纳回复接口（FOR UPDATE行锁+权限/状态校验+积分转移事务）、积分排行榜接口（ORDER BY score DESC，全站排名+金银铜奖杯+当前用户高亮）、积分流水记录接口 |
| **前端页面** | 发布需求页（板块选择+标题+内容+悬赏积分表单）、需求列表页（悬赏积分标签+状态标识+分页）、需求详情页（回复列表+采纳按钮，仅发布者可见）、积分排行榜（金银铜奖杯+钻石图标+当前用户蓝色高亮）、积分流水记录（正负号颜色区分） |
| **积分协作** | 发布需求扣分（事务+积分不足校验）、采纳回复加分（FOR UPDATE行锁防并发、权限校验、状态校验「已结束不可再次采纳」、事务原子性） |

**涉及文件清单**：

```
src/main/java/com/bbs/controller/
  DemandServlet.java           # 需求发布/列表/详情/采纳
  ScoreServlet.java            # 积分排行榜/积分记录

src/main/webapp/
  demand/detail_content.jsp    # 需求详情（回复+采纳弹窗）
  post/demand_content.jsp      # 需求列表内容
  post/demand_create_content.jsp # 发布需求内容
  score/rank_content.jsp       # 排行榜页面（金银铜奖杯美化）
  score/record_content.jsp     # 积分流水页面
```

---

## 三、工作量占比

```
组长（帖子核心+架构+创新+积分+封面+弹窗+草稿箱+嵌套回复+通知跳转）：    *************************    25%
组员A（置顶+加精+搜索+热度榜+举报+软删除+通知）：********************               20%
组员B（用户系统+签到+头像+个人中心扩展+鉴权拦截）：*******************              19%
组员C（板块+编辑+展示+用户管理+仪表盘图表+后台UI）：*******************              19%
组员D（需求+积分+排行榜）：                  *****************                17%
```

> 组长新增创新功能加分项（关注/点赞/收藏/AI总结/热度榜/实时数据/热门标签/封面生成/统一弹窗/积分集成/帖子草稿箱/嵌套回复/通知跳转等）。

---

## 四、每人全栈对照表

| 成员 | 涉及表数 | 后端接口 | 前端页面 | 积分相关 |
|------|:----------:|:--------:|:--------:|:--------:|
| 组长 | x5 | x14 | x8 | 发帖+10、回复+2、点赞+3、收藏+5 |
| 组员A | x3 | x8 | x7 | 搜索列表展示积分 |
| 组员B | x3 | x10 | x10 | 签到+5~15、登录+2 |
| 组员C | x2 | x10 | x8 | 采纳页面交互 |
| 组员D | x3 | x6 | x5 | 发布扣分、采纳加分、排行榜 |

> 每人至少负责 **1张表、2个以上接口、2个以上页面**，确保所有成员都有实质性开发内容。

---

## 五、项目架构说明

### 5.1 项目目录结构

```
BBSForum/
├── pom.xml                   # Maven 依赖配置
├── database/
│   └── init.sql              # 完整数据库初始化脚本（含迁移补丁）
├── src/
│   ├── main/
│   │   ├── java/com/bbs/
│   │   │   ├── Main.java              # 嵌入式 Tomcat 启动入口（端口8088）
│   │   │   ├── controller/            # Servlet 控制器层
│   │   │   ├── util/                   # 工具类
│   │   │   └── filter/                # 过滤器
│   │   ├── resources/
│   │   │   ├── config.properties      # 敏感配置（已加入.gitignore）
│   │   │   └── config.properties.template  # 配置模板
│   │   └── webapp/
│   │       ├── layouts/main.jsp       # 公共布局模板（含统一弹窗）
│   │       ├── post/                  # 帖子相关页面
│   │       ├── user/                  # 用户相关页面
│   │       ├── demand/                # 需求相关页面
│   │       ├── score/                 # 积分相关页面
│   │       ├── admin/                 # 管理后台页面
│   │       ├── WEB-INF/               # 路由分发JSP
│   │       └── js/common.js          # 公共JavaScript
│   └── test/
└── target/                   # 编译输出
```

### 5.2 核心技术栈

| 类别 | 实际方案 |
|------|----------|
| 后端框架 | Jakarta Servlet（Java） + 嵌入式Tomcat 10.1 |
| 视图模板 | JSP + JSTL |
| 数据库 | MySQL 8.0 + JDBC |
| 前端样式 | Tailwind CSS CDN |
| 图标 | Font Awesome 4.7 CDN |
| 构建工具 | Maven |
| 密码加密 | BCrypt (jBCrypt) |
| 封面生成 | SVG（内联生成，无外部依赖） |
| 弹窗系统 | 自定义CSS模态框（无外部依赖） |

### 5.3 启动方式

```bash
# 方式一：IDE 中右键运行 Main.java
# 方式二：命令行
mvn compile
java -cp "target/classes;target/dependency/*" com.bbs.Main

# 访问地址：http://localhost:8088/BBSForum/
```

---

## 六、核心数据表设计

### 用户表（users）—— 组员B负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| username | VARCHAR(50) | 用户名，唯一 |
| password | VARCHAR(255) | BCrypt加密密码 |
| phone | VARCHAR(20) | 联系方式 |
| job_type | VARCHAR(50) | 工作性质 |
| job_location | VARCHAR(100) | 工作地点 |
| role | ENUM('user','admin') | 角色，默认user |
| score | INT | 积分累计，默认0 |
| created_at | DATETIME | 注册时间 |

### 板块表（categories）—— 组员C负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| name | VARCHAR(50) | 板块名称 |
| description | VARCHAR(200) | 板块描述 |
| sort_order | INT | 排序权重 |
| created_at | DATETIME | 创建时间 |

### 帖子表（posts）—— 组长+组员A负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| title | VARCHAR(100) | 标题 |
| content | TEXT | 内容（Markdown格式） |
| image_url | VARCHAR(500) | 封面图URL |
| keywords | VARCHAR(200) | 关键词，逗号分隔 |
| ai_summary | TEXT | AI总结内容 |
| ai_user_id | INT | AI总结生成者 |
| user_id | INT | 作者ID（外键） |
| category_id | INT | 所属板块ID（外键） |
| is_top | TINYINT | 置顶状态：0=否 1=板块置顶 2=全局置顶（组员A） |
| is_elite | TINYINT | 是否加精，默认0（组员A） |
| like_count | INT | 点赞数，默认0 |
| favorite_count | INT | 收藏数，默认0 |
| view_count | INT | 浏览次数，默认0 |
| is_draft | TINYINT | 草稿标识：0=已发布 1=草稿（组长新增） |
| created_at | DATETIME | 发布时间 |
| updated_at | DATETIME | 修改时间 |

### 回复表（replies）—— 组长负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| content | TEXT | 回复内容 |
| user_id | INT | 回复者ID（外键） |
| post_id | INT | 所属帖子ID（外键） |
| parent_id | INT | 父回复ID，NULL=直接回复帖子（自引用外键） |
| created_at | DATETIME | 回复时间 |

### 需求表（demands）—— 组员D负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| title | VARCHAR(100) | 需求标题 |
| content | TEXT | 需求描述 |
| user_id | INT | 发布者ID（外键） |
| score | INT | 悬赏积分 |
| status | ENUM('open','closed') | 状态，默认open |
| best_reply_id | INT | 最佳回复ID（采纳后填入） |
| created_at | DATETIME | 发布时间 |

### 需求回复表（demand_replies）—— 组员D负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| content | TEXT | 回复内容 |
| user_id | INT | 回复者ID（外键） |
| demand_id | INT | 所属需求ID（外键） |
| created_at | DATETIME | 回复时间 |

### 积分流水表（score_logs）—— 组员D负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| user_id | INT | 用户ID |
| score | INT | 积分变动（正数为获得，负数为扣除） |
| reason | VARCHAR(100) | 变动原因 |
| created_at | DATETIME | 时间 |

### 签到表（daily_checkins）—— 组员B负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| user_id | INT | 用户ID（外键） |
| checkin_date | DATE | 签到日期 |
| consecutive_days | INT | 连续签到天数 |
| score_earned | INT | 本次获得积分，默认5 |
| created_at | DATETIME | 签到时间 |

### 举报记录表（reports）—— 组员A负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| reporter_id | INT | 举报人ID |
| target_type | ENUM | 举报类型：post/reply/demand/demand_reply |
| target_id | INT | 被举报对象ID |
| reason | VARCHAR(20) | 举报原因代码：spam/abuse/illegal/porn/other |
| status | ENUM | 处理状态：pending/approved/rejected |
| handler_id | INT | 处理人ID（管理员） |
| handle_note | VARCHAR(200) | 处理备注 |
| created_at | DATETIME | 举报时间 |
| updated_at | DATETIME | 更新时间 |

### 站内通知表（notifications）—— 组员A+组长负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| user_id | INT | 接收人ID |
| type | VARCHAR(20) | 类型：report_result/content_deleted/new_reply/new_like/new_favorite/reply_reply |
| content | VARCHAR(500) | 通知内容 |
| target_url | VARCHAR(500) | 通知关联的跳转链接（组长新增，用于互动通知） |
| is_read | TINYINT | 0未读 1已读 |
| created_at | DATETIME | 创建时间 |

### 互动表（组长新增）

**关注表（user_follows）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| user_id | INT | 关注者ID |
| followed_user_id | INT | 被关注者ID |
| created_at | DATETIME | 关注时间 |

**点赞表（post_likes）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| user_id | INT | 点赞者ID |
| post_id | INT | 帖子ID |
| created_at | DATETIME | 点赞时间 |

**收藏表（post_favorites）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| user_id | INT | 收藏者ID |
| post_id | INT | 帖子ID |
| created_at | DATETIME | 收藏时间 |

**ER图说明**：
```
users ──< posts ──< replies ──< replies（自引用，parent_id嵌套回复）
users ──< demands ──< demand_replies
users ──< score_logs
users ──< daily_checkins
users ──< user_follows >── users
users ──< post_likes >── posts
users ──< post_favorites >── posts
users ──< reports              （举报人→记录）
users ──< notifications        （用户→通知）
categories ──< posts
```

---

## 七、URL路由约定

```
GET    /BBSForum/                                     首页
GET    /BBSForum/post/detail?id=1                     帖子详情页
GET    /BBSForum/post/create                          发布帖子页
POST   /BBSForum/post/create                          提交帖子（+10积分）
GET    /BBSForum/post/drafts                          草稿箱（组长新增）
GET    /BBSForum/post/edit?id=1                       编辑帖子页
POST   /BBSForum/post/edit                            提交编辑
POST   /BBSForum/post/delete?id=1                     删除帖子
POST   /BBSForum/post/reply                           回复帖子（+2积分，支持parentId嵌套回复）
POST   /BBSForum/post/aiSummary                       生成AI总结
GET    /BBSForum/post/search?keyword=xx               搜索帖子
GET    /BBSForum/cover/42?title=标题                   封面图生成（组长新增）
GET    /BBSForum/category?id=1                        板块帖子列表
GET    /BBSForum/user/login                           登录页
POST   /BBSForum/user/login                           提交登录（+2积分）
GET    /BBSForum/user/register                        注册页
POST   /BBSForum/user/register                        提交注册
GET    /BBSForum/user/profile                         个人中心
GET    /BBSForum/user/profile/edit                    编辑资料
POST   /BBSForum/user/profile/edit                    提交编辑
GET    /BBSForum/user/checkin                         每日签到（+5积分 组员B）
GET    /BBSForum/user/score-log                       积分记录（组员B）
GET    /BBSForum/user/profile/follows                 关注列表（组长新增）
GET    /BBSForum/user/profile/posts                   我的帖子（组员B新增）
GET    /BBSForum/user/profile/demands                 我的悬赏（组员B新增）
GET    /BBSForum/user/profile/likes                   我的点赞（组员B新增）
GET    /BBSForum/user/profile/favorites               我的收藏（组员B新增）
POST   /BBSForum/interact/follow                      关注/取消关注（组长新增）
POST   /BBSForum/interact/like                        点赞/取消点赞（+3积分 组长新增）
POST   /BBSForum/interact/favorite                    收藏/取消收藏（组长新增）
GET    /BBSForum/hot                                  热度榜（组员A）
GET    /BBSForum/admin                                管理员首页（含Chart.js图表）
GET    /BBSForum/admin/users                          用户管理列表（组员C）
GET    /BBSForum/admin/users/edit                     用户编辑（组员C）
POST   /BBSForum/admin/users/edit                     保存用户编辑（组员C）
POST   /BBSForum/admin/users/toggleRole               切换用户角色（组员C）
POST   /BBSForum/admin/users/delete                   删除用户（组员C）
GET    /BBSForum/admin/chart/postsByCategory           板块分布图表数据JSON（组员C）
GET    /BBSForum/admin/chart/dailyPosts                近30天发帖量图表数据JSON（组员C）
GET    /BBSForum/admin/chart/userGrowth                近7天注册量图表数据JSON（组员C）
POST   /BBSForum/admin/post/top                       置顶帖子（组员A）
POST   /BBSForum/admin/post/elite                     加精帖子（组员A）
POST   /BBSForum/admin/category/add                   添加板块
POST   /BBSForum/admin/category/edit                  编辑板块
POST   /BBSForum/admin/category/delete                删除板块
GET    /BBSForum/demand                               需求列表
GET    /BBSForum/demand/detail?id=1                   需求详情
GET    /BBSForum/demand/create                        发布需求页
POST   /BBSForum/demand/create                        提交需求（扣积分）
POST   /BBSForum/demand/reply                         需求回复
POST   /BBSForum/demand/accept                        采纳回复（转积分）
GET    /BBSForum/demand/update?id=1                   编辑需求页
POST   /BBSForum/demand/update                        提交编辑
GET    /BBSForum/logout                               退出登录
GET    /BBSForum/score/rank                           积分排行
GET    /BBSForum/score/record                         积分记录
POST   /BBSForum/report                               提交举报（组员A）
GET    /BBSForum/admin/report                         举报管理列表（组员A）
POST   /BBSForum/admin/report/handle                  处理举报（组员A）
GET    /BBSForum/notification/list                    通知列表（组员A）
GET    /BBSForum/notification/detail?id=1             通知详情（组员A）
```

---

## 八、依赖关系与开发顺序

### 依赖图

```
组员C（板块表）
    |
    +--- 组长（帖子核心，发帖要选板块）
    |       |
    |       +--- 组员A（置顶加精+搜索+热度榜+举报+软删除，依赖帖子表）
    |
    +--- 组员D（需求信息，独立建表 demands + demand_replies + score_logs）
    |
    +--- 组员B（用户系统，贯穿全程，注册登录是入口 + daily_checkins + 鉴权拦截）
```

### 时间节点

| 时间 | 负责人 | 里程碑 | 产出 |
|------|--------|--------|------|
| 第1-2天 | 组长 | 架构搭建 | 项目模板、数据库SQL脚本、公共布局页面 |
| 第2-5天 | 组员C | 板块先行 | 板块表建表完成，板块CRUD接口可用 |
| 第3-8天 | 全员 | 并行开发 | 各自模块完整全栈开发 |
| 第9-14天 | 全员 | 创新功能+收尾 | 组长：关注/点赞/收藏/AI总结/实时数据等；组员A：热度榜+举报系统+通知；组员B：头像上传+个人中心扩展；组员C：用户管理+仪表盘图表+后台UI |
| 第15-16天 | 全员 | 联调测试+收尾 | 积分系统、封面生成、统一弹窗、bug修复 |

---

## 九、开发规范

### 代码风格
- 缩进：4空格
- 命名规范：Java类用驼峰（PostServlet.java），JSP用小写（detail_content.jsp）
- 所有接口返回 JSON 格式（交互接口），页面跳转用 redirect
- 中文注释，每个函数说明用途

### Git协作
- 每人一个分支，命名格式：feature/模块名
- 推送前先拉取最新代码
- 合并到主分支前，必须先在本地测试无误

### 安全配置
- 敏感信息（数据库密码、API密钥）统一放在 `config.properties` 中
- `config.properties` 已加入 `.gitignore`，不上传到远程仓库
- 提供 `config.properties.template` 作为开发参考

---

## 十、答辩准备建议

### 演示流程

```
注册/登录 → 浏览板块 → 发布帖子 → 回复帖子
→ 管理员置顶/加精 → 编辑文章 → 发布需求悬赏
→ 关注作者 → 点赞/收藏帖子 → 查看热度榜
→ AI总结 → 积分排行 → 每日签到
→ 举报帖子/回复 → 管理员审核处理 → 查看通知结果
→ 管理员后台 → 用户管理 → 仪表盘图表 → 帖子管理搜索排序
```

### 每人准备

- **一句话模块介绍**：我负责的是XXX模块，实现了XXX功能
- **演示1-2个亮点功能**：选最有交互感的
- **技术亮点准备**：
  - 组长可讲：MVC架构设计、数据库关系设计、AJAX交互（关注/点赞不刷新页面）、AI接口集成、嵌入式Tomcat部署、SVG封面生成、统一弹窗系统
  - 组员A可讲：多条件排序算法（置顶>加精>时间）、搜索LIKE匹配+关键词检索、举报系统流转（用户举报→管理员审核→通知反馈）、软删除机制（逻辑删除保留数据）、通知轮询（AJAX定时检查未读数）
  - 组员B可讲：密码BCrypt加密存储+旧明文自动升级、session鉴权机制（Session Fixation防护+AuthFilter拦截）、签到连续奖励算法（递增封顶+断签重置）、头像上传（multipart格式校验+UUID重命名+自动删除旧文件+实时预览）、个人中心扩展（我的帖子/悬赏/点赞/收藏四联查）、积分记录分页
  - 组员C可讲：RBAC权限控制（作者/管理员不同权限）、板块CRUD、用户管理模块（角色切换/自我保护/删除校验）、Chart.js交互式仪表盘图表（AJAX加载JSON数据+环形图/折线图渲染）、帖子管理搜索排序（多条件筛选+翻页状态保持）
  - 组员D可讲：积分流转的事务处理（FOR UPDATE行锁）、需求状态管理

---

> **文档更新日期**：2026-06-08
> **说明**：本文档根据实际开发完成情况更新，所有功能均已实现并测试可用。

---

## 十一、积分系统设计方案

### 11.1 积分规则总览

| 操作 | 积分变动 | 说明 |
|------|:--------:|------|
| 发布帖子 | **+10** | 发帖成功后自动增加 |
| 回复帖子 | **+2** | 回复成功后给回复者增加 |
| 每日签到 | **+5~15** | 每天限一次，连续签到递增封顶+15 |
| 帖子被点赞 | **+3** | 有人点赞帖子，给帖子作者增加 |
| 帖子被收藏 | **+5** | 有人收藏帖子，给帖子作者增加 |
| 帖子被取消点赞 | **-3** | 取消点赞时扣除（防止刷分） |
| 帖子被取消收藏 | **-5** | 取消收藏时扣除（防止刷分） |
| 每日首次登录 | **+2** | 登录成功后自动发放 |
| 回复被采纳 | **+悬赏分** | 需求发布者采纳回复后转给回复者 |
| 发布需求 | **-悬赏分** | 发布悬赏时从发布者账户扣除 |

> 连续签到奖励递增：连续签到第1天+5，第2天+6，第3天+7...封顶+15

### 11.2 数据库新增表

**签到表（daily_checkins）—— 组员B负责**

```sql
CREATE TABLE IF NOT EXISTS daily_checkins (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    user_id           INT NOT NULL COMMENT '用户ID',
    checkin_date      DATE NOT NULL COMMENT '签到日期',
    consecutive_days  INT NOT NULL DEFAULT 1 COMMENT '连续签到天数',
    score_earned      INT NOT NULL DEFAULT 5 COMMENT '本次获得积分',
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '签到时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uk_user_date (user_id, checkin_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日签到表';
```

**需求回复表（demand_replies）—— 组员D负责**

```sql
CREATE TABLE IF NOT EXISTS demand_replies (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    content     TEXT NOT NULL COMMENT '回复内容',
    user_id     INT NOT NULL COMMENT '回复者ID',
    demand_id   INT NOT NULL COMMENT '所属需求ID',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (demand_id) REFERENCES demands(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='需求回复表';
```

### 11.3 新增URL路由

```
GET    /BBSForum/user/checkin                          每日签到（组员B）
POST   /BBSForum/demand/reply                          需求回复（组员D）
POST   /BBSForum/demand/update                         编辑需求（组员D）
GET    /BBSForum/demand/update?id=1                    编辑需求页（组员D）
GET    /BBSForum/score/record                          积分记录（组员D）
GET    /BBSForum/post/drafts                           草稿箱（组长新增）
```
