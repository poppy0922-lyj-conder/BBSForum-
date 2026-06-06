# 成员C功能交付文档

## 概述

本文档描述了成员C在BBS论坛系统中实现的功能，包括板块管理、帖子编辑和分板块展示功能。这些功能为整个系统提供了核心的论坛组织和管理能力。

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

### posts 表 (相关字段)

```sql
ALTER TABLE posts ADD COLUMN category_id INT NOT NULL AFTER user_id;
```

**相关字段**：
- `category_id`: 帖子所属板块ID (外键关联categories.id)

## 前端集成说明

### 1. 板块显示

在首页和帖子页面，板块列表通过以下方式加载：

```jsp
<!-- 加载板块列表到session -->
<c:if test="${sessionScope.categoryList == null}">
    <c:set var="categoryList" value="${requestScope.categoryList}" scope="session" />
</c:if>

<!-- 显示板块导航 -->
<c:forEach var="cat" items="${sessionScope.categoryList}">
    <a href="${pageContext.request.contextPath}/category?id=${cat.id}">${cat.name}</a>
</c:forEach>
```

### 2. 板块帖子列表

在帖子列表页面，通过`currentCategory`属性显示当前板块：

```jsp
<h2>
    <c:choose>
        <c:when test="${not empty currentCategory}">
            <i class="fa fa-folder-o mr-1"></i> ${currentCategory.name}
        </c:when>
        <c:otherwise>
            <i class="fa fa-newspaper-o mr-1"></i> 全部帖子
        </c:otherwise>
    </c:choose>
</h2>
```

### 3. 帖子编辑表单

编辑页面包含板块选择下拉框：

```jsp
<select name="categoryId" id="categoryId" class="form-select" required>
    <c:forEach var="cat" items="${sessionScope.categoryList}">
        <option value="${cat.id}" ${cat.id == post.categoryId ? 'selected' : ''}>${cat.name}</option>
    </c:forEach>
</select>
```

## 使用示例

### 1. 添加新板块

**管理员操作**：
1. 访问 `/admin/categories`
2. 填写板块名称和描述
3. 点击"添加"按钮

**后端处理**：
```java
// 在AdminCategoryServlet中
addCategory(name, description);
```

### 2. 浏览技术交流板块

**用户操作**：
1. 访问 `/category?id=1` (假设技术交流板块ID为1)
2. 查看该板块下的所有帖子

**后端处理**：
```java
// 在CategoryServlet中
Map<String, Object> category = loadCategory(categoryId);
List<Map<String, Object>> posts = loadPostsByCategory(categoryId);
```

### 3. 编辑帖子

**作者操作**：
1. 访问 `/post/edit?id=123` (帖子ID为123)
2. 修改标题、内容和板块
3. 点击"保存修改"

**后端处理**：
```java
// 在PostEditServlet中
updatePost(postId, title, content, categoryId);
```

## 依赖关系

### 对其他成员的影响

1. **对组长 (Team Leader)**：
   - 需要确保`categories`表已创建
   - 需要在首页加载板块列表到session
   - 需要在帖子列表中显示板块信息

2. **对成员A (Member A)**：
   - 帖子置顶/加精功能需要板块信息
   - 搜索功能需要按板块过滤

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

## 注意事项

1. **权限控制**：当前实现未包含严格的权限检查，实际使用时需要添加管理员权限验证
2. **错误处理**：已实现基本的错误页面，但可以进一步完善
3. **数据验证**：表单数据验证可以在前端和后端同时进行
4. **编码**：确保所有请求使用UTF-8编码

