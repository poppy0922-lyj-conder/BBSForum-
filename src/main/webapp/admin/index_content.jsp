<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="mb-6">
    <h2 class="text-xl font-bold text-gray-800 flex items-center gap-2">
        <i class="fa fa-dashboard text-blue-500"></i> 管理员后台
    </h2>
</div>

<!-- 统计卡片 -->
<div class="grid grid-cols-3 gap-4 mb-6">
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
        <div class="text-3xl font-bold text-blue-500">${postCount}</div>
        <div class="text-sm text-gray-400 mt-1">帖子总数</div>
    </div>
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
        <div class="text-3xl font-bold text-green-500">${userCount}</div>
        <div class="text-sm text-gray-400 mt-1">用户总数</div>
    </div>
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
        <div class="text-3xl font-bold text-amber-500">${categoryCount}</div>
        <div class="text-sm text-gray-400 mt-1">板块数量</div>
    </div>
</div>

<!-- 快捷入口 -->
<div class="grid grid-cols-2 gap-4">
    <a href="${pageContext.request.contextPath}/admin/categories"
       class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center no-underline hover:shadow-md transition block">
        <i class="fa fa-th-list text-2xl text-blue-500"></i>
        <p class="text-gray-700 mt-2 text-sm">板块管理</p>
    </a>
    <a href="${pageContext.request.contextPath}/admin/post/manage"
       class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center no-underline hover:shadow-md transition block">
        <i class="fa fa-file-text text-2xl text-green-500"></i>
        <p class="text-gray-700 mt-2 text-sm">帖子管理</p>
    </a>
</div>
