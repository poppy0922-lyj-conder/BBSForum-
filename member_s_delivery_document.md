# 组长功能交付文档

## 概述

本文档描述了组长在BBS论坛系统中实现的核心功能模块，包括首页帖子列表与板块导航、帖子发布（含Markdown编辑器和图片上传）、帖子详情查看与回复、AI内容总结、用户互动系统（关注/点赞/收藏）、热度榜、帖子搜索、实时数据面板与热门标签等功能。这些功能构成了论坛系统的内容展示与交互核心。

## 功能模块

### 1. 首页 — 帖子列表与板块导航

**功能描述**：
- 首页展示所有帖子列表，按置顶优先 → 精华优先 → 时间倒序排列
- 顶部导航栏和左侧侧边栏展示板块分类，点击可筛选帖子
- 支持**分页**浏览，每页显示 20 条帖子，底部显示页码导航
- 每条帖子卡片显示：封面图、标题、摘要、标签（置顶/精华）、AI总结标识（仅登录用户可见）、关键词、作者、板块、浏览量、发布时间
- 板块列表缓存在 `ServletContext` 中全局共享，支持通过 `?refresh=1` 强制刷新

**相关文件**：
- `src/main/java/com/bbs/controller/HomeServlet.java` — 首页控制器（加载板块+帖子列表+分页）
- `src/main/java/com/bbs/controller/CategoryServlet.java` — 板块过滤控制器（按板块筛选+分页）
- `src/main/java/com/bbs/util/PostMapper.java` — 帖子数据映射工具类（统一 ResultSet → Map 转换）
- `src/main/webapp/index.jsp` — 入口页（转发到 `/index`）
- `src/main/webapp/WEB-INF/home.jsp` — 首页模板
- `src/main/webapp/layouts/main.jsp` — 全局布局（导航栏+侧边栏+右侧面板+内容区+页脚）
- `src/main/webapp/post/list.jsp` — 帖子列表卡片视图（含分页导航）
- `src/main/webapp/category/list.jsp` — 板块帖子页面模板

### 2. 发布帖子

**功能描述**：
- 已登录用户可点击"写文章"进入发帖页面
- 支持选择板块、输入标题、关键词、内容
- 编辑器提供 Markdown 工具栏：加粗、链接、插图
- 支持**本地上传封面图**（jpg/png/gif/webp，最大 5MB，UUID 重命名）
- 支持**内联图片上传**（编辑器内上传，自动插入 Markdown 语法 `![图片](url)`）
- 支持通过图片 URL 设置封面图（上传优先于 URL）
- 后端校验：标题和内容必填，板块必选
- 发帖成功后重定向到新帖详情页

**相关文件**：
- `src/main/java/com/bbs/controller/PostServlet.java` — 帖子控制器（`handleCreateForm`、`handleCreatePost`、`saveUploadedImage`、`handleInlineImageUpload`）
- `src/main/webapp/post/create.jsp` — 发帖页面模板
- `src/main/webapp/post/create_content.jsp` — 发帖表单视图（含 Markdown 编辑器和图片上传）

### 3. 帖子详情与回复

**功能描述**：
- 点击帖子卡片进入详情页，浏览量自动 +1
- 展示帖子完整信息：封面图、标题、关键词标签、作者、发布时间、浏览量、点赞数、收藏数
- 已登录用户在作者名旁可**关注/取消关注**作者
- 已登录用户可**点赞/取消点赞**（♥按钮，计数实时更新）
- 已登录用户可**收藏/取消收藏**（书签按钮，计数实时更新）
- 显示回复列表（按时间正序，含楼层号）
- 已登录用户可在底部发表回复
- 帖子作者或管理员可**编辑**帖子（修改标题、内容、关键词、封面图、板块）
- 帖子作者或管理员可**删除**帖子（级联删除回复）
- 管理员可对帖子进行**置顶**和**加精**操作（三步切换：无→板块置顶→全局置顶→取消）
- 右侧展示**相关推荐**：根据帖子关键词匹配或同板块兜底，最多推荐 5 篇

