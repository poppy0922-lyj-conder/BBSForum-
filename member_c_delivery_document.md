# 成员C功能交付文档

## 概述

本文档描述了成员C在BBS论坛系统中实现的功能，包括板块管理、帖子编辑、分板块展示功能，以及管理员后台的全面增强（用户管理模块、帖子搜索与排序、可交互数据图表、UI优化）。

## 功能模块

### 1. 板块管理 (Category Management)

**功能描述**：
- 管理员可以创建、编辑、删除论坛板块
- 板块信息包括名称、描述和排序顺序
- 板块列表在首页侧边栏显示，供用户浏览

**相关文件**：
- `src/main/java/com/bbs/controller/AdminCategoryServlet.java` - 后端控制器
- `src/main/webapp/admin/categories.jsp` - 管理页面
- `src/main/webapp/admin/categories_content.jsp` - 管理内容页面

### 2. 分板块展示 (Section-based Display)

**功能描述**：
- 用户可以按板块浏览帖子
- 每个板块显示该板块下的帖子列表
- 板块名称在帖子列表页头显示

**相关文件**：
- `src/main/java/com/bbs/controller/CategoryServlet.java` - 后端控制器
- `src/main/webapp/category/list.jsp` - 板块帖子列表页面
- `src/main/webapp/post/list.jsp` - 帖子列表渲染

### 3. 帖子编辑 (Post Editing)

**功能描述**：
- 帖子作者可以编辑自己的帖子
- 管理员可以编辑任何帖子
- 支持帖子标题、内容和板块的修改

**相关文件**：
- `src/main/java/com/bbs/controller/PostEditServlet.java` - 后端控制器
- `src/main/webapp/post/edit.jsp` - 编辑页面
- `src/main/webapp/post/edit_content.jsp` - 编辑内容页面

### 4. 用户管理模块 (User Management) — 新增

**功能描述**：
- 管理员可以查看所有用户列表，支持分页（每页20条）和按用户名搜索
- 管理员可以编辑用户信息（联系方式、工作性质、工作地点、角色、积分）
- 管理员可以切换用户角色（普通用户 ↔ 管理员）
- 管理员可以删除用户（需确认，且不能删除自己或有帖子的用户）
- 当前登录管理员的行不显示操作按钮

**相关文件**：
- `src/main/java/com/bbs/controller/AdminUserServlet.java` - 后端控制器
- `src/main/webapp/admin/users.jsp` - 用户列表页面
- `src/main/webapp/admin/users_content.jsp` - 用户列表内容
- `src/main/webapp/admin/user_edit.jsp` - 用户编辑页面
- `src/main/webapp/admin/user_edit_content.jsp` - 用户编辑表单

### 5. 帖子管理增强 — 搜索与排序

**功能描述**：
- 管理员可以在帖子管理页面按标题/内容关键词搜索
- 管理员可以按作者名搜索帖子
- 管理员可以按板块筛选帖子
- 支持按帖子ID升序/降序排序（默认升序）
- 分页和搜索状态在翻页时保持

**相关文件**：
- `src/main/java/com/bbs/controller/AdminPostServlet.java` - 修改：新增 keyword/author/categoryId/sort 参数处理
- `src/main/webapp/admin/post_manage_content.jsp` - 修改：新增搜索栏、作者输入框、板块下拉框、排序切换按钮

### 6. 管理员仪表盘可交互图表

**功能描述**：
- 各板块帖子统计：环形图（doughnut）展示各板块帖子数量分布，带数据标签（数量和百分比）
- 近30天每日发帖量：折线图展示每日发帖趋势
- 近7天用户注册量：折线图展示每日注册趋势
- 数据通过 AJAX 从 JSON API 实时加载，使用 Chart.js 4 渲染

**相关文件**：
- `src/main/java/com/bbs/controller/AdminDashboardServlet.java` - 新增：图表数据 JSON 接口
- `src/main/webapp/admin/index_content.jsp` - 修改：替换统计卡片为交互式图表

### 7. 管理员后台 UI 优化

**功能描述**：
- 管理后台左上角新增"返回首页"按钮，方便管理员快速返回前台
- 底部版权信息固定在页面底部（使用 flex 布局），内容不足时不会漂浮在中间
- 管理后台侧边栏新增"用户管理"导航项

**相关文件**：
- `src/main/webapp/layouts/main.jsp` - 修改：body 使用 flex 布局，新增返回首页按钮，侧边栏新增用户管理入口


