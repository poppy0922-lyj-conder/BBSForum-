<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<h2 style="margin-bottom:20px;"><i class="fa fa-user"></i> 个人中心</h2>

<c:if test="${not empty message}">
    <div class="alert alert-success">
        <i class="fa fa-check-circle"></i> ${message}
    </div>
</c:if>

<div class="card">
    <h3 style="margin-bottom:16px;"><i class="fa fa-id-card"></i> 基本信息</h3>
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
</div>

<div style="margin-top:16px; display:flex; gap:8px; flex-wrap:wrap;">
    <a href="${pageContext.request.contextPath}/user/profile/edit" class="btn btn-primary">
        <i class="fa fa-edit"></i> 编辑资料
    </a>
    <a href="${pageContext.request.contextPath}/user/profile/follows" class="btn btn-outline">
        <i class="fa fa-users"></i> 我的关注
    </a>
</div>
