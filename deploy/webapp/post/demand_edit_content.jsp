<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 面包屑 -->
<div class="flex items-center gap-2 text-sm text-gray-400 mb-4">
    <a href="${pageContext.request.contextPath}/" class="text-gray-500 hover:text-blue-500 no-underline">首页</a>
    <span>/</span>
    <a href="${pageContext.request.contextPath}/demand" class="text-gray-500 hover:text-blue-500 no-underline">需求列表</a>
    <span>/</span>
    <a href="${pageContext.request.contextPath}/demand/detail?id=${demand.id}" class="text-gray-500 hover:text-blue-500 no-underline">需求详情</a>
    <span>/</span>
    <span class="text-gray-700">编辑需求</span>
</div>

<div class="mb-4 pb-3 border-b border-gray-200">
    <h2 class="text-lg font-semibold text-gray-900">
        <i class="fa fa-edit mr-1 text-orange-500"></i> 编辑需求
    </h2>
</div>

<div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
    <form action="${pageContext.request.contextPath}/demand/update" method="post" class="space-y-4">
        <input type="hidden" name="id" value="${demand.id}">
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">标题 <span class="text-red-500">*</span></label>
            <input type="text" name="title" value="${demand.title}" required maxlength="100"
                   class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200">
        </div>
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">详细描述 <span class="text-red-500">*</span></label>
            <textarea name="content" required rows="8" maxlength="2000"
                      class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 resize-y">${demand.content}</textarea>
        </div>
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">悬赏积分</label>
            <div class="text-sm text-gray-500 py-2 px-3 bg-gray-50 rounded border border-gray-200">
                <i class="fa fa-diamond text-orange-400 mr-1"></i> ${demand.score} 积分（发布后不可修改）
            </div>
        </div>
        <div class="pt-2 flex items-center gap-3">
            <button type="submit" class="px-6 py-2 text-sm bg-blue-500 text-white rounded hover:bg-blue-600 transition cursor-pointer border-none">
                <i class="fa fa-save mr-1"></i> 保存修改
            </button>
            <a href="${pageContext.request.contextPath}/demand/detail?id=${demand.id}" class="text-sm text-gray-500 hover:text-gray-700 no-underline">取消</a>
        </div>
    </form>
</div>