## API 端点说明

### 板块管理 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/admin/categories` | GET | 显示板块列表 | 无 | 板块列表 |
| `/admin/categories/add` | POST | 添加新板块 | name, description | 重定向到板块列表 |
| `/admin/categories/edit` | GET | 显示编辑表单 | id | 编辑表单 |
| `/admin/categories/edit` | POST | 更新板块 | id, name, description | 重定向到板块列表 |
| `/admin/categories/delete` | POST | 删除板块 | id | 重定向到板块列表 |

### 板块展示 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/category` | GET | 显示指定板块的帖子 | id (板块ID) | 帖子列表 |

### 帖子编辑 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/post/edit` | GET | 显示编辑表单 | id (帖子ID) | 编辑表单 |
| `/post/edit` | POST | 保存帖子修改 | id, title, content, categoryId | 重定向到帖子详情 |
| `/post/delete` | POST | 删除帖子 | id (帖子ID) | 重定向到首页 |

### 用户管理 API（新增）

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/admin/users` | GET | 用户列表（分页+搜索） | page, keyword | 用户列表页面 |
| `/admin/users/edit` | GET | 显示编辑表单 | id | 编辑表单 |
| `/admin/users/edit` | POST | 保存用户修改 | id, phone, jobType, jobLocation, role, score | 重定向到用户列表 |
| `/admin/users/toggleRole` | POST | 切换用户角色 | id | 重定向到用户列表 |
| `/admin/users/delete` | POST | 删除用户 | id | 重定向到用户列表 |

### 帖子管理增强 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/admin/post/manage` | GET | 帖子列表（分页+搜索+排序） | page, keyword, author, categoryId, sort | 帖子列表页面 |

### 仪表盘图表数据 API

| URL | 方法 | 功能 | 返回 |
|-----|------|------|------|
| `/admin/chart/postsByCategory` | GET | 各板块帖子统计 | JSON {labels, data} |
| `/admin/chart/dailyPosts` | GET | 近30天每日发帖量 | JSON {labels, data} |
| `/admin/chart/userGrowth` | GET | 近7天用户注册量 | JSON {labels, data} |

## 数据库表结构

### categories 表

```sql
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200) DEFAULT '',
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**字段说明**：
- `id`: 板块唯一标识
- `name`: 板块名称
- `description`: 板块描述
- `sort_order`: 排序顺序
- `created_at`: 创建时间


## 新增/修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `src/main/java/com/bbs/controller/AdminUserServlet.java` | 新增 | 用户管理控制器 |
| `src/main/java/com/bbs/controller/AdminDashboardServlet.java` | 新增 | 仪表盘图表数据 API |
| `src/main/java/com/bbs/controller/AdminPostServlet.java` | 修改 | 新增搜索/排序/作者筛选 |
| `src/main/java/com/bbs/util/PostMapper.java` | 修改 | 新增 mapUserRow() 方法 |
| `src/main/webapp/admin/users.jsp` | 新增 | 用户管理列表页 |
| `src/main/webapp/admin/users_content.jsp` | 新增 | 用户管理列表内容 |
| `src/main/webapp/admin/user_edit.jsp` | 新增 | 用户编辑页 |
| `src/main/webapp/admin/user_edit_content.jsp` | 新增 | 用户编辑表单 |
| `src/main/webapp/admin/post_manage_content.jsp` | 修改 | 新增搜索栏和排序按钮 |
| `src/main/webapp/admin/index_content.jsp` | 修改 | 新增交互式图表 |
| `src/main/webapp/layouts/main.jsp` | 修改 | 返回首页按钮、用户管理入口、底部固定 |
| `database/init.sql` | 修改 | 新增列和表定义 |

## 前端集成说明

### 1. 板块显示

在首页和帖子页面，板块列表通过以下方式加载：

```jsp
<c:forEach var="cat" items="${applicationScope.categoryList}">
    <a href="${pageContext.request.contextPath}/category?id=${cat.id}">${cat.name}</a>
</c:forEach>
```

### 2. 帖子编辑表单

编辑页面包含板块选择下拉框：

```jsp
<select name="categoryId" id="categoryId" class="form-select" required>
    <c:forEach var="cat" items="${sessionScope.categoryList}">
        <option value="${cat.id}" ${cat.id == post.categoryId ? 'selected' : ''}>${cat.name}</option>
    </c:forEach>
