# 成员A功能交付文档

## 概述

本文档描述了成员A在BBS论坛系统中实现的功能，包括帖子置顶/加精管理、帖子搜索功能和二级确认提示功能。这些功能为论坛提供了内容管理、检索能力和操作安全性，增强用户体验和管理效率。

## 功能模块

### 1. 帖子置顶/加精管理 (Post Pin & Elite Management)

**功能描述**：
- 管理员可以通过管理后台对帖子进行置顶和加精操作
- 置顶支持三级状态循环切换：未置顶(0) → 板块置顶(1) → 全局置顶(2) → 未置顶(0)
- 加精支持开关切换：未加精(0) ↔ 已加精(1)
- 置顶和加精后的帖子在首页和板块列表中优先展示（置顶 > 加精 > 时间倒序）
- 管理列表支持分页浏览

**相关文件**：
- `src/main/java/com/bbs/controller/AdminPostServlet.java` — 后端控制器（新建）
- `src/main/webapp/admin/post_manage.jsp` — 管理页面
- `src/main/webapp/admin/post_manage_content.jsp` — 管理内容页面（修改）

### 2. 帖子搜索 (Post Search)

**功能描述**：
- 用户可以通过顶部导航栏搜索框搜索帖子
- 支持按帖子标题和内容进行模糊匹配（LIKE 查询）
- 搜索结果按置顶 > 加精 > 时间倒序排列
- 搜索结果支持分页浏览
- 无结果时显示友好提示

**相关文件**：
- `src/main/java/com/bbs/controller/PostServlet.java` — 后端控制器（修改，新增搜索端点）
- `src/main/webapp/post/list.jsp` — 帖子列表页面（修改，适配搜索展示）
- `src/main/webapp/WEB-INF/home.jsp` — 搜索结果复用首页模板
- `src/main/webapp/layouts/main.jsp` — 顶部导航搜索框（已有）

### 3. 二级确认提示 (Secondary Confirmation Prompt)

**功能描述**：
- 管理员在帖子详情页执行置顶/加精操作时，会先弹出确认对话框
- 确认对话框根据当前帖子状态显示具体的操作描述
- 避免管理员误操作，提高操作安全性

**相关文件**：
- `src/main/webapp/post/detail_content.jsp` — 帖子详情页（修改，添加确认提示）

## API 端点说明

### 帖子管理 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/admin/post/manage` | GET | 显示帖子管理列表（分页） | page（页码，可选） | 帖子管理页 |
| `/admin/post/top` | POST | 切换置顶状态（循环） | id（帖子ID） | 重定向到管理页 |
| `/admin/post/elite` | POST | 切换加精状态（开关） | id（帖子ID） | 重定向到管理页 |

### 搜索 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/post/search` | GET | 搜索帖子 | keyword（关键词）, page（页码，可选） | 帖子列表页 |

## 数据库表结构

### posts 表（相关字段）

`is_top` 和 `is_elite` 字段为成员A所用字段，定义在 `database/init.sql` 的 `posts` 表中：

```sql
is_top      TINYINT DEFAULT 0 COMMENT '是否置顶 0=否 1=板块置顶 2=全局置顶',
is_elite    TINYINT DEFAULT 0 COMMENT '是否加精 0=否 1=是',
```

**字段说明**：
- `is_top`: 置顶状态（0=未置顶, 1=板块置顶, 2=全局置顶）
- `is_elite`: 加精状态（0=未加精, 1=已加精）

## 核心逻辑说明

### 1. 置顶状态循环切换

```java
// 读取当前置顶状态
int currentTop = rs.getInt("is_top");
// 循环切换：0→1→2→0
int newTop = (currentTop + 1) % 3;
```

### 2. 加精状态开关切换

```java
// 读取当前加精状态
int currentElite = rs.getInt("is_elite");
// 开关切换：0→1, 1→0
int newElite = (currentElite == 1) ? 0 : 1;
```

### 3. 搜索实现

