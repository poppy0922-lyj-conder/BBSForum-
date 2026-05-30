# BBS论坛系统

基于 Jakarta Servlet 5.0 + JSP + MySQL 的 BBS 技术社区，五人团队协作项目。

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 后端 | Jakarta Servlet + JSP + JSTL | 5.0 / 3.1 / 2.0 (GlassFish) |
| 数据库 | MySQL | 8.0+ |
| 前端 | Tailwind CSS (CDN) + Font Awesome | 4.7.0 |
| 构建 | Maven (WAR + 可执行 JAR) | 3.6+ |
| 服务器 | 嵌入式 Tomcat (embed-core) | 10.1.52 |
| JDK | Java 11+ | 实际运行 Java 21 |

## 项目结构

```
BBSForum/
├── pom.xml
├── README.md
├── database/
│   └── init.sql                         # 建库建表 + 初始数据
└── src/main/
    ├── java/com/bbs/
    │   ├── Main.java                    # 唯一启动入口（嵌入式Tomcat）
    │   ├── controller/
    │   │   └── HomeServlet.java         # 首页（加载板块+帖子列表）
    │   └── util/
    │       ├── DBUtil.java              # 数据库连接
    │       └── EncodingFilter.java      # UTF-8编码过滤器
    └── webapp/
        ├── index.jsp                    # 自动转发到 /index
        ├── WEB-INF/
        │   ├── web.xml                  # Servlet 5.0 配置
        │   └── home.jsp                 # 首页模板（受保护）
        ├── layouts/
        │   └── main.jsp                 # 公共布局（导航+侧栏+页脚）
        ├── post/
        │   ├── list.jsp                 # 帖子列表卡片
        │   ├── create.jsp / create_content.jsp
        │   ├── detail.jsp / detail_content.jsp
        │   └── edit.jsp / edit_content.jsp
        ├── user/
        │   ├── login.jsp / login_content.jsp
        │   ├── register.jsp / register_content.jsp
        │   ├── profile.jsp / profile_content.jsp
        │   └── profile_edit.jsp / profile_edit_content.jsp
        ├── admin/
        │   ├── index.jsp / index_content.jsp
        │   ├── categories.jsp / categories_content.jsp
        │   └── post_manage.jsp / post_manage_content.jsp
        ├── demand/
        │   ├── list.jsp / list_content.jsp
        │   ├── create.jsp / create_content.jsp
        │   └── detail.jsp / detail_content.jsp
        ├── score/
        │   ├── record.jsp / record_content.jsp
        │   └── rank.jsp / rank_content.jsp
        ├── category/
        │   └── list.jsp
        └── error/
            ├── 404.jsp
            └── 500.jsp
```

## 快速开始

### 1. 初始化数据库

确保 MySQL 服务已启动，然后执行：

```bash
mysql -u root -p < database/init.sql
```

默认创建 `bbs_forum` 数据库，包含 6 张表、4 个板块、默认账号。

### 2. 修改数据库密码

编辑 `src/main/java/com/bbs/util/DBUtil.java`，将密码改为你的 MySQL 密码：

```java
private static final String DB_PASS = "你的密码";
```

### 3. 编译

```bash
mvnw clean compile
```

编译后 `target/classes` 目录会生成 `.class` 文件，供嵌入式 Tomcat 加载。

### 4. 启动

在 IDE 中右键 `src/main/java/com/bbs/Main.java` → **Run 'Main'**。

```
==========================================
  BBS技术社区 启动成功！
  http://localhost:8088/BBSForum/
==========================================
```

> 嵌入式 Tomcat 自动从当前目录向上查找 `src/main/webapp`，因此必须在 IDE 中运行，不要直接 `java -jar`。

### 5. 访问

浏览器打开 `http://localhost:8088/BBSForum/`

| 账号 | 密码 | 角色 |
|------|------|------|
| admin | admin123 | 管理员 |
| test | test123 | 普通用户 |

## 页面路由

| URL | 页面 | 负责成员 |
|-----|------|----------|
| `/` 或 `/index` | 首页（帖子列表+板块导航） | 组长 |
| `/post/create` | 发布帖子 | 组长 |
| `/post/detail?id=` | 帖子详情+回复 | 组长 |
| `/post/edit?id=` | 编辑帖子 | 组员C |
| `/user/login` | 登录 | 组员B |
| `/user/register` | 注册 | 组员B |
| `/user/profile` | 个人中心 | 组员B |
| `/user/profile/edit` | 编辑资料 | 组员B |
| `/admin` | 管理员后台 | 组员C |
| `/admin/categories` | 板块管理 | 组员C |
| `/admin/post/manage` | 帖子管理（置顶/加精） | 组员A |
| `/post/search?keyword=` | 帖子搜索 | 组员A |
| `/demand` | 需求列表 | 组员D |
| `/demand/create` | 发布需求 | 组员D |
| `/demand/detail?id=` | 需求详情 | 组员D |
| `/score` | 积分记录 | 组员D |
| `/score/rank` | 积分排行 | 组员D |

## 模块分工

| 成员 | 模块 | 占比 |
|------|------|------|
| 组长 | 帖子核心CRUD + 公共布局 + 首页 | 22% |
| 组员A | 帖子置顶/加精/搜索 | 20% |
| 组员B | 用户注册/登录/个人中心 | 19% |
| 组员C | 板块管理 + 帖子编辑 + 分板块展示 | 21% |
| 组员D | 需求悬赏 + 积分系统 | 19% |

## 数据库表

| 表名 | 说明 | 负责 |
|------|------|------|
| users | 用户表（用户名/密码/联系方式/角色） | 组员B |
| categories | 板块表（名称/描述/排序） | 组员C |
| posts | 帖子表（标题/内容/封面图/置顶/加精/浏览数） | 组长 |
| replies | 回复表（内容/所属帖子） | 组长 |
| demands | 需求表（标题/内容/悬赏积分/状态/最佳回复） | 组员D |
| score_logs | 积分流水表（积分变动/原因） | 组员D |

## 前端说明

- 使用 **Tailwind CSS CDN** 实现现代化界面，无需编译步骤
- 帖子卡片采用左图右文布局（220×128px 封面图）
- 封面图字段 `image_url`：有值显示图片，无值显示渐变占位块
- 图片加载失败时自动回退到占位块（`onerror` 处理）
- 导航栏包含首页、技术交流、生活杂谈、求职招聘、需求悬赏入口

## 开发规范

- 缩进：2 空格
- Java 命名：驼峰（`PostServlet.java`）
- JSP 命名：小写+下划线（`login_content.jsp`）
- 每个模块采用 `xxx.jsp`（外壳）+ `xxx_content.jsp`（内容）的拆分方式
- 列表数据通过 Servlet 查询后放入 `request.setAttribute`，JSP 用 JSTL 渲染
- 页面放在 `src/main/webapp/` 下可直接访问，核心模板放在 `WEB-INF/` 下受保护
- JSTL 标签 URI：`http://java.sun.com/jsp/jstl/core`（GlassFish JSTL 2.0 要求）
- 每人一个 Git 分支：`feature/模块名`
