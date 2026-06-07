<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="mb-6">
    <h2 class="text-xl font-bold text-gray-800 flex items-center gap-2">
        <i class="fa fa-edit text-blue-500"></i> 编辑用户
    </h2>
</div>

<c:choose>
    <c:when test="${not empty editUser}">
        <c:if test="${param.error == 'self'}">
            <div class="mb-4 px-4 py-3 bg-red-50 border border-red-200 text-red-600 text-sm rounded-lg">
                <i class="fa fa-exclamation-circle"></i> 不能修改当前登录管理员的角色
            </div>
        </c:if>

        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 max-w-xl">
            <form action="${pageContext.request.contextPath}/admin/users/edit" method="post">
                <input type="hidden" name="id" value="${editUser.id}">

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1">用户名</label>
                    <input type="text" value="${editUser.username}" disabled
                           class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg bg-gray-50 text-gray-500 cursor-not-allowed">
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1">联系方式</label>
                    <input type="text" name="phone" value="${editUser.phone}"
                           class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400 transition"
                           placeholder="手机号（可选）">
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1">工作性质</label>
                    <input type="text" name="jobType" value="${editUser.jobType}"
                           class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400 transition"
                           placeholder="如：全职、兼职（可选）">
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1">工作地点</label>
                    <input type="text" name="jobLocation" value="${editUser.jobLocation}"
                           class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400 transition"
                           placeholder="如：北京（可选）">
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1">角色</label>
                    <select name="role"
                            class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400 transition ${editUser.id == sessionScope.user.id ? 'bg-gray-50 cursor-not-allowed' : ''}"
                            ${editUser.id == sessionScope.user.id ? 'disabled' : ''}>
                        <option value="user" ${editUser.role == 'user' ? 'selected' : ''}>普通用户</option>
                        <option value="admin" ${editUser.role == 'admin' ? 'selected' : ''}>管理员</option>
                    </select>
                    <c:if test="${editUser.id == sessionScope.user.id}">
                        <input type="hidden" name="role" value="${editUser.role}">
                    </c:if>
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-medium text-gray-700 mb-1">积分</label>
                    <input type="number" name="score" value="${editUser.score}" min="0"
                           class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400 transition">
                </div>

                <div class="flex items-center gap-3">
                    <button type="submit"
                            class="px-5 py-2 text-sm text-white bg-blue-500 rounded-lg hover:bg-blue-600 transition cursor-pointer">
                        <i class="fa fa-save"></i> 保存修改
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/users"
                       class="px-5 py-2 text-sm text-gray-600 bg-gray-100 border border-gray-200 rounded-lg hover:bg-gray-200 transition no-underline">
                        取消
                    </a>
                </div>
            </form>
        </div>
    </c:when>
    <c:otherwise>
        <div class="bg-red-50 border border-red-200 rounded-xl p-4 text-sm text-red-600">
            <i class="fa fa-exclamation-circle"></i> 未找到该用户
        </div>
    </c:otherwise>
</c:choose>