**相关文件**：
- `src/main/java/com/bbs/controller/PostServlet.java` — 帖子控制器（`handleDetail`、`handleReply`、`handleEditForm`、`handleEditPost`、`handleDelete`、`loadRelatedPosts`）
- `src/main/java/com/bbs/controller/InteractionServlet.java` — 交互控制器（关注/点赞/收藏）
- `src/main/webapp/post/detail.jsp` — 帖子详情页面模板
- `src/main/webapp/post/detail_content.jsp` — 帖子详情+回复列表+回复表单+相关推荐+互动按钮视图
- `src/main/webapp/post/edit.jsp` — 编辑帖子页面模板
- `src/main/webapp/post/edit_content.jsp` — 编辑帖子表单视图

### 4. 用户互动系统（关注/点赞/收藏）

**功能描述**：
- **关注用户**：帖子详情页作者名旁显示"+ 关注"按钮，点击后变为"已关注"
  - 不能关注自己
  - 个人中心新增"我的关注"页面，可查看所有已关注用户并一键取消关注
  - 所有操作通过 AJAX 异步完成，无需刷新页面
- **点赞帖子**：操作栏显示 ♥ 按钮及点赞数
  - 已登录用户可点赞/取消点赞
  - 计数实时更新（`posts.like_count` 维护）
  - 未登录用户不显示点赞按钮
- **收藏帖子**：操作栏显示书签按钮及收藏数
  - 已登录用户可收藏/取消收藏
  - 计数实时更新（`posts.favorite_count` 维护）

**相关文件**：
- `src/main/java/com/bbs/controller/InteractionServlet.java` — 交互控制器
- `src/main/webapp/post/detail_content.jsp` — 互动按钮HTML + JS逻辑
- `src/main/webapp/user/follows.jsp` — 关注列表页面模板
- `src/main/webapp/user/follows_content.jsp` — 关注列表视图（含取消关注）
- `src/main/webapp/user/profile.jsp` — 个人中心（含"我的关注"入口）

### 5. AI 内容总结

**功能描述**：
- 已登录用户在帖子详情页点击"AI 总结"按钮，异步调用硅基流动 API 生成 1-2 句中文总结
- 调用模型：`Qwen/Qwen2.5-7B-Instruct`
- 总结结果存入数据库 `posts.ai_summary` 字段，同时记录生成者 `ai_user_id`，避免重复调用
- **登录门控**：未登录用户无法看到 AI 总结结果，详情页 AI 总结框和首页 🤖 标识均对未登录用户隐藏
- 首页帖子列表中，已登录用户可以看到有 AI 总结的帖子显示 🤖 标识

**相关文件**：
- `src/main/java/com/bbs/controller/PostServlet.java` — 帖子控制器（`handleAiSummary`）
- `src/main/java/com/bbs/util/AiUtil.java` — AI 总结工具类（封装硅基流动 API 调用）
- `src/main/webapp/post/detail_content.jsp` — AI 总结框登录门控
- `src/main/webapp/post/list.jsp` — 首页 🤖 标识登录门控

### 6. 热度榜

**功能描述**：
- 独立页面，按浏览量（`view_count`）降序排列显示所有帖子
- 顶部导航栏"热度榜"按钮进入
- 每条帖子显示：排名序号、标题、浏览量
- 前三名分别显示金色/银色/铜色标签
- 置顶和精华帖子不影响热度榜排序，完全按浏览量

**相关文件**：
- `src/main/java/com/bbs/controller/HotServlet.java` — 热度榜控制器
- `src/main/webapp/WEB-INF/hot.jsp` — 热度榜页面模板
- `src/main/webapp/post/hot_content.jsp` — 热度榜列表视图

### 7. 实时数据面板与热门标签

**功能描述**：
- **右侧面板**：在支持侧边栏的页面显示
  - **上半部分**：实时数据面板，展示帖子总数、评论总数、用户总数、需求总数
  - **下半部分**：热门标签，从帖子关键词中聚合统计，显示使用频率最高的前 8 个标签
  - 数据通过 `StatsFilter` 缓存，15秒自动刷新
