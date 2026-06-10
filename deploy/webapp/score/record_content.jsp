<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<h2 style="margin-bottom:20px;"><i class="fa fa-history"></i> 积分记录</h2>

<div class="card" style="margin-bottom:20px;text-align:center;">
    <div style="font-size:36px;color:#3b82f6;font-weight:bold;">
        <i class="fa fa-diamond"></i> ${totalScore}
    </div>
    <div style="color:#94a3b8;font-size:14px;">当前积分</div>
</div>

<table class="data-table">
    <thead>
        <tr>
            <th>时间</th>
            <th>积分变动</th>
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

<div class="pagination">${pagination}</div>
