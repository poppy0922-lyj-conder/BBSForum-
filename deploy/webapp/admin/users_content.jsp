<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="mb-6">
    <h2 class="text-xl font-bold text-gray-800 flex items-center gap-2">
        <i class="fa fa-users text-blue-500"></i> 用户管理
        <span class="text-sm font-normal text-gray-500 bg-gray-100 px-2 py-0.5 rounded-full">共 ${totalUsers} 人</span>
    </h2>
</div>

<!-- 错误提示 -->
<c:if test="${not empty param.error}">
    <c:choose>
        <c:when test="${param.error == 'self'}">
            <div class="mb-4 px-4 py-3 bg-red-50 border border-red-200 text-red-600 text-sm rounded-lg">
                <i class="fa fa-exclamation-circle"></i> 不能对当前登录的管理员账号执行此操作
            </div>
        </c:when>
        <c:when test="${param.error == 'hasPosts'}">
            <div class="mb-4 px-4 py-3 bg-red-50 border border-red-200 text-red-600 text-sm rounded-lg">
                <i class="fa fa-exclamation-circle"></i> 该用户名下有帖子，无法删除
            </div>
        </c:when>
        <c:when test="${param.error == 'notFound'}">
            <div class="mb-4 px-4 py-3 bg-red-50 border border-red-200 text-red-600 text-sm rounded-lg">
                <i class="fa fa-exclamation-circle"></i> 用户不存在
            </div>
        </c:when>
    </c:choose>
</c:if>

<!-- 搜索栏 -->
<div class="mb-4">
    <form method="get" action="${pageContext.request.contextPath}/admin/users" class="flex gap-2">
        <input type="text" name="keyword" value="${fn:escapeXml(keyword)}"
               placeholder="搜索用户名..."
               class="flex-1 px-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-300 focus:border-blue-400" />
        <button type="submit" class="px-4 py-2 bg-blue-500 text-white text-sm rounded-lg hover:bg-blue-600 transition cursor-pointer">
            <i class="fa fa-search"></i> 搜索
        </button>
        <c:if test="${not empty keyword}">
            <a href="${pageContext.request.contextPath}/admin/users"
               class="px-4 py-2 bg-gray-100 text-gray-600 text-sm rounded-lg hover:bg-gray-200 transition no-underline">
                清除
            </a>
        </c:if>
    </form>
</div>

<!-- 用户表格 -->
<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
            <tr>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">用户名</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">联系方式</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">角色</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">积分</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">注册时间</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
            </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
            <c:forEach var="user" items="${userList}">
                <tr class="hover:bg-blue-50/30 transition duration-150">
                    <td class="px-5 py-3 text-sm text-gray-600">${user.id}</td>
                    <td class="px-5 py-3 text-sm text-gray-800 font-medium">
                        ${user.username}
                        <c:if test="${user.id == sessionScope.user.id}">
                            <span class="text-xs text-blue-500 font-normal ml-1">(当前登录)</span>
                        </c:if>
                    </td>
                    <td class="px-5 py-3 text-sm text-gray-600">${user.phone}</td>
                    <td class="px-5 py-3">
                        <c:choose>
                            <c:when test="${user.role == 'admin'}">
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-700">管理员</span>
                            </c:when>
                            <c:otherwise>
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-600">用户</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="px-5 py-3 text-sm text-gray-600">${user.score}</td>
                    <td class="px-5 py-3 text-sm text-gray-500">${fn:substring(user.createdAt, 0, 16)}</td>
                    <td class="px-5 py-3 whitespace-nowrap">
                        <c:if test="${user.id != sessionScope.user.id}">
                        <div class="flex items-center gap-2">
                            <!-- 切换角色 -->
                            <c:choose>
                                <c:when test="${user.role == 'admin'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/users/toggleRole" class="inline">
                                        <input type="hidden" name="id" value="${user.id}" />
                                        <button type="submit" class="p-1.5 text-amber-600 bg-amber-50 border border-amber-200 rounded-lg hover:bg-amber-100 transition cursor-pointer"
                                                title="降级为普通用户">
                                            <i class="fa fa-arrow-down"></i>
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <form method="post" action="${pageContext.request.contextPath}/admin/users/toggleRole" class="inline">
                                        <input type="hidden" name="id" value="${user.id}" />
                                        <button type="submit" class="p-1.5 text-green-600 bg-green-50 border border-green-200 rounded-lg hover:bg-green-100 transition cursor-pointer"
                                                title="升级为管理员">
                                            <i class="fa fa-arrow-up"></i>
                                        </button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                            <!-- 编辑 -->
                            <a href="${pageContext.request.contextPath}/admin/users/edit?id=${user.id}"
                               class="p-1.5 text-blue-600 bg-blue-50 border border-blue-200 rounded-lg hover:bg-blue-100 transition inline-flex items-center"
                               title="编辑用户">
                                <i class="fa fa-edit"></i>
                            </a>
                            <!-- 删除 -->
                            <form method="post" action="${pageContext.request.contextPath}/admin/users/delete" class="inline">
                                <input type="hidden" name="id" value="${user.id}" />
                                <button type="button" onclick="confirmDeleteUser(this, '${fn:escapeXml(user.username)}')"
                                        class="p-1.5 text-red-600 bg-red-50 border border-red-200 rounded-lg hover:bg-red-100 transition cursor-pointer"
                                        title="删除用户">
                                    <i class="fa fa-trash-o"></i>
                                </button>
                            </form>
                        </div>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty userList}">
                <tr>
                    <td colspan="7" class="px-5 py-12 text-center text-gray-400">
                        <i class="fa fa-inbox text-3xl mb-2 block"></i>
                        暂无用户数据
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>

<!-- 分页 -->
<c:if test="${totalPages > 1}">
    <div class="flex items-center justify-center gap-2 mt-6">
        <c:if test="${currentPage > 1}">
            <a href="${pageContext.request.contextPath}/admin/users?page=${currentPage - 1}<c:if test='${not empty keyword}'>&amp;keyword=${fn:escapeXml(keyword)}</c:if>"
               class="px-3 py-1.5 text-sm bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition no-underline">
                上一页
            </a>
        </c:if>
        <c:forEach begin="1" end="${totalPages}" var="i">
            <c:choose>
                <c:when test="${i == currentPage}">
                    <span class="px-3 py-1.5 text-sm bg-blue-500 text-white rounded-lg">${i}</span>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/admin/users?page=${i}<c:if test='${not empty keyword}'>&amp;keyword=${fn:escapeXml(keyword)}</c:if>"
                       class="px-3 py-1.5 text-sm bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition no-underline">
                            ${i}
                    </a>
                </c:otherwise>
            </c:choose>
        </c:forEach>
        <c:if test="${currentPage < totalPages}">
            <a href="${pageContext.request.contextPath}/admin/users?page=${currentPage + 1}<c:if test='${not empty keyword}'>&amp;keyword=${fn:escapeXml(keyword)}</c:if>"
               class="px-3 py-1.5 text-sm bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition no-underline">
                下一页
            </a>
        </c:if>
    </div>
</c:if>

<script>
function confirmDeleteUser(btn, username) {
    showConfirm('确定要删除用户「' + username + '」吗？删除后不可恢复。').then(function(ok) {
        if (ok) {
            var form = btn.closest('form');
            if (form) form.submit();
        }
    });
}
</script>
