<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="mb-6">
    <h2 class="text-xl font-bold text-gray-800 flex items-center gap-2">
        <i class="fa fa-file-text text-blue-500"></i> 帖子管理
        <span class="text-sm font-normal text-gray-500 bg-gray-100 px-2 py-0.5 rounded-full">共 ${totalPosts} 篇</span>
    </h2>
</div>

<!-- 搜索与筛选栏 -->
<div class="mb-4">
    <form method="get" action="${pageContext.request.contextPath}/admin/post/manage" class="flex flex-wrap items-center gap-2">
        <input type="text" name="keyword" value="${fn:escapeXml(keyword)}"
               placeholder="搜索标题或内容..."
               class="w-48 px-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-300 focus:border-blue-400" />
        <input type="text" name="author" value="${fn:escapeXml(author)}"
               placeholder="搜索作者..."
               class="w-36 px-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-300 focus:border-blue-400" />
        <select name="categoryId" class="px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:border-blue-400 bg-white">
            <option value="">全部板块</option>
            <c:forEach var="cat" items="${categoryList}">
                <option value="${cat.id}" ${categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
            </c:forEach>
        </select>
        <button type="submit" class="px-4 py-2 bg-blue-500 text-white text-sm rounded-lg hover:bg-blue-600 transition cursor-pointer">
            <i class="fa fa-search"></i> 搜索
        </button>
        <c:if test="${not empty keyword or not empty author or not empty categoryId}">
            <a href="${pageContext.request.contextPath}/admin/post/manage"
               class="px-4 py-2 bg-gray-100 text-gray-600 text-sm rounded-lg hover:bg-gray-200 transition no-underline">
                清除
            </a>
        </c:if>
        <!-- 排序切换 -->
        <div class="ml-auto flex items-center gap-1">
            <span class="text-xs text-gray-400">排序:</span>
            <c:choose>
                <c:when test="${sort == 'desc'}">
                    <a href="${pageContext.request.contextPath}/admin/post/manage?sort=asc<c:if test='${not empty keyword}'>&amp;keyword=${fn:escapeXml(keyword)}</c:if><c:if test='${not empty author}'>&amp;author=${fn:escapeXml(author)}</c:if><c:if test='${not empty categoryId}'>&amp;categoryId=${categoryId}</c:if>"
                       class="px-3 py-1.5 text-xs bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition no-underline">
                        <i class="fa fa-sort-numeric-asc"></i> 升序
                    </a>
                    <span class="px-3 py-1.5 text-xs bg-blue-500 text-white rounded-lg">
                        <i class="fa fa-sort-numeric-desc"></i> 降序
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="px-3 py-1.5 text-xs bg-blue-500 text-white rounded-lg">
                        <i class="fa fa-sort-numeric-asc"></i> 升序
                    </span>
                    <a href="${pageContext.request.contextPath}/admin/post/manage?sort=desc<c:if test='${not empty keyword}'>&amp;keyword=${fn:escapeXml(keyword)}</c:if><c:if test='${not empty author}'>&amp;author=${fn:escapeXml(author)}</c:if><c:if test='${not empty categoryId}'>&amp;categoryId=${categoryId}</c:if>"
                       class="px-3 py-1.5 text-xs bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition no-underline">
                        <i class="fa fa-sort-numeric-desc"></i> 降序
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </form>
</div>

<!-- 使用 Tailwind 表格，圆角、阴影、悬停效果 -->
<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
            <tr>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">标题</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">作者</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">板块</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">置顶</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">精华</th>
                <th class="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
            </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
            <c:forEach var="post" items="${postList}">
                <tr class="hover:bg-blue-50/30 transition duration-150">
                    <td class="px-5 py-3 text-sm text-gray-600">${post.id}</td>
                    <td class="px-5 py-3">
                        <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}"
                           class="text-blue-600 hover:text-blue-800 hover:underline text-sm font-medium">
                                ${post.title}
                        </a>
                    </td>
                    <td class="px-5 py-3 text-sm text-gray-600">${post.authorName}</td>
                    <td class="px-5 py-3 text-sm text-gray-600">${post.categoryName}</td>
                    <td class="px-5 py-3">
                        <c:choose>
                            <c:when test="${post.isTop == 2}">
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-700">全局置顶</span>
                            </c:when>
                            <c:when test="${post.isTop == 1}">
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-700">板块置顶</span>
                            </c:when>
                            <c:otherwise>
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-500">未置顶</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="px-5 py-3">
                        <c:choose>
                            <c:when test="${post.isElite == 1}">
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-pink-100 text-pink-700">精华</span>
                            </c:when>
                            <c:otherwise>
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-500">普通</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="px-5 py-3 whitespace-nowrap">
                        <div class="flex items-center gap-2">
                            <!-- 置顶表单 -->
                            <form method="post" action="${pageContext.request.contextPath}/admin/post/top" class="inline">
                                <input type="hidden" name="id" value="${post.id}" />
                                <button type="submit" class="p-1.5 text-amber-600 bg-amber-50 border border-amber-200 rounded-lg hover:bg-amber-100 transition cursor-pointer"
                                        title="切换置顶状态">
                                    <i class="fa fa-arrow-up"></i>
                                </button>
                            </form>
                            <!-- 加精表单 -->
                            <form method="post" action="${pageContext.request.contextPath}/admin/post/elite" class="inline">
                                <input type="hidden" name="id" value="${post.id}" />
                                <button type="submit" class="p-1.5 text-pink-600 bg-pink-50 border border-pink-200 rounded-lg hover:bg-pink-100 transition cursor-pointer"
                                        title="切换精华状态">
                                    <i class="fa fa-diamond"></i>
                                </button>
                            </form>
                            <!-- 编辑链接 -->
                            <a href="${pageContext.request.contextPath}/post/edit?id=${post.id}"
                               class="p-1.5 text-blue-600 bg-blue-50 border border-blue-200 rounded-lg hover:bg-blue-100 transition inline-flex items-center"
                               title="编辑帖子">
                                <i class="fa fa-edit"></i>
                            </a>
                        </div>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty postList}">
                <tr>
                    <td colspan="7" class="px-5 py-12 text-center text-gray-400">
                        <i class="fa fa-inbox text-3xl mb-2 block"></i>
                        暂无帖子数据
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>

