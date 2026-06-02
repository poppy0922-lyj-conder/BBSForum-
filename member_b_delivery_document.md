# 成员B功能交付文档

## 概述

本文档描述了成员B在BBS论坛系统中实现的用户系统功能，包括用户注册、登录、退出和个人资料管理功能，并实现了基于BCrypt的密码加密存储和Session鉴权拦截器。这些功能为整个系统提供用户身份认证与权限管控的基础支撑。

## 功能模块

### 1. 用户注册 (Registration)

**功能描述**：
- 新用户可以注册成为BBS用户，填写用户名、密码、联系方式、工作性质、工作地点等信息
- 密码使用BCrypt算法加密存储，不存明文
- 注册成功后跳转登录页并显示成功提示
- 后端校验用户名唯一、两次密码一致

**相关文件**：
- `src/main/java/com/bbs/controller/UserServlet.java` - 后端控制器
- `src/main/webapp/user/register.jsp` - 注册页面
- `src/main/webapp/user/register_content.jsp` - 注册内容页面
- `src/main/java/com/bbs/util/PasswordUtil.java` - 密码加密工具类

### 2. 用户登录 (Login)

**功能描述**：
- 用户使用用户名和密码登录系统
- 登录成功后session中保存用户完整信息（用户名、角色、联系方式、工作性质、工作地点等）
- 支持BCrypt hash校验和旧明文密码兼容
- 旧明文密码首次登录后自动升级为BCrypt加密

**相关文件**：
- `src/main/java/com/bbs/controller/UserServlet.java` - 后端控制器
- `src/main/webapp/user/login.jsp` - 登录页面
- `src/main/webapp/user/login_content.jsp` - 登录内容页面

### 3. 退出登录 (Logout)

**功能描述**：
- 用户可以安全退出系统
- 清除当前session会话
- 退出后重定向到首页

**相关文件**：
- `src/main/java/com/bbs/controller/UserServlet.java` - 后端控制器

### 4. 个人中心 (Profile)

**功能描述**：
- 登录后可查看个人资料信息
- 显示用户名、联系方式、工作性质、工作地点、注册时间
- 每次访问从数据库刷新数据保证信息最新
- 资料更新后显示"资料已更新"提示

**相关文件**：
- `src/main/java/com/bbs/controller/UserProfileServlet.java` - 后端控制器
- `src/main/webapp/user/profile.jsp` - 个人中心页面
- `src/main/webapp/user/profile_content.jsp` - 个人中心内容页面

### 5. 资料编辑 (Profile Edit)

**功能描述**：
- 用户可以修改联系方式、工作性质、工作地点
- 支持可选修改密码（非空时才更新）
- 密码修改同样使用BCrypt加密
- 使用数据库事务确保资料更新和密码更新的原子性

**相关文件**：
- `src/main/java/com/bbs/controller/UserProfileServlet.java` - 后端控制器
- `src/main/webapp/user/profile_edit.jsp` - 编辑页面
- `src/main/webapp/user/profile_edit_content.jsp` - 编辑内容页面

### 6. Session鉴权拦截 (AuthFilter)

**功能描述**：
- 拦截未登录用户访问个人中心（`/user/profile`、`/user/profile/*`），重定向到登录页
- 拦截未登录用户访问后台（`/admin`、`/admin/*`），重定向到登录页
- 已登录但非管理员用户访问后台返回403禁止访问

**相关文件**：
- `src/main/java/com/bbs/filter/AuthFilter.java` - 鉴权拦截器

## API 端点说明

### 用户注册/登录 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/user/register` | GET | 显示注册页 | 无 | 注册表单 |
| `/user/register` | POST | 提交注册 | username, password, password2, phone, jobType, jobLocation | 重定向到登录页或返回注册页并显示错误 |
| `/user/login` | GET | 显示登录页 | 无 | 登录表单 |
| `/user/login` | POST | 提交登录 | username, password | 重定向首页并建立session或返回登录页并显示错误 |
| `/logout` | GET | 退出登录 | 无 | 清除session并重定向首页 |

### 个人中心 API

| URL | 方法 | 功能 | 参数 | 返回 |
|-----|------|------|------|------|
| `/user/profile` | GET | 查看个人资料 | 无（需登录） | 个人资料页面 |
| `/user/profile/edit` | GET | 显示编辑表单 | 无（需登录） | 编辑表单（回显当前资料） |
| `/user/profile/edit` | POST | 保存修改 | phone, jobType, jobLocation, password(可选), password2 | 重定向到个人中心或返回编辑页并显示错误 |

### 鉴权拦截规则（AuthFilter）

| URL Pattern | 条件 | 响应 |
|-------------|------|------|
| `/user/profile`, `/user/profile/*` | 未登录（session无user） | 重定向 `/user/login` |
| `/admin`, `/admin/*` | 未登录 | 重定向 `/user/login` |
| `/admin`, `/admin/*` | 已登录但非管理员 | HTTP 403 |

## 数据库表结构

### users 表

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) DEFAULT '',
    job_type VARCHAR(50) DEFAULT '',
    job_location VARCHAR(100) DEFAULT '',
    role ENUM('user','admin') NOT NULL DEFAULT 'user',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**字段说明**：
