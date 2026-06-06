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
| 中 | 热门关键词 | 帖子关键词聚合展示，点击搜索 | ✓ 已完成 |
| 高 | 图片上传 | 发帖支持上传封面图 | ✓ 已完成 |
| 中 | 积分排行 | 用户积分排行榜 | ✓ 已完成 |
| 高 | 通知提示 | 操作成功/失败浮层通知 | ✓ 已完成 |

---

## 二、角色与模块分工

### 组长：帖子核心功能 + 公共架构 + 创新功能（28%）

| 开发层面 | 具体内容 |
|----------|----------|
| **数据库** | 帖子表（posts）、回复表（replies）、关注表（user_follows）、点赞表（post_likes）、收藏表（post_favorites）建表 |
| **后端接口** | 发布帖子、回复帖子、帖子列表/详情查询、删除帖子、关注/取消关注、点赞/取消点赞、收藏/取消收藏、AI总结、搜索结果、热度榜 |
| **前端页面** | 发帖页面、帖子详情页（含回复列表/关注/点赞/收藏）、首页帖子列表、热度榜、帖子搜索、布局模板（导航栏/侧边栏/底部栏） |
| **公共架构** | 项目初始化、目录结构、数据库连接配置、全局样式、路由配置、代码合并、实时数据面板、热门关键词、config配置抽取 |
| **加分创新** | AI总结功能、关注/点赞/收藏互动系统、热度排行、实时数据面板、热门关键词聚合、配置信息脱敏 |

**涉及文件清单**：

```
src/main/java/com/bbs/
  Main.java                    # Tomcat 嵌入式启动入口
  controller/
    HomeServlet.java           # 首页
    PostServlet.java           # 帖子CRUD + AI总结 + 搜索
    InteractionServlet.java    # 关注/点赞/收藏交互
    HotServlet.java            # 热度榜
  util/
    DBUtil.java                # 数据库连接工具
    AiUtil.java                # AI接口调用
    ContentUtil.java           # 内容渲染（Markdown等）
    PostMapper.java            # 帖子结果集映射
    StatsFilter.java           # 实时数据统计缓存过滤器
    PasswordUtil.java          # 密码加密工具

src/main/webapp/
  layouts/
    main.jsp                   # 全局布局（导航栏+侧边栏+右侧面板+底部栏）
  post/
    detail_content.jsp         # 帖子详情内容
    list.jsp                   # 帖子列表
    create.jsp                 # 发帖页面
    hot_content.jsp            # 热度榜内容
```

---

### 组员A：置顶 + 加精 + 搜索（18%）

| 开发层面 | 具体内容 |
|----------|----------|
| **数据库** | 帖子表扩展字段：is_top（置顶，0/1/2）、is_elite（加精） |
| **后端接口** | 设置置顶（板块置顶/全局置顶）、取消置顶、设置加精、取消加精、帖子搜索（LIKE模糊匹配+分页） |
| **前端页面** | 管理员操作面板（置顶/加精按钮）、帖子列表排序展示（置顶优先→加精次之→时间倒序）、搜索框及搜索结果展示 |

**涉及文件清单**：

```
src/main/java/com/bbs/controller/
  AdminPostServlet.java        # 管理员帖子管理（置顶/加精）
  PostServlet.java             # 帖子搜索（handleSearch/countSearchPosts/searchPosts）
src/main/webapp/
  layouts/main.jsp             # 搜索框组件
  post/list.jsp                # 搜索结果列表（复用首页模板）
```

**管理后台入口**：顶部导航栏用户名旁 → 管理
**搜索入口**：顶部导航栏搜索框

---

### 组员B：用户系统（18%）

| 开发层面 | 具体内容 |
|----------|----------|
| **数据库** | 用户表（users）建表，字段包含：用户名、密码、角色、联系方式、工作性质、工作地点 |
| **后端接口** | 注册接口、登录接口、退出登录、个人资料查询、个人资料更新、密码修改、session鉴权 |
| **前端页面** | 注册页、登录页、个人中心页（查看资料）、资料编辑页 |

**涉及文件清单**：

```
src/main/java/com/bbs/controller/
  UserServlet.java             # 注册/登录/登出
  UserProfileServlet.java      # 个人中心/资料编辑

src/main/webapp/user/
  login.jsp                    # 登录页
  register.jsp                 # 注册页
  profile.jsp / profile_content.jsp          # 个人中心
  profile_edit.jsp / profile_edit_content.jsp # 资料编辑
```

