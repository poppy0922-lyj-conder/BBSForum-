<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 需求悬赏列表 -->
<div class="flex items-center justify-between mb-4 pb-3 border-b border-gray-200">
    <h2 class="text-lg font-semibold text-gray-900">
        <i class="fa fa-diamond mr-1 text-orange-500"></i> 需求悬赏
        <span class="text-sm text-gray-400 font-normal ml-2">共 ${totalPosts} 条需求</span>
    </h2>
    <c:if test="${not empty sessionScope.user}">
        <a href="${pageContext.request.contextPath}/demand/create" class="text-sm px-3 py-1.5 bg-orange-500 text-white rounded hover:bg-orange-600 no-underline">
            <i class="fa fa-plus"></i> 发布悬赏
        </a>
    </c:if>
</div>

<c:choose>
    <c:when test="${empty postList}">
        <div class="text-center py-20 text-gray-400">
            <i class="fa fa-diamond text-5xl block mb-4"></i>
            <p class="text-sm">还没有悬赏需求</p>
            <c:if test="${not empty sessionScope.user}">
                <a href="${pageContext.request.contextPath}/demand/create" class="inline-block mt-3 text-sm text-orange-500 hover:text-orange-600 no-underline">发布第一个悬赏</a>
            </c:if>
        </div>
    </c:when>
    <c:otherwise>
        <div class="space-y-3">
            <c:forEach var="demand" items="${postList}">
                <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-5 hover:shadow-md transition">
                    <div class="flex items-start justify-between">
                        <div class="flex-1 min-w-0">
                            <h3 class="text-base font-semibold mb-1">
                                <c:choose>
                                    <c:when test="${demand.status == 'open'}">
                                        <span class="inline-block px-1.5 py-px text-xs font-medium text-green-600 bg-green-50 border border-green-200 rounded mr-1.5 align-middle">进行中</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="inline-block px-1.5 py-px text-xs font-medium text-gray-500 bg-gray-100 border border-gray-200 rounded mr-1.5 align-middle">已结束</span>
                                    </c:otherwise>
                                </c:choose>
                                ${demand.title}
                            </h3>
                            <p class="text-sm text-gray-500 mt-1 line-clamp-2">${demand.content}</p>
                            <div class="flex items-center gap-4 mt-3 text-xs text-gray-400">
                                <span class="flex items-center gap-1">
                                    <span class="w-5 h-5 bg-orange-400 text-white rounded-full flex items-center justify-center text-[10px] font-bold">${fn:substring(demand.authorName, 0, 1)}</span>
                                    ${demand.authorName}
                                </span>
                                <span><i class="fa fa-clock-o mr-0.5"></i> ${demand.createdAt}</span>
                            </div>
                        </div>
                        <div class="ml-4 text-center shrink-0">
                            <div class="text-xl font-bold text-orange-500">${demand.score}</div>
                            <div class="text-xs text-gray-400">积分</div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- 分页 -->
        <c:if test="${totalPages > 1}">
            <div class="flex items-center justify-center gap-1 mt-6">
                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/demand?page=${currentPage - 1}" class="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 no-underline">上一页</a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <c:choose>
                        <c:when test="${i == currentPage}">
                            <span class="px-3 py-1.5 text-sm bg-orange-500 text-white rounded font-medium">${i}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/demand?page=${i}" class="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 no-underline">${i}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/demand?page=${currentPage + 1}" class="px-3 py-1.5 text-sm border border-gray-300 rounded text-gray-600 hover:bg-gray-50 no-underline">下一页</a>
                </c:if>
            </div>
        </c:if>
    </c:otherwise>
</c:choose>
