# 成员A 提交说明

## 合并背景

成员A实现了举报系统、软删除机制、站内通知、热门标签等功能，涉及对多个已有文件的 SQL 查询修改和 UI 新增。由于这些修改分散在多个 Servlet 和 JSP 文件中，合并时需注意冲突处理。

## 冲突风险总览

| 风险等级 | 文件 | 原因 |
|----------|------|------|
| **高** | `layouts/main.jsp` | 布局文件多人修改 |
| **高** | `PostServlet.java` | 核心控制器，其他成员可能改动 |
| **中** | `init.sql` | 测试数据可能被其他人修改 |
| **中** | `DemandServlet.java` | 组员D负责的文件 |
| **中** | `StatsFilter.java` | 组长负责的文件 |
| **低** | 其他 Servlet/JSP | 修改量小，位置独立 |
| **无** | 8个新建文件 | 全新文件，不会冲突 |

## 高风险文件合并建议

### `layouts/main.jsp`

A在此文件中做了4处修改：

1. **导航栏**：在用户名后添加通知铃铛，替换"首页"链接为"退出"链接
2. **侧边栏**：在"帖子管理"和"用户管理"之间插入"举报管理"菜单项
3. **弹窗JS**：添加 `showCustomModal` 函数；在 `alert`/`showConfirm`/`showError` 中各加一行 `modalBtnConfirm.onclick` 重置
4. **轮询脚本**：在 `</script>` 前添加通知未读数 AJAX 轮询

如果组长也改了 main.jsp，建议逐项对照合入。

### `PostServlet.java`

A在此文件中做了以下修改（均为 SQL 查询层面）：

- 所有 SELECT 查询追加 `AND is_deleted = 0`
- `handleDelete`：`DELETE FROM posts` 改为 `UPDATE posts SET is_deleted = 1`
- 搜索方法：WHERE 条件增加 `OR keywords LIKE ?`，相应增加一个参数绑定
- 这些修改位置分散在不同方法中，与其他成员的修改区域通常不重叠

### `database/init.sql`

- 文件末尾追加了 is_deleted 迁移补丁（幂等，可安全重复执行）
- 追加了 reports 表、notifications 表（CREATE TABLE IF NOT EXISTS）
- 测试帖子 INSERT 语句增加了 `keywords` 列 — 如果其他人也改了测试数据需手动合并

### `DemandServlet.java`

- 7个查询追加了 `is_deleted = 0`，修改位置在各方法的 SQL 字符串中
- 组员D可能修改了积分相关逻辑，注意区分修改区域

## 新建文件（无冲突）

以下文件为全新创建，可直接合入：

```
src/main/java/com/bbs/controller/ReportServlet.java
src/main/java/com/bbs/controller/NotificationServlet.java
src/main/webapp/admin/report_manage.jsp
src/main/webapp/admin/report_manage_content.jsp
src/main/webapp/notification/list.jsp
src/main/webapp/notification/list_content.jsp
src/main/webapp/notification/detail.jsp
src/main/webapp/notification/detail_content.jsp
```

## 其他修改文件（低风险）

以下文件修改量小，通常是 SQL 查询追加 `is_deleted = 0`，冲突概率低但逻辑重要：

- `HomeServlet.java` — 2个查询
- `CategoryServlet.java` — 2个查询
- `HotServlet.java` — 2个查询
- `AdminPostServlet.java` — 4个查询
- `AdminDashboardServlet.java` - 2个查询
- `AdminUserServlet.java` — 1个查询
- `admin/index_content.jsp` — 1个查询
- `post/detail_content.jsp` — 添加举报按钮+JS
- `demand/detail_content.jsp` — 添加举报按钮+JS