- **侧边栏导航**：积分排行、需求悬赏等入口

**相关文件**：
- `src/main/java/com/bbs/util/StatsFilter.java` — 数据统计过滤器（缓存+刷新机制）
- `src/main/webapp/layouts/main.jsp` — 实时数据面板+热门标签视图

### 9. v2.0 优化项

| 优化项 | 说明 |
|--------|------|
| **分页** | 首页和板块页支持 `?page=` 参数，每页 20 条，底部显示页码导航 |
| **参数校验** | `CategoryServlet` 增加 `NumberFormatException` 处理，防止非法参数导致 500 |
| **公共映射** | 新增 `PostMapper` 工具类，消除 ResultSet 映射重复代码 |
| **日志** | 所有 `printStackTrace()` 替换为 `java.util.logging.Logger`，记录中文日志 |
| **板块缓存** | 从 `session` 改为 `ServletContext` 全局共享，支持 `?refresh=1` 刷新 |
| **连接复用** | AI 总结方法复用同一个数据库连接，减少开销 |
| **AI 登录门控** | AI 总结结果和 🤖 图标仅登录用户可见，未登录自动隐藏 |
| **AI 用户追踪** | 新增 `ai_user_id` 字段记录生成 AI 总结的用户 |
| **安全配置** | 敏感信息（数据库密码、API密钥）抽取到 `config.properties`，加入 `.gitignore` |
| **全局布局改进** | 导航栏改为搜索+热度榜+登录，侧边栏添加描述文字，右侧面板实时数据 |
| **通知提示** | 操作成功/失败后 URL 参数传递 `?success=1`/`?error=1`，页面展示浮层通知 |

## API 端点说明

### 首页与板块 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/` `/index` `/home` | GET | 首页帖子列表 | `page`(可选,页码) `refresh`(可选,1=刷新缓存) | 首页 JSP |
| `/category` | GET | 按板块筛选帖子 | `id`(必填,板块ID) `page`(可选,页码) | 板块帖子列表 JSP |

### 帖子发布 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/post/create` | GET | 显示发帖表单 | 无（需登录） | 发帖表单 JSP |
| `/post/create` | POST | 提交新帖 | title, content, categoryId, keywords, coverImage(file), imageUrl | 重定向到新帖详情页 |
| `/post/uploadImage` | POST | 上传内联图片 | coverImage(file)（需登录） | JSON `{"markdown":"...","url":"..."}` |

### 帖子详情与交互 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/post/detail` | GET | 查看帖子详情 | `id`(必填,帖子ID) | 帖子详情 JSP |
| `/post/reply` | POST | 发表回复 | postId, content（需登录） | 重定向回详情页 |
| `/post/edit` | GET | 显示编辑表单 | `id`(必填)（需作者或管理员） | 编辑表单 JSP |
| `/post/edit` | POST | 保存编辑 | id, title, content, categoryId, keywords, coverImage, imageUrl | 重定向回详情页 |
| `/post/delete` | GET | 删除帖子 | `id`(必填)（需作者或管理员） | 重定向到首页 |
| `/post/aiSummary` | POST | 生成AI总结 | `id`(必填)（需登录） | JSON `{"summary":"..."}` 或 `{"error":"..."}` |

### 用户互动 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/interact/follow` | POST | 关注/取消关注 | userId（需登录） | JSON `{"ok":true,"action":"follow/unfollow"}` |
| `/interact/like` | POST | 点赞/取消点赞 | postId（需登录） | JSON `{"ok":true,"action":"like/unlike","count":N}` |
| `/interact/favorite` | POST | 收藏/取消收藏 | postId（需登录） | JSON `{"ok":true,"action":"favorite/unfavorite","count":N}` |

### 其他 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/hot` | GET | 热度榜 | 无 | 热度榜 JSP |
| `/post/search` | GET | 搜索帖子 | `keyword`(必填) `page`(可选) | 搜索结果 JSP |

