<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 热度榜 -->
<div class="flex items-center justify-between mb-4 pb-3 border-b border-gray-200">
    <h2 class="text-lg font-semibold text-gray-900">
        <i class="fa fa-fire mr-1 text-orange-500"></i> <span class="text-orange-500">热度榜</span>
        <span class="text-sm text-gray-400 font-normal ml-2">按浏览量排序</span>
    </h2>
</div>

<c:choose>
    <c:when test="${empty postList}">
        <div class="text-center py-20 text-gray-400">
            <i class="fa fa-inbox text-5xl block mb-4"></i>
            <p class="text-sm">暂无热度内容</p>
        </div>
    </c:when>
    <c:otherwise>
        <div class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
            <c:forEach var="post" items="${postList}" varStatus="vs">
                <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}" class="flex items-center gap-3 px-5 py-3 hover:bg-gray-50 transition no-underline border-b border-gray-50 last:border-b-0 ${vs.index < 3 ? '' : ''}">
                    <!-- 排名 -->
                    <span class="w-7 h-7 flex items-center justify-center text-sm font-bold rounded-full
                        <c:choose>
                            <c:when test="${vs.index == 0}">bg-red-500 text-white</c:when>
                            <c:when test="${vs.index == 1}">bg-orange-400 text-white</c:when>
                            <c:when test="${vs.index == 2}">bg-yellow-400 text-white</c:when>
                            <c:otherwise>bg-gray-100 text-gray-500</c:otherwise>
                        </c:choose>">
                        ${vs.index + 1}
                    </span>
                    <!-- 标题 -->
                    <span class="flex-1 text-sm text-gray-800 truncate">${post.title}</span>
                    <!-- 浏览量 -->
                    <span class="text-xs text-gray-400 whitespace-nowrap">
                        <i class="fa fa-eye mr-1"></i> ${post.viewCount}
                    </span>
                </a>
            </c:forEach>
        </div>

        <!-- 分页 -->
        <c:if test="${totalPages > 1}">
            <div class="flex items-center justify-center gap-1 mt-6">
                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/hot?page=${currentPage - 1}" class="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 no-underline">上一页</a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <c:choose>
                        <c:when test="${i == currentPage}">
                            <span class="px-3 py-1.5 text-sm bg-orange-500 text-white rounded font-medium">${i}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/hot?page=${i}" class="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 no-underline">${i}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/hot?page=${currentPage + 1}" class="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 no-underline">下一页</a>
                </c:if>
            </div>
        </c:if>
    </c:otherwise>
</c:choose>