<!-- 分页组件 – 保持与整体风格一致 -->
<c:if test="${totalPages > 1}">
    <div class="flex items-center justify-center gap-2 mt-6">
        <c:if test="${currentPage > 1}">
            <a href="${pageContext.request.contextPath}/admin/post/manage?page=${currentPage - 1}<c:if test='${not empty keyword}'>&amp;keyword=${fn:escapeXml(keyword)}</c:if><c:if test='${not empty author}'>&amp;author=${fn:escapeXml(author)}</c:if><c:if test='${not empty categoryId}'>&amp;categoryId=${categoryId}</c:if><c:if test='${sort == "desc"}'>&amp;sort=desc</c:if>"
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
                    <a href="${pageContext.request.contextPath}/admin/post/manage?page=${i}<c:if test='${not empty keyword}'>&amp;keyword=${fn:escapeXml(keyword)}</c:if><c:if test='${not empty author}'>&amp;author=${fn:escapeXml(author)}</c:if><c:if test='${not empty categoryId}'>&amp;categoryId=${categoryId}</c:if><c:if test='${sort == "desc"}'>&amp;sort=desc</c:if>"
                       class="px-3 py-1.5 text-sm bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition no-underline">
                            ${i}
                    </a>
                </c:otherwise>
            </c:choose>
        </c:forEach>
        <c:if test="${currentPage < totalPages}">
            <a href="${pageContext.request.contextPath}/admin/post/manage?page=${currentPage + 1}<c:if test='${not empty keyword}'>&amp;keyword=${fn:escapeXml(keyword)}</c:if><c:if test='${not empty author}'>&amp;author=${fn:escapeXml(author)}</c:if><c:if test='${not empty categoryId}'>&amp;categoryId=${categoryId}</c:if><c:if test='${sort == "desc"}'>&amp;sort=desc</c:if>"
               class="px-3 py-1.5 text-sm bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition no-underline">
                下一页
            </a>
        </c:if>
    </div>
</c:if>