---

### 组员C：板块管理 + 文章编辑 + 分板块展示（19%）

| 开发层面 | 具体内容 |
|----------|----------|
| **数据库** | 板块表（categories）建表，字段：板块名称、描述、排序权重 |
| **后端接口** | 板块CRUD接口、按板块筛选帖子接口、文章编辑接口（作者可改自己、管理员可改所有）、文章删除接口 |
| **前端页面** | 板块管理页（管理员）、首页分板块展示区、帖子编辑页 |

**涉及文件清单**：

```
src/main/java/com/bbs/controller/
  CategoryServlet.java         # 板块帖子列表
  AdminCategoryServlet.java    # 板块管理CRUD

src/main/webapp/post/
  edit.jsp                     # 帖子编辑页
```

---

### 组员D：需求悬赏 + 积分（19%）

| 开发层面 | 具体内容 |
|----------|----------|
| **数据库** | 需求表（demands）、积分流水表（score_logs） |
| **后端接口** | 发布需求接口、需求列表/详情接口、积分记录查询接口 |
| **前端页面** | 发布需求页、需求列表页、积分排行页 |

**涉及文件清单**：

```
src/main/java/com/bbs/controller/
  DemandServlet.java           # 需求发布/列表

src/main/webapp/post/
  demand_content.jsp           # 需求列表内容
  demand_create_content.jsp    # 发布需求内容
```

---

## 三、工作量占比

```
组长（帖子核心+架构+创新）：  ************************** 26%
组员C（板块+编辑+展示）：    *******************          19%
组员B（用户系统）：          ******************           18%
组员D（需求+积分）：         *******************          19%
组员A（置顶+加精+搜索）：   ******************           18%
```

> 组长新增创新功能加分项（关注/点赞/收藏/AI总结/热度榜/实时数据/热门标签等），工作量相应增加。

---

## 四、每人全栈对照表

| 成员 | 数据库建表 | 后端接口 | 前端页面 |
|------|:----------:|:--------:|:--------:|
| 组长 | x5 | x10 | x5 |
| 组员A | x1 | x5 | x3 |
| 组员B | x1 | x5 | x4 |
| 组员C | x1 | x5 | x3 |
| 组员D | x2 | x4 | x3 |

> 每人至少负责 **1张表、2个以上接口、2个以上页面**，确保所有成员都有实质性开发内容。

---

## 五、项目架构说明

### 5.1 项目目录结构

