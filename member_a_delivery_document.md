# 成员A功能交付文档

**工作量占比：20%**（详见 `BBS论坛项目分工方案.md`）

## 概述

本文档描述了成员A在BBS论坛系统中实现的功能，包括帖子置顶/加精管理、帖子搜索功能、二级确认提示功能、举报与审核系统、软删除机制、站内通知系统、统一弹窗系统扩展和热门标签。这些功能为论坛提供了内容管理、检索能力、操作安全性、违规内容治理、用户通知和标签检索等能力，全面增强用户体验和管理效率。

## 功能模块

### 1. 帖子置顶/加精管理 (Post Pin & Elite Management)

**功能描述**：
- 管理员可以通过管理后台对帖子进行置顶和加精操作
- 置顶支持三级状态循环切换：未置顶(0) → 板块置顶(1) → 全局置顶(2) → 未置顶(0)
- 加精支持开关切换：未加精(0) ↔ 已加精(1)
- 置顶和加精后的帖子在首页和板块列表中优先展示（置顶 > 加精 > 时间倒序）
- 管理列表支持分页浏览

**相关文件**：
- `src/main/java/com/bbs/controller/AdminPostServlet.java` — 后端控制器
- `src/main/webapp/admin/post_manage.jsp` — 管理页面
- `src/main/webapp/admin/post_manage_content.jsp` — 管理内容页面

### 2. 帖子搜索 (Post Search)

**功能描述**：
- 用户可以通过顶部导航栏搜索框搜索帖子
- 支持按帖子标题、内容和关键词进行模糊匹配（LIKE 查询）
- 搜索结果按置顶 > 加精 > 时间倒序排列
- 搜索结果支持分页浏览
- 无结果时显示友好提示

**相关文件**：
- `src/main/java/com/bbs/controller/PostServlet.java` — 后端控制器（搜索端点）
- `src/main/webapp/WEB-INF/home.jsp` — 搜索结果复用首页模板
- `src/main/webapp/layouts/main.jsp` — 顶部导航搜索框

### 3. 二级确认提示 (Secondary Confirmation Prompt)

**功能描述**：
- 管理员在帖子详情页执行置顶/加精操作时，会先弹出确认对话框
- 确认对话框根据当前帖子状态显示具体的操作描述
- 避免管理员误操作，提高操作安全性

**相关文件**：
- `src/main/webapp/post/detail_content.jsp` — 帖子详情页（添加确认提示）

### 4. 举报与审核系统 (Report & Review System)

**功能描述**：
- 用户可以举报帖子、回复、需求、需求回复四类内容
- 举报原因支持：垃圾广告、人身攻击、政治敏感、色情低俗、其他
- 防重复举报：同一用户对同一内容仅允许一条 pending 状态的举报
- 不能举报自己的内容
- 管理员可在后台查看举报列表（分页15条，支持状态筛选）
- 管理员可预览被举报内容（escapeHtml 防 XSS）
- 管理员处理举报（通过/驳回），通过时自动软删除内容
- 处理操作使用事务保证原子性（SELECT FOR UPDATE 行锁）
- 复用项目统一弹窗系统（showCustomModal）

**相关文件**：
- `src/main/java/com/bbs/controller/ReportServlet.java` — 举报控制器
- `src/main/webapp/admin/report_manage.jsp` — 管理页布局壳
- `src/main/webapp/admin/report_manage_content.jsp` — 管理页内容
- `src/main/webapp/post/detail_content.jsp` — 帖子详情页（添加举报按钮）
- `src/main/webapp/demand/detail_content.jsp` — 需求详情页（添加举报按钮）
- `src/main/webapp/layouts/main.jsp` — 侧边栏菜单（添加举报管理入口）

### 5. 软删除机制 (Soft Delete Mechanism)

**功能描述**：
- 为 posts、replies、demands、demand_replies 四张表添加 `is_deleted` 字段
- 全局修改所有 SELECT 查询，添加 `is_deleted = 0` 过滤条件
- 用户删除帖子时改为软删除（UPDATE 而非 DELETE）
- 管理员通过举报处理时自动软删除违规内容
- 软删除的内容在首页、板块列表、热度榜、搜索结果中均不可见

