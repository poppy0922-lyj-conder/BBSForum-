                           # 成员D功能交付文档

## 概述

本文档描述了成员D在BBS论坛系统中实现的功能，包括需求悬赏发布与管理、积分流转系统（发布扣分/采纳加分）和积分记录与排行榜功能。这些功能为论坛构建了完整的悬赏激励机制，用户可以通过发布悬赏需求获取解决方案，通过参与解答赚取积分，形成良性互动的社区生态。

## 功能模块

### 1. 需求发布与管理 (Demand Management)

**功能描述**：
- 用户可以发布悬赏需求，设置悬赏积分金额
- 发布需求时自动扣除相应积分并记录流水
- 需求列表支持分页浏览，显示需求标题、悬赏积分、发布者、状态等信息
- 需求详情页展示完整内容及回复列表
- 需求状态分为“进行中”(open)和“已结束”(closed)

**相关文件**：
- `src/main/java/com/bbs/controller/DemandServlet.java` - 后端控制器
- `src/main/webapp/WEB-INF/demand.jsp` - 需求列表页面
- `src/main/webapp/WEB-INF/demand_create.jsp` - 发布需求页面

### 2. 采纳回复与积分流转 (Reply Acceptance & Score Transfer)

**功能描述**：
- 需求发布者可以采纳任意回复作为最佳答案
- 采纳后系统自动将悬赏积分从发布者账户转移给被采纳者
- 使用数据库事务保证积分流转的原子性，防止积分异常
- 采纳后需求状态自动变更为“已结束”，不可再次采纳

**相关文件**：
- `src/main/java/com/bbs/controller/DemandServlet.java` - 采纳回复逻辑
- `src/main/webapp/WEB-INF/demand_detail.jsp` - 需求详情页（采纳按钮）

### 3. 积分记录与查询 (Score Record & Query)

**功能描述**：
- 用户可以查看自己的积分流水记录
- 记录包含积分变动金额、变动原因、变动时间
- 支持支出（负数）和收入（正数）的区分显示
- 积分记录按时间倒序排列

**相关文件**：
- `src/main/java/com/bbs/controller/ScoreServlet.java` - 积分控制器
- `src/main/webapp/score/record.jsp` - 积分记录页面
- `src/main/webapp/score/record_content.jsp` - 积分记录内容页面

### 4. 积分排行榜 (Score Ranking)

**功能描述**：
- 展示全站用户积分排行，按积分从高到低排序
- 支持前三名特殊视觉样式（金银铜奖杯图标）
- 当前登录用户在排行榜中高亮显示（蓝色背景 + “我”标签）
- 积分实时从数据库读取，与积分流转同步更新

**相关文件**：
- `src/main/java/com/bbs/controller/ScoreServlet.java` - 排行榜逻辑
- `src/main/webapp/score/rank.jsp` - 排行榜页面
- `src/main/webapp/score/rank_content.jsp` - 排行榜内容页面（已美化）

## API 端点说明

### 需求管理 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/demand` | GET | 需求列表 | page（页码，可选） | 需求列表页 |
| `/demand/create` | GET | 显示发布需求页 | 无 | 发布表单页 |
| `/demand/create` | POST | 提交发布需求 | title, content, score, categoryId | 重定向到需求列表 |
| `/demand/accept` | POST | 采纳回复 | demandId, replyId | 重定向到需求详情 |

### 积分系统 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/score/record` | GET | 查看积分记录 | 无（需登录） | 积分记录页 |
| `/score/rank` | GET | 查看积分排行榜 | 无 | 排行榜页 |

## 数据库表结构

### demands 表

```sql
CREATE TABLE demands (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    score INT NOT NULL DEFAULT 0,
    status ENUM('open','closed') NOT NULL DEFAULT 'open',
    best_reply_id INT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

**字段说明**：
- `id`: 需求唯一标识
- `title`: 需求标题
- `content`: 需求详细描述
- `user_id`: 发布者ID（外键关联users.id）
- `category_id`: 所属板块ID（外键关联categories.id）
- `score`: 悬赏积分金额
- `status`: 需求状态（open=进行中, closed=已结束）
- `best_reply_id`: 被采纳的最佳回复ID
- `created_at`: 发布时间

### score_logs 表

```sql
CREATE TABLE score_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    score INT NOT NULL,
    reason VARCHAR(100) DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