```sql
SELECT p.id, p.title, p.content AS summary, p.is_top, p.is_elite, ...
FROM posts p
JOIN users u ON p.user_id = u.id
JOIN categories c ON p.category_id = c.id
WHERE p.title LIKE ? OR p.content LIKE ?
ORDER BY p.is_top DESC, p.is_elite DESC, p.created_at DESC
LIMIT ? OFFSET ?
```

### 4. 列表排序规则

首页、板块列表、搜索结果均按以下优先级排序：
1. 置顶帖子排最前（全局置顶 > 板块置顶）
2. 加精帖子次之
3. 按发布时间倒序

### 5. 二级确认提示实现

JavaScript 确认逻辑：

```javascript
function adminAction(url, postId, actionText, actionText2, actionText3) {
    // 根据URL判断操作类型
    let actionType = '';
    let confirmMessage = '';

    if (url.includes('/admin/post/top')) {
        actionType = '置顶';
        // 置顶操作 - 根据当前状态显示不同的确认消息
        if (typeof actionText !== 'undefined' && typeof actionText2 !== 'undefined' && typeof actionText3 !== 'undefined') {
            if (typeof post !== 'undefined' && post.isTop !== undefined) {
                if (post.isTop === 0) {
                    confirmMessage = '确定要' + actionText + '此帖子吗？\n\n注意：置顶操作将使帖子在板块列表中置顶显示。';
                } else if (post.isTop === 1) {
                    confirmMessage = '确定要' + actionText2 + '此帖子吗？\n\n注意：全局置顶将使帖子在首页置顶显示。';
                } else if (post.isTop === 2) {
                    confirmMessage = '确定要' + actionText3 + '此帖子吗？\n\n注意：取消置顶后帖子将恢复正常显示顺序。';
                }
            }
        }
    } else if (url.includes('/admin/post/elite')) {
        actionType = '加精';
        // 加精操作 - 根据当前状态显示不同的确认消息
        if (typeof actionText !== 'undefined' && typeof actionText2 !== 'undefined') {
            if (typeof post !== 'undefined' && post.isElite !== undefined) {
                if (post.isElite === 0) {
                    confirmMessage = '确定要' + actionText + '此帖子吗？\n\n注意：加精操作将标记此帖子为优质内容。';
                } else if (post.isElite === 1) {
                    confirmMessage = '确定要' + actionText2 + '此帖子吗？\n\n注意：取消加精后帖子将不再显示精华标记。';
                }
            }
        }
    }

    if (confirm(confirmMessage)) {
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'id=' + postId
        }).then(function(r) {
            if (r.ok) {
                location.reload();
            } else {
                alert('操作失败，服务器返回: ' + r.status);
            }
        }).catch(function(error) {
            alert('操作失败，请重试: ' + error.message);
        });
    }
}
```

## 前端集成说明

### 1. 帖子列表中的置顶/加精标识

在首页和板块帖子列表中，置顶和加精帖子上方显示对应标签：

```jsp
<c:if test="${post.isTop == 2}">
    <span class="inline-block px-1.5 py-px text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-1.5 align-middle">全局置顶</span>
</c:if>
<c:if test="${post.isTop == 1}">
    <span class="inline-block px-1.5 py-px text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-1.5 align-middle">置顶</span>
</c:if>
<c:if test="${post.isElite == 1}">
    <span class="inline-block px-1.5 py-px text-xs font-medium text-pink-600 bg-pink-50 border border-pink-200 rounded mr-1.5 align-middle">精华</span>
</c:if>
```

### 2. 管理后台操作按钮

管理后台帖子管理页使用 POST 表单提交置顶/加精操作：