**相关文件**（修改的查询涉及多个文件）：
- `src/main/java/com/bbs/controller/HomeServlet.java` — 2个查询
- `src/main/java/com/bbs/controller/CategoryServlet.java` — 2个查询
- `src/main/java/com/bbs/controller/PostServlet.java` — 多个查询 + DELETE→UPDATE
- `src/main/java/com/bbs/controller/DemandServlet.java` — 多个查询
- `src/main/java/com/bbs/controller/HotServlet.java` — 2个查询
- `src/main/java/com/bbs/controller/AdminPostServlet.java` — 多个查询
- `src/main/java/com/bbs/controller/AdminDashboardServlet.java` — 2个查询
- `src/main/java/com/bbs/controller/AdminUserServlet.java` — 1个查询
- `src/main/java/com/bbs/util/StatsFilter.java` — 4个查询
- `src/main/webapp/admin/index_content.jsp` — 1个查询

### 6. 站内通知系统 (Notification System)

**功能描述**：
- 管理员处理举报后，自动通知举报人处理结果（通过/驳回）
- 举报通过时，自动通知被举报人（内容作者）内容已被删除
- 通知类型：`report_result`（举报结果）、`content_deleted`（内容删除）
- 顶部导航栏显示未读通知红点及数量（AJAX 轮询，60秒刷新）
- 通知列表页面分页展示，支持"全部已读"
- 点击通知进入详情页查看举报完整信息（举报人、原因、处理结果、备注）
- 点击详情后自动标记为已读
- 通知与举报处理在同一事务中插入，保证原子性

**相关文件**：
- `src/main/java/com/bbs/controller/NotificationServlet.java` — 通知控制器
- `src/main/webapp/notification/list.jsp` — 通知列表布局壳
- `src/main/webapp/notification/list_content.jsp` — 通知列表内容
- `src/main/webapp/notification/detail.jsp` — 通知详情布局壳
- `src/main/webapp/notification/detail_content.jsp` — 通知详情内容
- `src/main/webapp/layouts/main.jsp` — 顶部导航栏（添加通知铃铛+AJAX轮询）

### 7. 统一弹窗系统扩展 (Modal System Extension)

**功能描述**：
- 在现有 `showConfirm`、`alert`、`showError` 基础上，新增 `showCustomModal` 函数
- 支持自定义 HTML 内容（下拉框、文本域等表单元素）
- 支持 `onConfirm` 回调（传入 `done` 函数控制关闭时机）
- 修复了 `alert`/`showConfirm`/`showError` 未重置 `modalBtnConfirm.onclick` 的 Bug
- 举报提交、管理员处理举报均复用此弹窗系统

**相关文件**：
- `src/main/webapp/layouts/main.jsp` — 弹窗函数定义

### 8. 热门标签 (Hot Tags)

**功能描述**：
- 右侧栏实时数据面板下方显示热门标签模块
- 从帖子 `keywords` 字段聚合统计，显示使用频率最高的前 8 个标签
- 按出现次数降序排列，次数相同时按关键词名称字母序排列（TreeMap + 二级排序）
- 点击标签跳转到搜索页 `/post/search?keyword=xxx`，搜索范围包含标题、内容和关键词
- 数据通过 `StatsFilter` 缓存（15秒自动刷新），避免每次请求都查库
- 帖子卡片上显示每个帖子的前 3 个关键词标签

**相关文件**：
- `src/main/java/com/bbs/util/StatsFilter.java` — 热门标签聚合逻辑（`loadHotKeywords` 方法）
- `src/main/webapp/layouts/main.jsp` — 热门标签视图（右侧栏）
- `src/main/webapp/post/list.jsp` — 帖子卡片关键词标签展示

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

### 举报 API

| URL | 方法 | 功能 | 权限 | 参数 | 返回 |
|-----|------|------|------|------|------|
| `/report/submit` | POST | 提交举报 | 已登录 | targetType, targetId, reason | JSON |
| `/admin/report/list` | GET | 举报列表 | 管理员 | status, page | 管理页 |
| `/admin/report/preview` | GET | 预览举报内容 | 管理员 | reportId | HTML片段 |
| `/admin/report/handle` | POST | 处理举报 | 管理员 | reportId, action, handleNote | 重定向 |

### 通知 API

| URL | 方法 | 功能 | 权限 | 参数 | 返回 |
|-----|------|------|------|------|------|
| `/notification/unreadCount` | GET | 未读通知数 | 已登录 | 无 | JSON `{"count": N}` |
| `/notification/list` | GET | 通知列表 | 已登录 | page | 通知列表页 |
| `/notification/detail` | GET | 通知详情 | 已登录 | id | 详情页 |
| `/notification/markRead` | POST | 标记已读 | 已登录 | id（可选） | 重定向 |

## 数据库表结构

### posts 表（相关字段）