```
BBSForum/
├── pom.xml                   # Maven 依赖配置
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
│   │       ├── layouts/main.jsp       # 公共布局模板
│   │       ├── post/                  # 帖子相关页面
│   │       ├── user/                  # 用户相关页面
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
| password | VARCHAR(255) | 加密密码 |
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
| content | TEXT | 内容 |
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
| created_at | DATETIME | 发布时间 |
| updated_at | DATETIME | 修改时间 |

### 回复表（replies）—— 组长负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| content | TEXT | 回复内容 |
| user_id | INT | 回复者ID（外键） |
| post_id | INT | 所属帖子ID（外键） |
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

### 积分流水表（score_logs）—— 组员D负责

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| user_id | INT | 用户ID |
| score | INT | 积分变动（正数为获得，负数为扣除） |
| reason | VARCHAR(100) | 变动原因 |
| created_at | DATETIME | 时间 |

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

---

## 七、URL路由约定

```
GET    /BBSForum/                                     首页
GET    /BBSForum/post/detail?id=1                     帖子详情页
GET    /BBSForum/post/create                          发布帖子页
POST   /BBSForum/post/create                          提交帖子
GET    /BBSForum/post/edit?id=1                       编辑帖子页
POST   /BBSForum/post/edit                            提交编辑
POST   /BBSForum/post/delete?id=1                     删除帖子
POST   /BBSForum/post/reply                           回复帖子
POST   /BBSForum/post/aiSummary                       生成AI总结
GET    /BBSForum/post/search?keyword=xx               搜索帖子
GET    /BBSForum/category?id=1                        板块帖子列表
GET    /BBSForum/user/login                           登录页
POST   /BBSForum/user/login                           提交登录
GET    /BBSForum/user/register                        注册页
POST   /BBSForum/user/register                        提交注册
GET    /BBSForum/user/profile                         个人中心
GET    /BBSForum/user/profile/edit                    编辑资料
POST   /BBSForum/user/profile/edit                    提交编辑
GET    /BBSForum/user/profile/follows                 关注列表（组长新增）
POST   /BBSForum/interact/follow                      关注/取消关注（组长新增）
POST   /BBSForum/interact/like                        点赞/取消点赞（组长新增）
POST   /BBSForum/interact/favorite                    收藏/取消收藏（组长新增）
GET    /BBSForum/hot                                  热度榜（组长新增）
GET    /BBSForum/admin                                管理员首页
POST   /BBSForum/admin/post/top                       置顶帖子（组员A）
POST   /BBSForum/admin/post/elite                     加精帖子（组员A）
POST   /BBSForum/admin/category/add                   添加板块
POST   /BBSForum/admin/category/edit                  编辑板块
POST   /BBSForum/admin/category/delete                删除板块
GET    /BBSForum/demand                               需求列表
GET    /BBSForum/demand/create                        发布需求页
POST   /BBSForum/demand/create                        提交需求
GET    /BBSForum/logout                               退出登录
GET    /BBSForum/score/rank                           积分排行
```

---

## 八、依赖关系与开发顺序

### 依赖图

```
组员C（板块表）
    |
    +--- 组长（帖子核心，发帖要选板块）
    |       |
    |       +--- 组员A（置顶加精，依赖帖子表 is_top/is_elite 字段）
    |
    +--- 组员D（需求信息，独立建表）
    |
    +--- 组员B（用户系统，贯穿全程，注册登录是入口）
```

### 时间节点

| 时间 | 负责人 | 里程碑 | 产出 |
|------|--------|--------|------|
| 第1-2天 | 组长 | 架构搭建 | 项目模板、数据库SQL脚本、公共布局页面 |
| 第2-5天 | 组员C | 板块先行 | 板块表建表完成，板块CRUD接口可用 |
| 第3-8天 | 全员 | 并行开发 | 各自模块完整全栈开发 |
| 第9-14天 | 组长 | 创新功能+收尾 | 关注/点赞/收藏/AI总结/热度榜/实时数据等 |
| 第15-16天 | 全员 | 联调测试 | 接口对接、bug修复、功能串联 |

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
→ AI总结 → 积分排行
```

### 每人准备

- **一句话模块介绍**：我负责的是XXX模块，实现了XXX功能
- **演示1-2个亮点功能**：选最有交互感的
- **技术亮点准备**：
  - 组长可讲：MVC架构设计、数据库关系设计、AJAX交互（关注/点赞不刷新页面）、AI接口集成、嵌入式Tomcat部署
  - 组员A可讲：多条件排序算法（置顶>加精>时间）
  - 组员B可讲：密码加密存储、session鉴权机制
  - 组员C可讲：RBAC权限控制（作者/管理员不同权限）
  - 组员D可讲：积分流转的事务处理

---

> **文档更新日期**：2026-06-06
> **说明**：本文档根据实际开发完成情况更新，所有功能均已实现并测试可用。

---

## 十一、积分系统设计方案

### 11.1 积分规则总览

| 操作 | 积分变动 | 说明 |
|------|:--------:|------|
| 发布帖子 | **+10** | 成功发帖后自动增加 |
| 回复帖子 | **+2** | 回复成功后给回复者增加 |
| 每日签到 | **+5** | 每天限一次，点击签到按钮领取 |
| 帖子被点赞 | **+3** | 有人点赞帖子，给帖子作者增加 |
| 每日首次登录 | **+2** | 登录成功后自动发放 |
| 回复被采纳 | **+悬赏分** | 需求发布者采纳回复后转给回复者 |
| 发布需求 | **-悬赏分** | 发布悬赏时从发布者账户扣除 |

> 连续签到奖励递增：连续签到第1天+5，第2天+6，第3天+7...封顶+15

### 11.2 角色分工

#### 组长（S）：帖子维度积分

