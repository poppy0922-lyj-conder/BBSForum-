<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<h2 style="margin-bottom:20px;"><i class="fa fa-edit"></i> 编辑个人资料</h2>

<c:if test="${not empty error}">
    <div class="alert alert-danger">
        <i class="fa fa-exclamation-circle"></i> ${error}
    </div>
</c:if>

<form action="${pageContext.request.contextPath}/user/profile/edit" method="post">
    <div class="form-group">
        <label for="phone">联系方式</label>
        <input type="text" name="phone" id="phone" class="form-input"
               value="${user.phone}" placeholder="请输入手机号" maxlength="20">
    </div>

    <div class="form-group">
        <label for="jobType">工作性质</label>
        <input type="text" name="jobType" id="jobType" class="form-input"
               value="${user.jobType}" placeholder="如：学生、程序员、设计师等" maxlength="50">
    </div>

    <div class="form-group">
        <label for="jobLocation">工作地点</label>
        <input type="text" name="jobLocation" id="jobLocation" class="form-input"
               value="${user.jobLocation}" placeholder="如：北京、上海等" maxlength="100">
    </div>

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

    <div style="display:flex;gap:12px;">
        <button type="submit" class="btn btn-primary">
            <i class="fa fa-save"></i> 保存
        </button>
        <a href="${pageContext.request.contextPath}/user/profile"
           class="btn" style="background:#e5e7eb;color:#475569;">取消</a>
    </div>
</form>