### 关注列表（个人中心）

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/user/profile/follows` | GET | 查看关注列表 | 无（需登录） | 关注列表 JSP |

## 数据库表结构

### posts 表

```sql
CREATE TABLE posts (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(100) NOT NULL COMMENT '标题',
    content         TEXT NOT NULL COMMENT '内容',
    image_url       VARCHAR(500) DEFAULT '' COMMENT '封面图片URL',
    user_id         INT NOT NULL COMMENT '作者ID',
    category_id     INT NOT NULL COMMENT '所属板块ID',
    is_top          TINYINT DEFAULT 0 COMMENT '是否置顶 0=否 1=板块置顶 2=全局置顶',
    is_elite        TINYINT DEFAULT 0 COMMENT '是否加精 0=否 1=是',
    ai_summary      TEXT DEFAULT NULL COMMENT 'AI生成的内容总结',
    ai_user_id      INT DEFAULT NULL COMMENT 'AI总结生成者ID',
    keywords        VARCHAR(200) DEFAULT '' COMMENT '关键词，逗号分隔',
    like_count      INT DEFAULT 0 COMMENT '点赞数',
    favorite_count  INT DEFAULT 0 COMMENT '收藏数',
    view_count      INT DEFAULT 0 COMMENT '浏览次数',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

### replies 表

```sql
CREATE TABLE replies (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    content     TEXT NOT NULL COMMENT '回复内容',
    user_id     INT NOT NULL COMMENT '回复者ID',
    post_id     INT NOT NULL COMMENT '所属帖子ID',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
```

### user_follows 表（组长新增）

```sql
CREATE TABLE user_follows (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    user_id           INT NOT NULL COMMENT '关注者ID',
    followed_user_id  INT NOT NULL COMMENT '被关注者ID',
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (followed_user_id) REFERENCES users(id)
);
```

### post_likes 表（组长新增）

```sql
CREATE TABLE post_likes (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL COMMENT '点赞者ID',
    post_id     INT NOT NULL COMMENT '帖子ID',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
```

### post_favorites 表（组长新增）

```sql
CREATE TABLE post_favorites (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL COMMENT '收藏者ID',
    post_id     INT NOT NULL COMMENT '帖子ID',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
```

## 前端集成说明

### 1. 全局布局 (main.jsp)

所有页面通过 `layouts/main.jsp` 统一渲染，各页面只需设置相关变量：

```jsp
<c:set var="pageTitle" value="首页" scope="request" />
<c:set var="contentPage" value="/post/list.jsp" scope="request" />
<c:set var="showSidebar" value="true" scope="request" />
<jsp:include page="/layouts/main.jsp" />
```

布局包含（条件判断 `showSidebar` 控制是否显示左右侧栏）：
- **顶部导航**：Logo、搜索框、热度榜按钮、登录/用户状态（头像+用户名+管理链接+我的+退出）
- **左侧侧边栏**：全部帖子（静态高亮）、板块列表（带描述）、创作中心（写文章/发布悬赏）、热门推荐（积分排行/需求悬赏）
- **右侧面板**（仅 `showSidebar=true` 时显示）：实时数据面板（帖子数/评论数/用户数/需求数）、热门标签
- **中间内容区**：`<jsp:include page="${contentPage}" />` 动态加载内容页
- **通知提示**：URL 参数 `?success=1`/`?error=1` 自动展示成功/失败浮层

### 2. 帖子列表卡片

每张帖子卡片包含封面图、标题、标签、摘要、关键词、作者信息、浏览量和发布时间，点击跳转到详情页：

```jsp
<article class="bg-white rounded-lg shadow-sm hover:shadow-md ..."
    onclick="location.href='${pageContext.request.contextPath}/post/detail?id=${post.id}'">
```

### 3. Markdown 编辑器

发帖和编辑页面提供简易 Markdown 工具栏：

```jsp
<button type="button" onclick="insertMarkdown('**', '**')">加粗</button>
<button type="button" onclick="insertMarkdown('[', '](url)')">链接</button>
<button type="button" id="inlineUploadBtn">插图</button>
```

内联图片上传通过 `fetch` + `FormData` 异步提交到 `/post/uploadImage`，返回 Markdown 语法后自动插入文本框。

### 4. 分页导航

首页和板块页底部显示分页控件，包含"上一页"、页码列表、"下一页"和总帖数统计。使用 JSTL 根据 `currentPage`、`totalPages`、`totalPosts` 动态生成。

### 5. AI 总结按钮（需登录）

帖子详情页的 AI 总结功能通过异步请求实现，未登录用户点击按钮会弹出提示"请先登录后再使用AI总结功能"：

```javascript
function generateAiSummary(postId) {
    fetch('/BBSForum/post/aiSummary', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'id=' + postId
    })
    .then(r => r.json())
    .then(data => { /* 显示总结或错误提示 */ });
}
```

### 6. 互动按钮（关注/点赞/收藏）

- **关注按钮**：帖子详情页作者名旁显示，AJAX 异步切换关注/取消关注状态
- **点赞按钮**：操作栏红色 ♥ 按钮，点击切换实心/空心，计数实时更新
- **收藏按钮**：操作栏黄色书签按钮，点击切换实心/空心，计数实时更新
- 所有互动通过 `fetch` 异步调用 `/interact/*` 端点，无需刷新页面

```javascript
function toggleLike(postId, btn) {
    fetch('/BBSForum/interact/like', { method: 'POST', body: 'postId=' + postId })
    .then(r => r.json())
    .then(data => {
        // 更新图标样式（实心/空心）和计数
        if (data.action === 'like') { /* 红色实心 */ }
        else { /* 灰色空心 */ }
        countSpan.textContent = data.count;
    });
}
```

## 使用示例

### 1. 访问首页

浏览器访问 `http://localhost:8088/BBSForum/`，自动跳转到首页，展示帖子列表和板块导航。

### 2. 发布新帖

1. 登录后点击"写文章"
2. 选择板块、输入标题和内容（支持 Markdown）
3. 可选上传封面图和填写关键词
4. 点击"发布"
5. 自动跳转到新帖详情页

### 3. 查看帖子并互动

1. 点击任意帖子卡片进入详情页
2. 查看帖子内容和已有回复
3. 点击作者名旁 **"+ 关注"** 关注作者
4. 点击 **♥ 按钮** 点赞帖子（计数实时更新）
5. 点击 **书签按钮** 收藏帖子（计数实时更新）
6. 在底部输入框填写回复内容，点击"提交回复"

### 4. 查看关注列表

1. 点击顶部导航栏"我的"
2. 进入个人中心，点击"我的关注"
3. 查看所有已关注的用户列表
4. 点击"取消关注"可移除关注

### 5. 生成 AI 总结

1. 进入任意帖子详情页
2. 点击"AI 总结"按钮
3. 等待 2-5 秒，总结内容出现在帖子顶部

### 6. 浏览热度榜

1. 点击顶部导航栏"热度榜"
2. 查看按浏览量排名的帖子列表
3. 前三名分别有金/银/铜色标记

### 7. 搜索帖子

1. 顶部导航栏搜索框输入关键词
2. 按回车或点击搜索按钮
3. 搜索结果分页展示，支持翻页

## 依赖关系

### 对其他成员的影响

1. **对成员B (用户系统)**：
   - 发帖、回复、编辑、删除、AI 总结、关注/点赞/收藏等操作依赖 `sessionScope.user` 判断登录态
   - 导航栏登录/用户状态依赖成员B提供的 session 结构
   - 关注列表页面 (`/user/profile/follows`) 集成在个人中心模块中

2. **对成员C (板块管理)**：
   - 板块列表缓存使用 `ServletContext` 存储，管理员修改板块后需访问 `?refresh=1` 刷新缓存
   - 首页和导航栏展示的板块列表来自 `categories` 表，依赖成员C维护数据
   - 搜索功能（组员A负责）同样使用板块列表展示

3. **对成员A (置顶/加精/搜索)**：
   - 帖子搜索功能（组员A负责）依赖 `posts` 表的标题和内容字段进行 LIKE 匹配
   - 搜索框位于顶部导航栏（组长搭建的布局中），搜索结果复用首页帖子列表模板

4. **对成员D (需求悬赏/积分)**：
   - 发帖表单的板块选择下拉框使用 `applicationScope.categoryList`
   - 回复功能与帖子的 `user_id` 关联
   - 统计面板中的需求总数依赖 `demands` 表

### 外部依赖

- **硅基流动 API**：AI 总结功能依赖外部 API（`api.siliconflow.cn`），需要网络连通
- **MySQL 数据库**：所有功能依赖 `posts`、`replies`、`categories`、`users`、`user_follows`、`post_likes`、`post_favorites` 表
- **上传目录**：图片上传存储在 `src/main/webapp/uploads/` 目录

## 测试建议

### 1. 首页测试
- 访问首页查看帖子列表是否正常加载
- 测试分页功能：点击页码、上一页、下一页
- 测试板块筛选：点击不同板块查看帖子是否过滤正确
- 测试空状态：数据库无帖子时显示"还没有帖子"提示

### 2. 发帖测试
- 测试正常发帖（含封面图上传）
- 测试 Markdown 编辑器工具栏
- 测试内联图片上传
- 测试必填项校验（空标题、空内容）
- 测试未登录用户点击发帖被拦截

### 3. 详情与互动测试
- 测试帖子详情页正常显示
- 测试浏览量递增
- 测试关注/取消关注作者（不能关注自己）
- 测试点赞/取消点赞（计数实时更新）
- 测试收藏/取消收藏（计数实时更新）
- 测试发表回复
- 测试空回复拦截
- 测试相关推荐展示

### 4. 编辑与删除测试
- 测试帖子作者编辑自己的帖子
- 测试管理员编辑他人帖子
- 测试非作者/非管理员编辑被拦截
- 测试删除帖子（级联删除回复）

### 5. AI 总结测试
- 测试生成 AI 总结
- 测试未登录用户点击被拦截
- 测试网络断开时的错误提示

### 6. 热度榜测试
- 测试热度榜按浏览量排序
- 测试前三名颜色标记
- 测试空数据状态

### 7. 搜索测试
- 测试关键词搜索
- 测试搜索结果分页
- 测试无结果提示
- 测试空关键词跳转

### 8. 分页测试
- 测试第 1 页正常显示
- 测试超出范围的页码自动修正
- 测试板块页分页与首页分页独立

## 注意事项

1. **板块缓存**：板块列表使用 `ServletContext` 存储，应用重启后自动重新加载。管理员增删改板块后，需在 URL 后加 `?refresh=1` 手动刷新缓存。
2. **分页参数**：所有分页使用 `LIMIT ? OFFSET ?` 预编译语句，防止 SQL 注入。页码超出范围时自动修正到有效值。
3. **图片上传**：上传目录为 `src/main/webapp/uploads/`，文件使用 UUID 重命名防止冲突。仅允许 jpg/png/gif/webp 格式，最大 5MB。
4. **Markdown 渲染**：详情页使用 `ContentUtil.render()` 将 Markdown 转为 HTML，首页列表使用 `ContentUtil.summary()` 生成纯文本摘要。注意 XSS 防护，用户输入内容需经过 `escapeHtml()` 处理。
5. **AI 总结**：调用外部 API 可能耗时 2-5 秒，前端使用异步请求防止阻塞。API 调用失败时返回友好错误提示，不影响页面其他功能。
6. **编码**：全部使用 UTF-8 编码，通过 `EncodingFilter` 统一处理。
7. **安全配置**：敏感信息（数据库密码 `db.password`、API密钥 `ai.api.key`）统一存放在 `config.properties` 中，此文件已加入 `.gitignore`，不上传到远程仓库。其他开发者使用 `config.properties.template` 填入自己的配置。
8. **互动操作**：关注/点赞/收藏均为 AJAX 异步请求，无页面刷新。所有互动操作需要登录状态，未登录时按钮不显示。