```sql
is_top      TINYINT DEFAULT 0 COMMENT '是否置顶 0=否 1=板块置顶 2=全局置顶',
is_elite    TINYINT DEFAULT 0 COMMENT '是否加精 0=否 1=是',
```

### posts/replies/demands/demand_replies 表（软删除字段）

```sql
ALTER TABLE posts ADD COLUMN is_deleted TINYINT DEFAULT 0 COMMENT '0=正常 1=已删除';
ALTER TABLE replies ADD COLUMN is_deleted TINYINT DEFAULT 0 COMMENT '0=正常 1=已删除';
ALTER TABLE demands ADD COLUMN is_deleted TINYINT DEFAULT 0 COMMENT '0=正常 1=已删除';
ALTER TABLE demand_replies ADD COLUMN is_deleted TINYINT DEFAULT 0 COMMENT '0=正常 1=已删除';
```

### reports 表（举报记录）

```sql
CREATE TABLE IF NOT EXISTS reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_id INT NOT NULL COMMENT '举报人ID',
    target_type ENUM('post', 'reply', 'demand', 'demand_reply') NOT NULL COMMENT '举报类型',
    target_id INT NOT NULL COMMENT '被举报对象ID',
    reason VARCHAR(20) NOT NULL COMMENT '举报原因代码',
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending' COMMENT '处理状态',
    handler_id INT DEFAULT NULL COMMENT '处理人ID',
    handle_note VARCHAR(200) DEFAULT NULL COMMENT '处理备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (reporter_id) REFERENCES users(id),
    FOREIGN KEY (handler_id) REFERENCES users(id),
    INDEX idx_status (status),
    INDEX idx_target (target_type, target_id)
);
```

### notifications 表（站内通知）

```sql
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT '接收人ID',
    type VARCHAR(20) NOT NULL COMMENT '类型：report_result, content_deleted',
    content VARCHAR(500) NOT NULL COMMENT '通知内容',
    is_read TINYINT DEFAULT 0 COMMENT '0未读 1已读',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_read (user_id, is_read)
);
```

## 核心逻辑说明

### 1. 置顶状态循环切换

```java
int currentTop = rs.getInt("is_top");
int newTop = (currentTop + 1) % 3;  // 0→1→2→0
```

### 2. 加精状态开关切换

```java
int currentElite = rs.getInt("is_elite");
int newElite = (currentElite == 1) ? 0 : 1;
```

### 3. 搜索实现

搜索范围覆盖标题、内容和关键词三个字段：

```sql
SELECT ... FROM posts p ...
WHERE (p.title LIKE ? OR p.content LIKE ? OR p.keywords LIKE ?) AND p.is_deleted = 0
ORDER BY p.is_top DESC, p.is_elite DESC, p.created_at DESC
```

### 4. 列表排序规则

首页、板块列表、搜索结果均按以下优先级排序：
1. 置顶帖子排最前（全局置顶 > 板块置顶）
2. 加精帖子次之
3. 按发布时间倒序

### 5. 举报处理事务

管理员处理举报时使用事务保证原子性：

```java
conn.setAutoCommit(false);
// 1. SELECT ... FOR UPDATE 锁定举报记录
// 2. 验证状态为 pending
// 3. 软删除违规内容（approve 时）
// 4. 更新举报状态
// 5. 插入通知（举报人 + 被举报人）
// 6. conn.commit()
// 异常时 conn.rollback()
```

### 6. 通知插入逻辑

处理举报成功后，在同一事务中插入通知：

```java
// 通知举报人
insertNotification(conn, reporterId, "report_result",
    "您举报的" + targetTypeName + "(ID:" + targetId + ")已处理，结果为：通过/驳回");

// 通知被举报人（仅通过时，且不与举报人重复）
if ("approve".equals(action) && targetAuthorId != null && targetAuthorId != reporterId) {
    insertNotification(conn, targetAuthorId, "content_deleted",
        "您发布的" + targetTypeName + "因【" + reasonText + "】已被删除");
}
```

### 7. 软删除过滤模式

全局修改所有 SELECT 查询，追加 `is_deleted = 0` 条件：

```sql
-- 无 WHERE 子句
SELECT ... FROM posts WHERE is_deleted = 0

-- 有 WHERE 子句
SELECT ... FROM posts WHERE category_id = ? AND is_deleted = 0

-- LEFT JOIN 查询
SELECT ... FROM categories c LEFT JOIN posts p ON c.id = p.category_id AND p.is_deleted = 0

-- LIKE 搜索
SELECT ... FROM posts WHERE (title LIKE ? OR content LIKE ? OR keywords LIKE ?) AND is_deleted = 0
```