</select>
```

### 3. 管理后台图表

图表通过 AJAX 从 JSON API 加载，使用 Chart.js 4 渲染：

```javascript
fetch(ctx + '/admin/chart/postsByCategory')
    .then(function(r) { return r.json(); })
    .then(function(d) {
        new Chart(document.getElementById('chartCategory'), {
            type: 'doughnut',
            data: { labels: d.labels, datasets: [{ data: d.data, backgroundColor: colors }] },
            options: { cutout: '55%' }
        });
    });
```

## 使用示例

### 1. 添加新板块

**管理员操作**：
1. 访问 `/admin/categories`
2. 填写板块名称和描述
3. 点击"添加"按钮

### 2. 浏览技术交流板块

**用户操作**：
1. 访问 `/category?id=1`（假设技术交流板块ID为1）
2. 查看该板块下的所有帖子

### 3. 编辑帖子

**作者操作**：
1. 访问 `/post/edit?id=123`（帖子ID为123）
2. 修改标题、内容和板块
3. 点击"保存修改"

### 4. 管理用户

**管理员操作**：
1. 访问 `/admin/users`
2. 可搜索用户名、查看用户列表
3. 点击"编辑"修改用户信息（联系方式、角色、积分等）
4. 点击角色按钮切换用户角色（普通用户 ↔ 管理员）
5. 点击删除按钮删除用户（需确认，不能删除自己）

### 5. 管理帖子（搜索与排序）

**管理员操作**：
1. 访问 `/admin/post/manage`
2. 在搜索栏输入关键词（标题/内容）、作者名、选择板块
3. 点击升序/降序按钮切换排序方式
4. 使用分页控件浏览更多帖子

## 依赖关系

### 对其他成员的影响

1. **对组长 (Team Leader)**：
   - 需要确保 `categories`、`post_likes`、`post_favorites`、`user_follows` 表已创建
   - 需要在首页加载板块列表到 `applicationScope`
   - posts 表新增了 `like_count` 和 `favorite_count` 字段

2. **对成员A (Member A)**：
   - 帖子置顶/加精功能需要板块信息
   - 搜索功能需要按板块过滤（已在 AdminPostServlet 中实现）
   - 帖子详情页现在能正确显示点赞数和收藏数

3. **对成员B (Member B)**：
   - 用户注册/登录功能不受影响
   - 个人中心需要显示用户发布的帖子所属板块

4. **对成员D (Member D)**：
   - 需求悬赏功能需要选择板块
   - 积分系统不受直接影响

## 测试建议

### 1. 板块管理测试
- 测试添加新板块功能
- 测试编辑板块功能
- 测试删除板块功能
- 验证板块列表正确显示

### 2. 板块展示测试
- 测试按板块浏览帖子
- 验证板块名称正确显示
- 测试空板块显示

### 3. 帖子编辑测试
- 测试作者编辑自己的帖子
- 测试管理员编辑任意帖子
- 验证帖子内容更新
- 测试板块切换功能

### 4. 用户管理测试
- 测试用户列表分页功能
- 测试按用户名搜索
- 测试编辑用户信息
- 测试切换用户角色
- 验证不能切换/删除当前登录管理员
- 验证不能删除有帖子的用户

### 5. 帖子管理搜索排序测试
- 测试按标题/内容关键词搜索
- 测试按作者名搜索
- 测试按板块筛选
- 测试升序/降序排序
- 验证搜索状态在翻页时保持

### 6. 仪表盘图表测试
- 验证各板块帖子统计环形图正确显示
- 验证近30天发帖量折线图正确显示
- 验证近7天用户注册量折线图正确显示
- 验证数据标签（数量和百分比）正确显示

### 7. UI 测试
- 验证"返回首页"按钮在管理后台显示，前台不显示
- 验证底部版权信息始终固定在页面底部

### 8. 数据库修复验证
- 验证帖子详情页正常加载
- 验证点赞/收藏/关注按钮正常工作
- 验证 like_count 和 favorite_count 正确更新

## 注意事项

1. **权限控制**：所有 `/admin/*` 路径由 AuthFilter 保护，仅管理员可访问
2. **自我保护**：管理员不能通过用户管理切换自己的角色或删除自己
3. **数据库迁移**：如已有数据库，需手动执行 ALTER TABLE 和 CREATE TABLE 语句（见数据库修复部分）
4. **编码**：所有请求使用 UTF-8 编码