- `id`: 用户唯一标识
- `username`: 用户名（唯一）
- `password`: 加密密码（BCrypt hash，`$2a$`开头）
- `phone`: 联系方式
- `job_type`: 工作性质
- `job_location`: 工作地点
- `role`: 角色（user或admin）
- `created_at`: 注册时间

## 前端集成说明

### 1. 登录页注册成功提示

注册成功后跳转登录页时，通过URL参数`registered=1`显示绿色提示：

```jsp
<c:if test="${param.registered == '1'}">
    <div class="flex items-center gap-2 bg-green-50 text-green-700 border border-green-200 rounded px-4 py-2.5 text-sm mb-5">
        <i class="fa fa-check-circle"></i> 注册成功，请登录
    </div>
</c:if>
```

### 2. 资料编辑页密码确认

编辑资料页面包含新密码和确认密码两个输入框，后端校验两次输入一致：

```jsp
<div class="form-group">
    <label for="password">新密码（不修改请留空）</label>
    <input type="password" name="password" id="password" class="form-input"
           placeholder="请输入新密码">
</div>

<div class="form-group">
    <label for="password2">确认新密码</label>
    <input type="password" name="password2" id="password2" class="form-input"
           placeholder="再次输入新密码">
</div>
```

### 3. 个人中心资料展示

个人中心页面通过`${user}`对象展示用户基本信息，支持空值兜底显示"未填写"：

```jsp
<table class="data-table">
    <tr>
        <td style="width:120px;font-weight:600;">用户名</td>
        <td>${user.username}</td>
    </tr>
    <tr>
        <td style="width:120px;font-weight:600;">联系方式</td>
        <td>${empty user.phone ? '未填写' : user.phone}</td>
    </tr>
    <tr>
        <td style="width:120px;font-weight:600;">工作性质</td>
        <td>${empty user.jobType ? '未填写' : user.jobType}</td>
    </tr>
    <tr>
        <td style="width:120px;font-weight:600;">工作地点</td>
        <td>${empty user.jobLocation ? '未填写' : user.jobLocation}</td>
    </tr>
    <tr>
        <td style="width:120px;font-weight:600;">注册时间</td>
        <td>${user.createdAt}</td>
    </tr>
</table>
```

## 使用示例

### 1. 注册新用户

**用户操作**：
1. 访问 `/user/register`
2. 填写用户名、密码、联系方式等信息
3. 点击"注册"

**后端处理**：
```java
// 在UserServlet中
handleRegister(request, response);
```

### 2. 用户登录

**用户操作**：
1. 访问 `/user/login`
2. 输入用户名和密码
3. 点击"登录"

**后端处理**：
```java
// 在UserServlet中
handleLogin(request, response);
```

### 3. 编辑个人资料

**用户操作**：
1. 登录后访问 `/user/profile`
2. 点击"编辑资料"
3. 修改联系方式、工作性质、工作地点
4. 可选输入新密码和确认密码
5. 点击"保存"

**后端处理**：
```java
// 在UserProfileServlet中
doPost(request, response);
```

## 依赖关系

### 对其他成员的影响

1. **对组长 (Team Leader)**：
   - 需要确保`users`表已创建
   - 需要保证导航栏和侧边栏可以访问`sessionScope.user`（如"管理"入口需要user.role判断）
   - 发帖和回帖功能依赖`sessionScope.user`判断登录态

2. **对成员A (Member A)**：
   - 帖子置顶和加精功能仅管理员可操作，可通过`sessionScope.user.role == 'admin'`判断
   - 搜索功能不受影响

3. **对成员C (Member C)**：
   - 板块管理功能（`/admin/*`）受AuthFilter统一鉴权保护
   - 不需要自行实现管理员权限校验

4. **对成员D (Member D)**：
   - 需求悬赏发布/采纳需要登录态，可通过`sessionScope.user`判断
   - 积分流水关联`user_id`字段，使用users表

## 测试建议

### 1. 注册测试
- 测试正常注册
- 测试重复用户名注册
- 测试两次密码不一致
- 测试空用户名或密码

### 2. 登录测试
- 测试新注册用户登录
- 测试默认账号登录
- 测试错误密码
- 测试退出后重新登录

### 3. 个人中心测试
- 测试未登录访问被拦截
- 测试登录后正常查看信息
- 测试编辑资料后返回刷新

### 4. 资料编辑测试
- 测试修改联系方式、工作性质、工作地点
- 测试修改密码后重新登录
- 测试两次新密码不一致

### 5. 鉴权拦截测试
- 测试普通用户访问后台
- 测试管理员访问后台
- 测试退出后访问个人中心

## 注意事项

1. **密码安全**：新注册和改密均使用BCrypt加密（`org.mindrot:jbcrypt:0.4`）。`init.sql`中默认测试账号的密码为明文，首次登录时自动升级为BCrypt hash。
2. **Session结构**：登录后session中存储的user为`Map<String, Object>`格式，包含id、username和role等字段。其他模块均依赖此结构，修改时务必保证兼容。
3. **AuthFilter覆盖范围**：目前Filter保护`/user/profile*`和`/admin/*`路径。发帖、回帖等功能的登录判断仍由各自Servlet自行处理。
4. **编码**：通过`EncodingFilter`统一处理UTF-8编码，后端和JSP页面均使用UTF-8。
