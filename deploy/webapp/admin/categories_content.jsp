<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="mb-6">
    <h2 class="text-xl font-bold text-gray-800 flex items-center gap-2">
        <i class="fa fa-th-list text-blue-500"></i> 板块管理
        <span class="text-sm font-normal text-gray-500 bg-gray-100 px-2 py-0.5 rounded-full">${fn:length(categoryList)} 个板块</span>
    </h2>
</div>

<!-- 添加板块 -->
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5 mb-6">
    <h3 class="text-sm font-semibold text-gray-700 mb-3"><i class="fa fa-plus-circle text-green-500"></i> 添加新板块</h3>
    <form action="${pageContext.request.contextPath}/admin/categories/add" method="post"
          class="flex flex-wrap items-end gap-3">
        <div class="flex-1 min-w-[180px]">
            <label class="block text-xs text-gray-500 mb-1">板块名称</label>
            <input type="text" name="name" required placeholder="请输入板块名称"
                   class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400 transition">
        </div>
        <div class="flex-[2] min-w-[240px]">
            <label class="block text-xs text-gray-500 mb-1">描述</label>
            <input type="text" name="description" placeholder="请输入板块描述（可选）"
                   class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400 transition">
        </div>
        <button type="submit"
                class="px-4 py-2 text-sm text-white bg-blue-500 rounded-lg hover:bg-blue-600 transition cursor-pointer whitespace-nowrap">
            <i class="fa fa-plus"></i> 添加
        </button>
    </form>
</div>

<!-- 板块列表 -->
<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                    <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">板块名称</th>
                    <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">描述</th>
                    <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">排序</th>
                    <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">创建时间</th>
                    <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                <c:forEach var="cat" items="${categoryList}">
                    <tr class="hover:bg-blue-50/30 transition duration-150">
                        <td class="px-5 py-3 text-sm text-gray-600">${cat.id}</td>
                        <td class="px-5 py-3 text-sm font-medium text-gray-800">${cat.name}</td>
                        <td class="px-5 py-3 text-sm text-gray-500">${cat.description}</td>
                        <td class="px-5 py-3">
                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-600">${cat.sortOrder}</span>
                        </td>
                        <td class="px-5 py-3 text-sm text-gray-500">${cat.createdAt}</td>
                        <td class="px-5 py-3 whitespace-nowrap">
                            <div class="flex items-center gap-2">
                                <a href="${pageContext.request.contextPath}/admin/categories/edit?id=${cat.id}"
                                   class="p-1.5 text-blue-600 bg-blue-50 border border-blue-200 rounded-lg hover:bg-blue-100 transition inline-flex items-center"
                                   title="编辑板块">
                                    <i class="fa fa-edit"></i>
                                </a>
                                <form method="post" action="${pageContext.request.contextPath}/admin/categories/delete" class="inline">
                                    <input type="hidden" name="id" value="${cat.id}">
                                    <button type="button" onclick="confirmDeleteCategory(this, '${cat.name}')"
                                            class="p-1.5 text-red-600 bg-red-50 border border-red-200 rounded-lg hover:bg-red-100 transition cursor-pointer"
                                            title="删除板块">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty categoryList}">
                    <tr>
                        <td colspan="6" class="px-5 py-12 text-center text-gray-400">
                            <i class="fa fa-inbox text-3xl mb-2 block"></i>
                            暂无板块数据
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<script>
function confirmDeleteCategory(btn, name) {
    showConfirm('确定要删除板块「' + name + '」吗？删除后不可恢复。').then(function(ok) {
        if (ok) {
            var form = btn.closest('form');
            if (form) form.submit();
        }
    });
}
</script>
