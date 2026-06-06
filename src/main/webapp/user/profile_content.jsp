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

<!-- 积分卡片 -->
<div class="card" style="margin-top:16px;text-align:center;padding:24px;">
    <div style="font-size:36px;color:#3b82f6;font-weight:bold;">
        <i class="fa fa-diamond"></i> ${user.score}
    </div>
    <div style="color:#94a3b8;font-size:14px;">当前积分</div>
</div>

<!-- 最近积分记录 -->
<div class="card" style="margin-top:16px;">
    <h3 style="margin-bottom:12px;"><i class="fa fa-history"></i> 最近积分记录</h3>
    <table class="data-table">
        <thead>
            <tr>
                <th>时间</th>
                <th>积分</th>
                <th>原因</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty scoreLogs}">
                    <tr><td colspan="3" style="text-align:center;color:#94a3b8;">暂无积分记录</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="log" items="${scoreLogs}">
                        <tr>
                            <td>${log.createdAt}</td>
                            <td style="color:${log.score > 0 ? '#10b981' : '#ef4444'};font-weight:600;">
                                ${log.score > 0 ? '+' : ''}${log.score}
                            </td>
                            <td>${log.reason}</td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
    <div style="margin-top:8px;text-align:right;">
        <a href="${pageContext.request.contextPath}/score/record" class="btn btn-sm btn-outline">
            <i class="fa fa-list"></i> 查看全部
        </a>
    </div>
</div>

<div style="margin-top:16px; display:flex; gap:8px; flex-wrap:wrap;">
    <a href="${pageContext.request.contextPath}/user/profile/edit" class="btn btn-primary">
        <i class="fa fa-edit"></i> 编辑资料
    </a>
    <a href="${pageContext.request.contextPath}/user/profile/follows" class="btn btn-outline">
        <i class="fa fa-users"></i> 我的关注
    </a>
</div>