### 8. showCustomModal 弹窗函数

新增自定义内容弹窗，支持表单元素：

```javascript
function showCustomModal(title, contentHtml, options) {
    // options: { confirmText, onConfirm }
    // onConfirm(done) — 传入 done 回调，调用 done() 关闭弹窗
}
```

alert/showConfirm/showError 内部重置 `modalBtnConfirm.onclick`，防止弹窗状态冲突。

### 9. 二级确认提示实现

JavaScript 确认逻辑：

```javascript
function adminAction(url, postId, actionText, actionText2, actionText3) {
    // 根据URL判断操作类型
    // 置顶：根据 isTop 状态 (0/1/2) 显示不同确认消息
    // 加精：根据 isElite 状态 (0/1) 显示不同确认消息
    // 确认后通过 fetch POST 提交，成功后 location.reload()
}
```

### 10. 热门标签聚合逻辑

从所有帖子的 `keywords` 字段提取关键词，按出现频率排序：

```java
// 1. 查询所有非空 keywords 的帖子
String sql = "SELECT keywords FROM posts WHERE keywords IS NOT NULL AND keywords != '' AND is_deleted = 0";

// 2. 按逗号拆分，统计每个关键词出现的帖子数
for (String k : kw.split("[,，]")) {
    freq.merge(k.trim(), 1, Integer::sum);
}

// 3. 按频率降序 + 名称字母序排列（TreeMap 保证稳定性）
list.sort((a, b) -> {
    int cmp = b.getValue().compareTo(a.getValue());
    return cmp != 0 ? cmp : a.getKey().compareTo(b.getKey());
});

// 4. 取前 8 个
return list.size() > 8 ? list.subList(0, 8) : list;
```

## 前端集成说明

### 1. 帖子列表中的置顶/加精标识

```jsp
<c:if test="${post.isTop == 2}"><span class="...">全局置顶</span></c:if>
<c:if test="${post.isTop == 1}"><span class="...">置顶</span></c:if>
<c:if test="${post.isElite == 1}"><span class="...">精华</span></c:if>
```

### 2. 管理后台操作按钮

管理后台帖子管理页使用 POST 表单提交置顶/加精操作。

### 3. 搜索集成

搜索框位于顶部导航栏，提交到 `/post/search`，搜索范围包含标题、内容和关键词。

### 4. 举报按钮集成

在帖子详情页和需求详情页添加举报按钮（仅对非作者的登录用户显示），使用 showCustomModal 弹窗。

### 5. 通知铃铛集成

顶部导航栏用户菜单区添加通知铃铛图标，页面加载时 + 每60秒轮询未读数。

### 6. 管理后台侧边栏集成

在 admin 侧边栏添加举报管理菜单项。

## 使用示例

### 1. 管理员置顶帖子
1. 使用 admin/admin123 登录系统
2. 点击顶部导航栏"管理"按钮
3. 在后台首页点击"帖子管理"
4. 在帖子列表中点击某条帖子的置顶按钮（↑）
5. 置顶状态依次循环：否 → 板块置顶 → 全局置顶 → 否

### 2. 管理员加精帖子
1. 进入"帖子管理"页面
2. 点击某条帖子的加精按钮（◇）
3. 加精状态切换：否 ↔ 是

### 3. 用户搜索帖子
1. 在顶部导航栏搜索框中输入关键词
2. 点击搜索按钮或按回车
3. 查看搜索结果列表（支持标题、内容、关键词匹配）

### 4. 用户举报内容
1. 登录普通用户（如 test/test123）
2. 进入帖子详情页，点击"举报"按钮
3. 在弹窗中选择举报原因
4. 点击"提交举报"

### 5. 管理员处理举报
1. 使用 admin/admin123 登录
2. 进入管理后台 → 举报管理
3. 查看待处理的举报记录
4. 点击"处理"按钮，选择"通过"或"驳回"
5. 举报状态更新，相关通知自动发送

### 6. 用户查看通知
1. 顶部导航栏铃铛图标显示未读红点
2. 点击铃铛进入通知列表
3. 点击某条通知进入详情页 → 自动标为已读
4. 点击"全部已读" → 所有通知标为已读

## 注意事项

