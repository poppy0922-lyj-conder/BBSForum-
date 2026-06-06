<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="mb-6 flex flex-wrap items-center justify-between gap-3">
    <h2 class="text-xl font-bold text-gray-800 flex items-center gap-2">
        <i class="fa fa-edit text-blue-500"></i> 编辑板块
    </h2>
    <a href="${pageContext.request.contextPath}/admin/categories"
       class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-gray-600 bg-gray-100 border border-gray-200 rounded-lg hover:bg-gray-200 transition no-underline">
        <i class="fa fa-arrow-left"></i> 返回列表
    </a>
</div>

<c:choose>
    <c:when test="${not empty category}">
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 max-w-xl">
            <form action="${pageContext.request.contextPath}/admin/categories/edit" method="post">
                <input type="hidden" name="id" value="${category.id}">

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1">板块名称</label>
                    <input type="text" name="name" value="${category.name}" required
                           class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400 transition">
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-medium text-gray-700 mb-1">描述</label>
                    <input type="text" name="description" value="${category.description}"
                           class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400 transition"
                           placeholder="请输入板块描述（可选）">
                </div>

                <div class="flex items-center gap-3">
                    <button type="submit"
                            class="px-5 py-2 text-sm text-white bg-blue-500 rounded-lg hover:bg-blue-600 transition cursor-pointer">
                        <i class="fa fa-save"></i> 保存修改
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/categories"
                       class="px-5 py-2 text-sm text-gray-600 bg-gray-100 border border-gray-200 rounded-lg hover:bg-gray-200 transition no-underline">
                        取消
                    </a>
                </div>
            </form>
        </div>
    </c:when>
    <c:otherwise>
        <div class="bg-red-50 border border-red-200 rounded-xl p-4 text-sm text-red-600">
            <i class="fa fa-exclamation-circle"></i> 未找到该板块
        </div>
    </c:otherwise>
</c:choose>
