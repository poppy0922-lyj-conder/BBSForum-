<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 个人中心专用布局：左右分栏 -->
<div class="flex gap-5">
    <!-- 左侧边栏 -->
    <jsp:include page="/user/profile_sidebar.jsp" />

    <!-- 右侧主内容区 -->
    <main class="flex-1 min-w-0">
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-lg font-bold text-gray-900 mb-5 flex items-center gap-2">
                <i class="fa fa-star-o text-blue-500"></i> 我的收藏
            </h2>

            <c:choose>
                <c:when test="${empty favoriteList}">
                    <div class="text-center py-12 text-gray-400">
                        <i class="fa fa-star-o text-4xl block mb-3 text-gray-300"></i>
                        <p class="text-sm">还没有收藏过任何帖子，去<a href="${pageContext.request.contextPath}/" class="text-blue-500 no-underline">浏览帖子</a>发现精彩内容吧！</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="space-y-3">
                        <c:forEach var="post" items="${favoriteList}">
                            <div class="p-4 border border-gray-100 rounded-lg hover:bg-gray-50 transition">
                                <div class="flex items-start gap-3">
                                    <div class="flex-1 min-w-0">
                                        <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}" class="text-sm font-medium text-gray-900 hover:text-blue-500 no-underline line-clamp-1">
                                            ${post.title}
                                        </a>
                                        <p class="text-xs text-gray-400 mt-1 line-clamp-2">${post.summary}</p>
                                        <div class="flex items-center gap-3 mt-2 text-xs text-gray-400">
                                            <span><i class="fa fa-user-o"></i> ${post.authorName}</span>
                                            <span><i class="fa fa-folder-o"></i> ${post.categoryName}</span>
                                            <span><i class="fa fa-eye"></i> ${post.viewCount}</span>
                                            <span><i class="fa fa-star-o text-orange-500"></i> ${post.favoriteCount}</span>
                                            <span>收藏于 ${fn:substring(post.favTime, 0, 16)}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>
