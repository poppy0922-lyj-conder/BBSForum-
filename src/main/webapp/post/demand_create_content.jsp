<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 发布悬赏 -->
<div class="mb-4 pb-3 border-b border-gray-200">
    <h2 class="text-lg font-semibold text-gray-900">
        <i class="fa fa-gift mr-1 text-orange-500"></i> 发布悬赏
    </h2>
</div>

<div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
    <form action="${pageContext.request.contextPath}/demand/create" method="post" class="space-y-4">
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">标题 <span class="text-red-500">*</span></label>
            <input type="text" name="title" required maxlength="100"
                   class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200"
                   placeholder="简要描述你的需求">
        </div>
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">详细描述 <span class="text-red-500">*</span></label>
            <textarea name="content" required rows="6" maxlength="2000"
                      class="w-full px-3 py-2 text-sm border border-gray-300 rounded focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 resize-y"
                      placeholder="详细说明需求内容、期望的答案或解决方案..."></textarea>
        </div>
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">悬赏积分</label>
            <input type="number" name="score" min="1" value="10"
                   class="w-32 px-3 py-2 text-sm border border-gray-300 rounded focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200"
                   placeholder="积分">
            <p class="text-xs text-gray-400 mt-1">设置悬赏积分吸引更多人解答</p>
        </div>
        <div class="pt-2">
            <button type="submit" class="px-6 py-2 text-sm bg-orange-500 text-white rounded hover:bg-orange-600 transition cursor-pointer">
                <i class="fa fa-send mr-1"></i> 发布需求
            </button>
            <a href="${pageContext.request.contextPath}/demand" class="ml-3 text-sm text-gray-500 hover:text-gray-700 no-underline">取消</a>
        </div>
    </form>
</div>