```jsp
<%-- 置顶按钮 --%>
<form method="post" action="${pageContext.request.contextPath}/admin/post/top" style="display:inline;">
    <input type="hidden" name="id" value="${post.id}" />
    <button type="submit" class="btn btn-sm btn-warning" title="切换置顶状态">
        <i class="fa fa-arrow-up"></i>
    </button>
</form>

<%-- 加精按钮 --%>
<form method="post" action="${pageContext.request.contextPath}/admin/post/elite" style="display:inline;">
    <input type="hidden" name="id" value="${post.id}" />
    <button type="submit" class="btn btn-sm btn-warning" title="切换精华状态">
        <i class="fa fa-diamond"></i>
    </button>
</form>
```

### 3. 二级确认提示实现

在帖子详情页的置顶/加精按钮中添加确认提示：

```jsp
<button onclick="adminAction('${pageContext.request.contextPath}/admin/post/top', ${post.id}, '板块置顶', '全局置顶', '取消置顶')"
        class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-orange-600 bg-orange-50 border border-orange-200 rounded hover:bg-orange-100 transition cursor-pointer active:scale-95">
    <i class="fa fa-arrow-up"></i>
    <c:choose>
        <c:when test="${post.isTop == 0}">设为板块置顶</c:when>
        <c:when test="${post.isTop == 1}">设为全局置顶</c:when>
        <c:otherwise>取消置顶</c:otherwise>
    </c:choose>
</button>
<button onclick="adminAction('${pageContext.request.contextPath}/admin/post/elite', ${post.id}, '加精', '取消加精')"
        class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-pink-600 bg-pink-50 border border-pink-200 rounded hover:bg-pink-100 transition cursor-pointer active:scale-95">
    <i class="fa fa-diamond"></i>
    <c:choose>
        <c:when test="${post.isElite == 0}">加精</c:when>
        <c:otherwise>取消加精</c:otherwise>
    </c:choose>
</button>
```

### 4. 搜索集成

搜索框位于顶部导航栏，提交到 `/post/search`：

```jsp
<form action="${pageContext.request.contextPath}/post/search" method="get" class="ml-4 flex items-center">
    <input type="text" name="keyword" value="${param.keyword}" placeholder="搜索帖子..."
           class="w-40 px-3 py-1.5 text-sm border border-gray-300 rounded-l ..." maxlength="50">
    <button type="submit" class="px-3 py-1.5 text-sm bg-gray-100 border border-l-0 border-gray-300 rounded-r ...">
        <i class="fa fa-search"></i>
    </button>
</form>
```

搜索结果复用 `WEB-INF/home.jsp` 模板进行渲染，标题区显示搜索关键词：

```jsp
<c:when test="${not empty searchKeyword}">
    <i class="fa fa-search mr-1"></i> 搜索："${searchKeyword}"
    <span class="text-sm text-gray-400 font-normal ml-2">找到 ${totalPosts} 条结果</span>
</c:when>
```

无结果时显示友好提示：

```jsp
<c:when test="${not empty searchKeyword}">
    <i class="fa fa-search text-5xl block mb-4"></i>
    <p class="text-sm">没有找到与 "<c:out value='${searchKeyword}'/>" 相关的帖子</p>
</c:when>
```

## 使用示例

### 1. 管理员置顶帖子

**管理员操作**：
1. 使用 admin/admin123 登录系统
2. 点击顶部导航栏"管理"按钮
3. 在后台首页点击"帖子管理"
4. 在帖子列表中点击某条帖子的置顶按钮（↑）
5. 置顶状态依次循环：否 → 板块置顶 → 全局置顶 → 否

**后端处理**：
```java
// POST /admin/post/top  id=123
int currentTop = queryCurrentTop(postId);
int newTop = (currentTop + 1) % 3;
updatePostTop(postId, newTop);
// 重定向回 /admin/post/manage
```

### 2. 管理员加精帖子

**管理员操作**：
1. 进入"帖子管理"页面
2. 点击某条帖子的加精按钮（◇）
3. 加精状态切换：否 ↔ 是

**后端处理**：
```java
// POST /admin/post/elite  id=123
int currentElite = queryCurrentElite(postId);
int newElite = (currentElite == 1) ? 0 : 1;
updatePostElite(postId, newElite);
// 重定向回 /admin/post/manage
```

