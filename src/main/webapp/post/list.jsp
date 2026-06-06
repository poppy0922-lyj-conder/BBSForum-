<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 帖子列表 -->
<div class="flex items-center justify-between mb-4 pb-3 border-b border-gray-200">
    <h2 class="text-lg font-semibold text-gray-900">
        <c:choose>
            <c:when test="${not empty currentCategory}">
                <i class="fa fa-folder-o mr-1"></i> ${currentCategory.name}
            </c:when>
            <c:when test="${not empty searchKeyword}">
                <i class="fa fa-search mr-1"></i> 搜索："${searchKeyword}"
                <span class="text-sm text-gray-400 font-normal ml-2">找到 ${totalPosts} 条结果</span>
            </c:when>
            <c:otherwise>
                <i class="fa fa-newspaper-o mr-1"></i> 全部帖子
            </c:otherwise>
        </c:choose>
    </h2>
</div>

<c:choose>
    <c:when test="${empty postList}">
        <div class="text-center py-20 text-gray-400">
            <c:choose>
                <c:when test="${not empty searchKeyword}">
                    <i class="fa fa-search text-5xl block mb-4"></i>
                    <p class="text-sm">没有找到与 &quot;<c:out value='${searchKeyword}'/>&quot; 相关的帖子</p>
                </c:when>
                <c:otherwise>
                    <i class="fa fa-inbox text-5xl block mb-4"></i>
                    <p class="text-sm">还没有帖子，成为第一个分享知识的人吧</p>
                </c:otherwise>
            </c:choose>
        </div>
    </c:when>
    <c:otherwise>
        <c:forEach var="post" items="${postList}">
            <article class="bg-white rounded-lg shadow-sm hover:shadow-md transition-all border border-gray-100 overflow-hidden cursor-pointer mb-3" onclick="location.href='${pageContext.request.contextPath}/post/detail?id=${post.id}'">
                <div class="flex">
                    <!-- 封面图 -->
                    <div class="w-52 h-32 shrink-0 overflow-hidden bg-gray-100">
                        <c:choose>
                            <c:when test="${not empty post.imageUrl}">
                                <img src="${post.imageUrl}" alt="${post.title}" class="w-full h-full object-cover" onerror="this.src='${pageContext.request.contextPath}/cover/${post.id}?title=${fn:substring(post.title, 0, 1)}'">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/cover/${post.id}?title=${fn:substring(post.title, 0, 1)}" alt="${post.title}" class="w-full h-full object-cover">
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <!-- 内容 -->
                    <div class="flex-1 p-5 min-w-0 flex flex-col justify-between">
                        <div>
                            <h3 class="text-base font-semibold leading-snug mb-2">
                                <c:if test="${post.isTop == 2}"><span class="inline-block px-1.5 py-px text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-1.5 align-middle">全局置顶</span></c:if>
                                <c:if test="${post.isTop == 1}"><span class="inline-block px-1.5 py-px text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-1.5 align-middle">置顶</span></c:if>
                                <c:if test="${post.isElite == 1}"><span class="inline-block px-1.5 py-px text-xs font-medium text-pink-600 bg-pink-50 border border-pink-200 rounded mr-1.5 align-middle">精华</span></c:if>
                                <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}" class="text-gray-900 hover:text-red-500 no-underline">${post.title}</a>
                            </h3>
                            <p class="text-sm text-gray-500 leading-relaxed mb-3 line-clamp-2">
                                <c:if test="${not empty sessionScope.user && not empty post.aiSummary}"><span class="text-purple-500 mr-1">🤖</span></c:if>
                                ${post.summary}
                            </p>
                            <c:if test="${not empty post.keywords}">
                                <div class="flex items-center gap-1 flex-wrap mb-2">
                                    <c:forTokens var="kw" items="${post.keywords}" delims=",，" begin="0" end="2">
                                        <span class="inline-block px-1.5 py-px text-[11px] bg-gray-100 text-gray-400 border border-gray-200 rounded">${kw}</span>
                                    </c:forTokens>
                                </div>
                            </c:if>
                        </div>
                        <div class="flex items-center gap-4 text-xs text-gray-400 flex-wrap">
                            <span class="flex items-center gap-1">
                                <span class="w-5 h-5 bg-red-400 text-white rounded-full flex items-center justify-center text-[10px] font-bold">${fn:substring(post.authorName, 0, 1)}</span>
                                ${post.authorName}
                            </span>
                            <span><i class="fa fa-folder-o mr-0.5"></i> ${post.categoryName}</span>
                            <span><i class="fa fa-eye mr-0.5"></i> ${post.viewCount}</span>
                            <span><i class="fa fa-clock-o mr-0.5"></i> ${post.createdAt}</span>
                        </div>
                    </div>
                </div>
            </article>
        </c:forEach>
        <!-- 分页导航 -->
        <c:if test="${totalPages > 1}">
            <div class="flex items-center justify-center gap-1 mt-8 pb-5">
                <c:choose>
                    <c:when test="${not empty searchKeyword}">
                        <c:set var="pageUrl" value="${pageContext.request.contextPath}/post/search?keyword=${searchKeyword}&page="/>
                    </c:when>
                    <c:when test="${not empty currentCategory}">
                        <c:set var="pageUrl" value="${pageContext.request.contextPath}/category?id=${currentCategory.id}&page="/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="pageUrl" value="${pageContext.request.contextPath}/?page="/>
                    </c:otherwise>
                </c:choose>

                <%-- 上一页 --%>
                <c:if test="${currentPage > 1}">
                    <a href="${pageUrl}${currentPage - 1}" class="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 no-underline">上一页</a>
                </c:if>

                <%-- 页码 --%>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <c:choose>
                        <c:when test="${i == currentPage}">
                            <span class="px-3 py-1.5 text-sm bg-blue-500 text-white rounded font-medium">${i}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageUrl}${i}" class="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 no-underline">${i}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <%-- 下一页 --%>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageUrl}${currentPage + 1}" class="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 no-underline">下一页</a>
                </c:if>

                <span class="text-xs text-gray-400 ml-3">共 ${totalPosts} 篇帖子，${totalPages} 页</span>
            </div>
        </c:if>
    </c:otherwise>
</c:choose>