1. **权限控制**：`/admin/post/*` 和 `/admin/report/*` 路径已由 AuthFilter 统一保护，仅管理员可访问
2. **操作方式**：置顶/加精使用 POST 方式提交，防止 CSRF 攻击
3. **搜索安全**：搜索关键词使用 PreparedStatement 参数化查询，防止 SQL 注入
4. **分页安全**：页码参数使用异常捕获（NumberFormatException），无效值自动回退到第 1 页
5. **编码**：所有页面使用 UTF-8 编码
6. **XSS防护**：举报预览使用 `escapeHtml()` 转义所有用户输入内容，通知列表使用 `<c:out>` 自动转义
7. **事务一致性**：举报处理使用 `setAutoCommit(false)` + `SELECT FOR UPDATE` 行锁 + `conn.commit()/rollback()`，保证举报状态变更、软删除、通知插入的原子性
8. **弹窗状态管理**：`showCustomModal` 通过 `done` 回调控制关闭时机；`alert`/`showConfirm`/`showError` 内部重置 `modalBtnConfirm.onclick`，防止弹窗状态冲突
9. **数据库迁移**：所有 ALTER TABLE 和 CREATE INDEX 使用 `information_schema` 幂等检查，支持重复执行

## 交付文件清单

### 新建文件

| 文件 | 说明 |
|------|------|
| `src/main/java/com/bbs/controller/ReportServlet.java` | 举报控制器（提交、列表、预览、处理） |
| `src/main/java/com/bbs/controller/NotificationServlet.java` | 通知控制器（未读数、列表、详情、标记已读） |
| `src/main/webapp/admin/report_manage.jsp` | 举报管理布局壳 |
| `src/main/webapp/admin/report_manage_content.jsp` | 举报管理内容页 |
| `src/main/webapp/notification/list.jsp` | 通知列表布局壳 |
| `src/main/webapp/notification/list_content.jsp` | 通知列表内容页 |
| `src/main/webapp/notification/detail.jsp` | 通知详情布局壳 |
| `src/main/webapp/notification/detail_content.jsp` | 通知详情内容页 |

### 修改文件

| 文件 | 修改内容 |
|------|----------|
| `database/init.sql` | 追加 reports 表、notifications 表、is_deleted 字段及索引、测试帖子关键词 |
| `src/main/webapp/layouts/main.jsp` | 新增 showCustomModal、通知铃铛、AJAX轮询、侧边栏菜单、退出链接 |
| `src/main/java/com/bbs/controller/PostServlet.java` | 多个查询添加 is_deleted=0 + DELETE→UPDATE + 搜索增加 keywords 字段 |
| `src/main/java/com/bbs/controller/DemandServlet.java` | 多个查询添加 is_deleted=0 |
| `src/main/java/com/bbs/controller/HomeServlet.java` | 2个查询添加 is_deleted=0 |
| `src/main/java/com/bbs/controller/CategoryServlet.java` | 2个查询添加 is_deleted=0 |
| `src/main/java/com/bbs/controller/HotServlet.java` | 2个查询添加 is_deleted=0 |
| `src/main/java/com/bbs/controller/AdminPostServlet.java` | 多个查询添加 is_deleted=0 |
| `src/main/java/com/bbs/controller/AdminDashboardServlet.java` | 2个查询添加 is_deleted=0 |
| `src/main/java/com/bbs/controller/AdminUserServlet.java` | 1个查询添加 is_deleted=0 |
| `src/main/java/com/bbs/util/StatsFilter.java` | 4个查询添加 is_deleted=0 + 热门标签聚合（TreeMap+二级排序+限制8个） |
| `src/main/webapp/admin/index_content.jsp` | 1个查询添加 is_deleted=0 |
| `src/main/webapp/post/detail_content.jsp` | 添加举报按钮 + showReportModal JS |
| `src/main/webapp/demand/detail_content.jsp` | 添加举报按钮 + showReportModal JS |

## 功能验证状态

| # | 功能模块 | 状态 |
|---|----------|------|
| 1 | 帖子三级置顶与加精 | ✅ 已实现 |
| 2 | 帖子搜索（标题+内容+关键词） | ✅ 已实现 |
| 3 | 二级确认提示 | ✅ 已实现 |
| 4 | 举报与审核系统 | ✅ 已实现 |
| 5 | 软删除机制（36个查询修复） | ✅ 已实现 |
| 6 | 站内通知系统 | ✅ 已实现 |
| 7 | 统一弹窗系统扩展 | ✅ 已实现 |
| 8 | 热门标签（前8高频关键词+点击搜索） | ✅ 已实现 |
| 9 | 数据库表结构（reports + notifications） | ✅ 已实现 |
