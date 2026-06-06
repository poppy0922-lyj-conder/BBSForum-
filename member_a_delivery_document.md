# 组长功能交付文档

## 概述

本文档描述了组长在BBS论坛系统中实现的核心功能模块，包括首页帖子列表与板块导航、帖子发布（含Markdown编辑器和图片上传）、帖子详情查看与回复、以及AI内容总结功能。这些功能构成了论坛系统的内容展示与交互核心。

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
- `src/main/webapp/layouts/main.jsp` — 全局布局（导航栏+侧边栏+内容区+页脚）
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
- 展示帖子完整信息：封面图、标题、关键词标签、作者、发布时间、浏览量、已渲染的 Markdown 内容
- 显示回复列表（按时间正序，含楼层号）
- 已登录用户可在底部发表回复
- 帖子作者或管理员可**编辑**帖子（修改标题、内容、关键词、封面图、板块）
- 帖子作者或管理员可**删除**帖子（级联删除回复）
- 管理员可对帖子进行**置顶**和**加精**操作
- 右侧展示**相关推荐**：根据帖子关键词匹配或同板块兜底，最多推荐 5 篇

**相关文件**：
- `src/main/java/com/bbs/controller/PostServlet.java` — 帖子控制器（`handleDetail`、`handleReply`、`handleEditForm`、`handleEditPost`、`handleDelete`、`loadRelatedPosts`）
- `src/main/webapp/post/detail.jsp` — 帖子详情页面模板
- `src/main/webapp/post/detail_content.jsp` — 帖子详情+回复列表+回复表单+相关推荐视图
- `src/main/webapp/post/edit.jsp` — 编辑帖子页面模板
- `src/main/webapp/post/edit_content.jsp` — 编辑帖子表单视图

### 4. AI 内容总结

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

### 5. Markdown 渲染与内容处理

**功能描述**：
- `ContentUtil` 工具类提供 Markdown → HTML 渲染（详情页使用）
- 支持语法：`![alt](url)` → `<img>`、`[text](url)` → `<a>`、`**bold**` → `<strong>`、空行分段
- 提供纯文本摘要生成（首页列表使用）：去除 Markdown 标记，截取前 120 字符
- 提供 HTML 转义：防止 XSS 攻击

**相关文件**：
- `src/main/java/com/bbs/util/ContentUtil.java` — 内容渲染工具类

### 6. v2.0 优化项

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

## 数据库表结构

### posts 表

```sql
CREATE TABLE posts (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(100) NOT NULL COMMENT '标题',
    content     TEXT NOT NULL COMMENT '内容',
    image_url   VARCHAR(500) DEFAULT '' COMMENT '封面图片URL',
    user_id     INT NOT NULL COMMENT '作者ID',
    category_id INT NOT NULL COMMENT '所属板块ID',
    is_top      TINYINT DEFAULT 0 COMMENT '是否置顶 0=否 1=板块置顶 2=全局置顶',
    is_elite    TINYINT DEFAULT 0 COMMENT '是否加精 0=否 1=是',
    ai_summary  TEXT DEFAULT NULL COMMENT 'AI生成的内容总结',
    ai_user_id  INT DEFAULT NULL COMMENT 'AI总结生成者ID',
    keywords    VARCHAR(200) DEFAULT '' COMMENT '关键词，逗号分隔',
    view_count  INT DEFAULT 0 COMMENT '浏览次数',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
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

### categories 表

```sql
CREATE TABLE categories (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL COMMENT '板块名称',
    description VARCHAR(200) DEFAULT '' COMMENT '板块描述',
    sort_order  INT DEFAULT 0 COMMENT '排序权重',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
);
```

## 前端集成说明

### 1. 全局布局 (main.jsp)

所有页面通过 `layouts/main.jsp` 统一渲染，各页面只需设置两个变量：

```jsp
<c:set var="pageTitle" value="首页" scope="request" />
<c:set var="contentPage" value="/post/list.jsp" scope="request" />
<jsp:include page="/layouts/main.jsp" />
```

布局包含：
- **顶部导航**：Logo、板块链接（从 `applicationScope.categoryList` 循环渲染）、搜索框、登录/用户状态
- **左侧侧边栏**：板块列表、创作中心（写文章/发布悬赏）、热门推荐（积分排行/需求悬赏）
- **中间内容区**：`<jsp:include page="${contentPage}" />` 动态加载内容页

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

## 使用示例

### 1. 访问首页

浏览器访问 `http://localhost:8088/BBSForum/`，自动跳转到首页，展示帖子列表和板块导航。

### 2. 发布新帖

1. 登录后点击"写文章"
2. 选择板块、输入标题和内容（支持 Markdown）
3. 可选上传封面图和填写关键词
4. 点击"发布"
5. 自动跳转到新帖详情页

### 3. 查看帖子并回复

1. 点击任意帖子卡片进入详情页
2. 查看帖子内容和已有回复
3. 在底部输入框填写回复内容
4. 点击"提交回复"

### 4. 生成 AI 总结

1. 进入任意帖子详情页
2. 点击"AI 总结"按钮
3. 等待 2-5 秒，总结内容出现在帖子顶部

## 依赖关系

### 对其他成员的影响

1. **对成员B (Member B - 用户系统)**：
   - 发帖、回复、编辑、删除、AI 总结等操作依赖 `sessionScope.user` 判断登录态
   - 导航栏登录/用户状态依赖成员B提供的 session 结构
   - 管理员操作的权限判断依赖 `user.role == 'admin'`

2. **对成员C (Member C - 板块管理)**：
   - 板块列表缓存使用 `ServletContext` 存储，管理员修改板块后需访问 `?refresh=1` 刷新缓存
   - 首页和导航栏展示的板块列表来自 `categories` 表，依赖成员C维护数据

3. **对成员D (Member D - 需求悬赏/积分)**：
   - 发帖表单的板块选择下拉框使用 `applicationScope.categoryList`
   - 回复功能与帖子的 `user_id` 关联

### 外部依赖

- **硅基流动 API**：AI 总结功能依赖外部 API（`api.siliconflow.cn`），需要网络连通
- **MySQL 数据库**：所有功能依赖 `posts`、`replies`、`categories`、`users` 表
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

### 3. 详情与回复测试
- 测试帖子详情页正常显示
- 测试浏览量递增
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

### 6. 分页测试
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