**字段说明**：
- `id`: 流水唯一标识
- `user_id`: 用户ID（外键关联users.id）
- `score`: 积分变动值（正数=获得，负数=扣除）
- `reason`: 变动原因描述
- `created_at`: 变动时间

### users 表（新增字段）

```sql
ALTER TABLE users ADD COLUMN score INT NOT NULL DEFAULT 0 AFTER role;
```

## 核心逻辑说明

### 1. 发布需求 - 扣积分流程

```java
// 开启事务
conn.setAutoCommit(false);

// 1. 插入需求记录
INSERT INTO demands (title, content, user_id, category_id, score, status) 
VALUES (?, ?, ?, ?, ?, 'open');

// 2. 扣除发布者积分
UPDATE users SET score = score - ? WHERE id = ? AND score >= ?;

// 3. 记录积分流水
INSERT INTO score_logs (user_id, score, reason) 
VALUES (?, ?, '发布悬赏需求，支出 X 积分');

conn.commit();
```

### 2. 采纳回复 - 加积分流程

```java
// 开启事务，使用行锁防止并发
SELECT user_id, score, status FROM demands WHERE id = ? FOR UPDATE;

// 1. 检查权限（只有发布者可采纳）
if (currentUserId != demandUserId) → 拒绝

// 2. 检查状态（只有进行中可采纳）
if (!"open".equals(status)) → 拒绝

// 3. 给回复者增加积分
UPDATE users SET score = score + ? WHERE id = ?;

// 4. 记录积分流水
INSERT INTO score_logs (user_id, score, reason) 
VALUES (?, ?, '回复被采纳，获得悬赏 X 积分');

// 5. 更新需求状态
UPDATE demands SET status = 'closed', best_reply_id = ? WHERE id = ?;

conn.commit();
```

### 3. 积分排行榜查询

```sql
SELECT username, score FROM users ORDER BY score DESC LIMIT 100;
```

### 4. 积分记录查询

```sql
SELECT score, reason, created_at FROM score_logs 
WHERE user_id = ? ORDER BY created_at DESC;
```

## 前端集成说明

### 1. 发布需求表单

发布需求页面包含板块选择、标题、内容、悬赏积分的完整表单：

```jsp
<form action="${pageContext.request.contextPath}/demand/create" method="post">
    <select name="categoryId" required>
        <c:forEach var="cat" items="${applicationScope.categoryList}">
            <option value="${cat.id}">${cat.name}</option>
        </c:forEach>
    </select>
    <input type="text" name="title" required>
    <textarea name="content" required></textarea>
    <input type="number" name="score" min="1" required>
    <button type="submit">发布悬赏</button>
</form>
```

### 2. 需求列表展示

需求列表通过`postList`变量渲染，显示悬赏积分和状态标签：

```jsp
<c:forEach var="demand" items="${postList}">
    <div class="card">
        <span class="badge badge-score">${demand.score} 积分</span>
        <c:if test="${demand.status == 'closed'}">
            <span class="badge">已结束</span>
        </c:if>
        <a href="${pageContext.request.contextPath}/demand/detail?id=${demand.id}">
            ${demand.title}
        </a>
    </div>
</c:forEach>
```

### 3. 采纳回复按钮

需求详情页中，仅发布者可见采纳按钮：

```jsp
<c:if test="${sessionScope.user.id == demand.userId && demand.status == 'open'}">
    <a href="${pageContext.request.contextPath}/demand/accept?demandId=${demand.id}&replyId=${reply.id}"
       onclick="return confirm('确定采纳此回复？积分将转给该用户')">
        采纳此回复
    </a>
</c:if>
```

### 4. 积分排行榜展示（已美化）

排行榜页面支持：
- 前三名金银铜奖杯图标
- 当前用户高亮显示（蓝色背景 + “我”标签）
- 用户头像（用户名首字母圆形图标）
- 积分数字橙色加粗 + 钻石图标

```jsp
<tr class="${sessionScope.user.username == row.username ? 'bg-blue-50' : ''}">
    <td>${status.index + 1}</td>
    <td>${row.username}</td>
    <td><i class="fa fa-diamond"></i> ${row.score}</td>
</tr>
```

## 使用示例

### 1. 发布悬赏需求

**用户操作**：
1. 登录系统（如 test/test123）
2. 点击侧边栏“发布悬赏”
3. 填写需求标题、内容、悬赏积分（如10分）
4. 点击“发布悬赏”

