<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
    <h2><i class="fa fa-file-text"></i> 帖子管理（置顶/加精/编辑）</h2>
    <a href="${pageContext.request.contextPath}/admin" class="btn btn-sm" style="background:#e5e7eb;color:#475569;">
        <i class="fa fa-arrow-left"></i> 返回后台
    </a>
</div>

<table class="data-table">
    <thead>
        <tr>
            <th>ID</th>
            <th>标题</th>
            <th>作者</th>
            <th>板块</th>
            <th>置顶</th>
            <th>精华</th>
            <th>操作</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="post" items="${postList}">
            <tr>
                <td>${post.id}</td>
                <td><a href="${pageContext.request.contextPath}/post/detail?id=${post.id}">${post.title}</a></td>
                <td>${post.authorName}</td>
                <td>${post.categoryName}</td>
                <td>
                    <c:choose>
                        <c:when test="${post.isTop == 2}"><span style="color:#ef4444;font-weight:bold;">全局</span></c:when>
                        <c:when test="${post.isTop == 1}"><span style="color:#f59e0b;font-weight:bold;">板块</span></c:when>
                        <c:otherwise><span style="color:#94a3b8;">否</span></c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <c:choose>
                        <c:when test="${post.isElite == 1}"><span style="color:#eb2f96;font-weight:bold;">是</span></c:when>
                        <c:otherwise><span style="color:#94a3b8;">否</span></c:otherwise>
                    </c:choose>
                </td>
                <td style="white-space:nowrap;">
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
                    <%-- 编辑按钮 --%>
                    <a href="${pageContext.request.contextPath}/post/edit?id=${post.id}" class="btn btn-sm btn-primary" title="编辑帖子">
                        <i class="fa fa-edit"></i>
                    </a>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty postList}">
            <tr><td colspan="7" style="text-align:center;color:#94a3b8;padding:40px;">暂无帖子</td></tr>
        </c:if>
    </tbody>
</table>

<%-- 分页导航 --%>
<c:if test="${totalPages > 1}">
    <div class="pagination" style="display:flex;align-items:center;justify-content:center;gap:4px;margin-top:20px;">
        <c:if test="${currentPage > 1}">
            <a href="${pageContext.request.contextPath}/admin/post/manage?page=${currentPage - 1}" class="btn btn-sm" style="background:#e5e7eb;color:#475569;">上一页</a>
        </c:if>
        <c:forEach begin="1" end="${totalPages}" var="i">
            <c:choose>
                <c:when test="${i == currentPage}">
                    <span style="padding:4px 10px;background:#3b82f6;color:white;border-radius:4px;font-size:13px;">${i}</span>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/admin/post/manage?page=${i}" style="padding:4px 10px;background:#e5e7eb;color:#475569;border-radius:4px;font-size:13px;text-decoration:none;">${i}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>
        <c:if test="${currentPage < totalPages}">
            <a href="${pageContext.request.contextPath}/admin/post/manage?page=${currentPage + 1}" class="btn btn-sm" style="background:#e5e7eb;color:#475569;">下一页</a>
        </c:if>
    </div>
</c:if>