### 3. 用户搜索帖子

**用户操作**：
1. 在顶部导航栏搜索框中输入关键词，如"Java"
2. 点击搜索按钮或按回车
3. 查看搜索结果列表
4. 如有分页，可翻页浏览更多结果

**后端处理**：
```java
// GET /post/search?keyword=Java
String keyword = request.getParameter("keyword");
int total = countSearchPosts(keyword);
List<Map<String, Object>> results = searchPosts(keyword, page);
request.setAttribute("postList", results);
// 转发到 WEB-INF/home.jsp 渲染
```

### 4. 管理员操作确认流程

**管理员操作**：
1. 进入帖子详情页
2. 点击置顶/加精按钮
3. 弹出确认对话框，显示具体操作描述
4. 确认后执行操作，页面刷新显示新状态

**确认消息示例**：
- "确定要板块置顶此帖子吗？"
- "确定要全局置顶此帖子吗？"
- "确定要取消置顶此帖子吗？"
- "确定要加精此帖子吗？"
- "确定要取消加精此帖子吗？"

## 依赖关系

### 对其他成员的影响

1. **对组长 (Team Leader)**：
   - 依赖 `posts` 表已包含 `is_top` 和 `is_elite` 字段
   - 首页帖子列表已按置顶 > 加精 > 时间倒序排序（HomeServlet + CategoryServlet 已有）
   - 帖子详情页已读取并展示 `isTop`、`isElite` 属性

2. **对组员B (Member B)**：
   - 用户系统不受影响
   - 登录鉴权由 AuthFilter 统一处理（已覆盖 `/admin/*` 路径）

3. **对组员C (Member C)**：
   - 板块管理不受直接影响
   - 管理员后台首页已链接到帖子管理页面

4. **对组员D (Member D)**：
   - 搜索功能支持搜索结果展示，积分系统不受影响
   - 需求悬赏功能不受影响

## 测试建议

### 1. 置顶功能测试
- 测试置顶状态循环切换（0→1→2→0）
- 验证板块置顶和全局置顶在列表中显示不同标签
- 验证置顶帖子出现在列表最前面
- 测试多帖置顶的排序顺序

### 2. 加精功能测试
- 测试加精状态开关切换（0↔1）
- 验证加精帖子显示"精华"标签
- 验证加精帖子排在普通帖子前面
- 测试置顶+加精同时存在的显示效果

### 3. 搜索功能测试
- 测试关键词匹配标题
- 测试关键词匹配内容
- 测试无匹配结果时的提示信息
- 测试搜索结果分页
- 测试关键词为空时的处理（自动跳转首页）
- 测试特殊字符搜索（如标点符号、空格）

### 4. 二级确认提示功能测试
- 测试不同置顶状态下的确认消息显示
- 测试不同加精状态下的确认消息显示
- 测试确认对话框的取消操作
- 测试确认后操作是否正确执行
- 测试页面刷新后状态是否正确更新

### 5. 权限测试
- 验证普通用户无法访问 `/admin/post/manage`（403 禁止）
- 验证未登录用户无法访问管理页面（自动跳转登录页）

## 注意事项

1. **权限控制**：`/admin/post/*` 路径已由 AuthFilter（`@WebFilter(urlPatterns = {"/admin", "/admin/*"})`）统一保护，仅管理员可访问
2. **操作方式**：置顶/加精使用 POST 方式提交，防止 CSRF 攻击
3. **搜索安全**：搜索关键词使用 PreparedStatement 参数化查询，防止 SQL 注入
4. **分页安全**：页码参数使用异常捕获（NumberFormatException），无效值自动回退到第 1 页
5. **编码**：所有页面使用 UTF-8 编码
6. **SQL索引建议**：`posts` 表的 `title` 和 `content` 字段建议添加全文索引以优化搜索性能
7. **确认提示**：二级确认提示使用 JavaScript 实现客户端确认，提高操作安全性