**后端处理**：
- 检查用户积分是否充足（当前积分需 ≥ 悬赏积分）
- 扣除悬赏积分并记录流水（reason: "发布悬赏需求，支出10积分"）
- 插入需求记录，状态为“进行中”

### 2. 参与解答并获取积分

**用户操作（被采纳者）**：
1. 在需求详情页发表回复
2. 需求发布者点击“采纳此回复”
3. 确认弹窗后完成采纳

**后端处理**：
- 检查操作权限（仅发布者可采纳）
- 检查需求状态（仅“进行中”可采纳）
- 给被采纳者增加悬赏积分
- 记录积分流水（reason: "回复被采纳，获得悬赏10积分"）
- 更新需求状态为“已结束”

### 3. 查看积分记录

**用户操作**：
1. 访问积分记录页面 `/score/record`
2. 查看积分变动流水（支出10分、获得10分等）

### 4. 查看积分排行榜

**用户操作**：
1. 访问积分排行榜 `/score/rank`
2. 查看全站用户积分排名
3. 当前用户高亮显示，快速定位自己的排名

## 依赖关系

### 对其他成员的影响

1. **对组长 (Team Leader)**：
    - 依赖 `users` 表已添加 `score` 字段
    - 需求详情页引用组长实现的回复列表
    - 侧边栏需要添加“发布悬赏”和“需求悬赏”入口（已由组长完成）

2. **对成员A (Member A)**：
    - 积分系统独立运行，无直接依赖
    - 排行榜功能可独立访问

3. **对成员B (Member B)**：
    - 依赖 `users` 表和 `session` 用户信息
    - 积分系统使用 `sessionScope.user` 获取当前用户
    - 登录状态由成员B的 `AuthFilter` 统一管理

4. **对成员C (Member C)**：
    - 需求发布依赖 `categories` 表获取板块列表
    - 板块名称在需求列表中展示

### 依赖本模块的模块

1. **组长**：需求详情页中的回复功能复用 `PostServlet` 的 `/post/reply` 接口
2. **成员B**：个人中心需要显示用户积分（已添加积分显示）

## 测试建议

### 1. 需求发布测试
- 测试正常发布需求（积分充足）
- 测试积分不足时发布失败
- 测试发布后积分是否正确扣除
- 测试发布后积分流水是否记录

### 2. 采纳回复测试
- 测试发布者正常采纳回复
- 测试非发布者尝试采纳（应被拒绝）
- 测试已结束的需求再次采纳（应被拒绝）
- 测试采纳自己回复（应被拒绝）
- 测试采纳后积分是否正确转移
- 测试采纳后积分流水是否记录

### 3. 积分记录测试
- 测试查看积分记录（需登录）
- 测试积分流水正确显示收入和支出
- 测试未登录访问重定向到登录页

### 4. 排行榜测试
- 测试排行榜正确显示积分排序
- 测试积分变动后排行榜实时更新
- 测试当前用户高亮显示
- 测试前三名特殊样式

### 5. 事务一致性测试
- 模拟发布需求过程中数据库异常，验证积分不会异常扣除
- 模拟采纳回复过程中数据库异常，验证积分不会异常转移

## 注意事项

1. **事务原子性**：发布需求和采纳回复均使用数据库事务，确保积分扣除/增加与记录流水同步执行，防止积分异常
2. **并发控制**：采纳回复使用 `SELECT ... FOR UPDATE` 行锁，防止同一需求被重复采纳
3. **积分校验**：发布需求前检查用户积分是否充足，不足时返回错误提示
4. **权限控制**：采纳回复接口验证当前用户是否为需求发布者，非发布者禁止操作
5. **状态控制**：已结束的需求不可再次采纳，通过 `status` 字段控制
6. **编码**：所有请求使用 UTF-8 编码，由 `EncodingFilter` 统一处理
7. **SQL注入防护**：所有数据库查询均使用 `PreparedStatement` 参数化查询

## 积分规则汇总

| 操作 | 积分变动 | 说明 |
|------|----------|------|
| 发布悬赏需求 | -悬赏分 | 发布时从发布者账户扣除 |
| 回复被采纳 | +悬赏分 | 需求发布者采纳回复时获得 |
| 积分初始值 | 0 | 新注册用户初始积分为0 |

> 注：发帖、回复、签到等积分规则由其他模块负责实现。