**负责内容**：
- **发帖 +10 分**：在 `PostServlet.handleCreatePost()` 创建帖子成功后，调用积分工具给作者加 10 分，并写入 `score_logs`
- **回复 +2 分**：在 `PostServlet.handleReply()` 回复成功后，给回复者加 2 分，并写入 `score_logs`
- **点赞 +3 分**：在 `InteractionServlet.doLike()` 点赞时，查询帖子作者 ID，给作者加 3 分，并写入 `score_logs`

**涉及文件**：
```
src/main/java/com/bbs/controller/
  PostServlet.java           # 发帖+加分、回复+加分
  InteractionServlet.java    # 点赞+给作者加分
```

#### 组员A（A）：搜索结果展示积分

**负责内容**：
- 搜索结果列表展示帖子作者的积分值
- 搜索接口返回数据中包含作者积分字段

**涉及文件**：
```
src/main/webapp/post/list.jsp             # 搜索结果中展示作者积分
src/main/java/com/bbs/controller/
  PostServlet.java           # 搜索SQL关联users表查询score
```

#### 组员B（B）：用户签到 + 登录奖励

**负责内容**：
- **建表**：新建 `daily_checkins` 签到表
- **每日签到 +5 分**：新增接口 `/user/checkin`，每天限签到一次，给用户加积分并写入 `score_logs`
- **连续签到递增**：第1天+5，第2天+6，... 封顶+15，断签重置为第1天
- **登录 +2 分**：在 `UserServlet` 登录成功后，判断是否当天已领，未领则发放 +2 并写入 `score_logs`
- **前端签到按钮**：用户中心或个人资料页显示签到按钮，显示今日已签到/去签到状态

**涉及文件**：
```
src/main/java/com/bbs/controller/
  UserServlet.java           # 登录+2分、签到接口

src/main/webapp/user/
  profile.jsp                # 签到按钮 UI
```

**签到表设计**：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键自增 |
| user_id | INT | 用户ID（外键） |
| checkin_date | DATE | 签到日期 |
| consecutive_days | INT | 连续签到天数 |
| score_earned | INT | 本次签到获得积分 |
| created_at | DATETIME | 签到时间 |

#### 组员C（C）：采纳结算页面

**负责内容**：
- 需求详情页增加"去解决"按钮（登录用户可见）
- 需求详情页回复列表增加"采纳"确认交互
- 编辑文章页面显示作者当前积分

**涉及文件**：
```
src/main/webapp/demand/
  detail_content.jsp         # "去解决"按钮、采纳确认
src/main/webapp/post/
  edit_content.jsp           # 显示作者积分
```

#### 组员D（D）：需求积分流转

**负责内容**（已部分实现）：
- **发布需求扣分**：发布需求时从发布者 `users.score` 扣除对应积分，写入 `score_logs(-分)`
- **采纳回复加分**：采纳时给回复者 `users.score` 增加对应积分，写入 `score_logs(+分)`
- **积分排行榜**：`/score/rank` 按 `users.score` 降序排列
- **积分流水记录**：`/score/record` 展示当前用户的 `score_logs` 明细

**涉及文件**：
```
src/main/java/com/bbs/controller/
  DemandServlet.java         # 发布扣分、采纳加分
  ScoreServlet.java          # 排行榜、积分流水

src/main/webapp/score/
  rank_content.jsp           # 排行榜页面
  record_content.jsp         # 积分流水页面
```

### 11.3 数据库新增

**签到表（daily_checkins）—— 组员B负责**

```sql
CREATE TABLE IF NOT EXISTS daily_checkins (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    user_id           INT NOT NULL COMMENT '用户ID',
    checkin_date      DATE NOT NULL COMMENT '签到日期',
    consecutive_days  INT NOT NULL DEFAULT 1 COMMENT '连续签到天数',
    score_earned      INT NOT NULL DEFAULT 5 COMMENT '本次获得积分',
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uk_user_date (user_id, checkin_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日签到表';
```

### 11.4 新增URL路由

```
GET    /BBSForum/user/checkin                          签到接口（组员B）
```

### 11.5 工作量更新

```
组长（帖子核心+架构+创新+积分流转）：    *************************** 28%
组员C（板块+编辑+展示+采纳）：          *******************         19%
组员B（用户系统+签到+登录奖励）：        *******************         19%
组员D（需求+积分+排行榜）：              *******************         19%
组员A（置顶+加精+搜索+积分展示）：       ******************          15%
```
