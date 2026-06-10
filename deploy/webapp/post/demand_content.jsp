<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 需求悬赏列表 -->
<div class="flex items-center justify-between mb-4 pb-3 border-b border-gray-200">
    <h2 class="text-lg font-semibold text-gray-900">
        <i class="fa fa-diamond mr-1 text-orange-500"></i> 需求悬赏
        <span class="text-sm text-gray-400 font-normal ml-2">共 ${totalPosts} 条需求</span>
    </h2>
</div>

<c:choose>
    <c:when test="${empty postList}">
        <div class="text-center py-20 text-gray-400">
            <i class="fa fa-diamond text-5xl block mb-4"></i>
            <p class="text-sm">还没有悬赏需求</p>
        </div>
    </c:when>
    <c:otherwise>
        <div class="space-y-3">
            <c:forEach var="demand" items="${postList}">
                <a href="${pageContext.request.contextPath}/demand/detail?id=${demand.id}" class="block no-underline">
                <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-5 hover:shadow-md transition <c:if test='${demand.status != \"open\"}'>opacity-60</c:if>">
                    <div class="flex items-start justify-between">
                        <div class="flex-1 min-w-0">
                            <h3 class="text-base font-semibold mb-1 <c:choose><c:when test='${demand.status == \"open\"}'>text-gray-900</c:when><c:otherwise>text-gray-400</c:otherwise></c:choose>">
                                <c:choose>
                                    <c:when test="${demand.status == 'open'}">
                                        <span class="inline-block px-1.5 py-px text-xs font-medium text-green-600 bg-green-50 border border-green-200 rounded mr-1.5 align-middle">进行中</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="inline-block px-1.5 py-px text-xs font-medium text-gray-500 bg-gray-100 border border-gray-200 rounded mr-1.5 align-middle">已结束</span>
                                    </c:otherwise>
                                </c:choose>
                                ${demand.title}
                                <c:if test="${sessionScope.user.id == demand.userId}">
                                    <span class="inline-block px-1.5 py-px text-xs font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-full ml-1">我的</span>
                                </c:if>
                            </h3>
                            <p class="text-sm <c:choose><c:when test='${demand.status == \"open\"}'>text-gray-500</c:when><c:otherwise>text-gray-300</c:otherwise></c:choose> mt-1 line-clamp-2">${demand.content}</p>
                            <div class="flex items-center gap-4 mt-3 text-xs <c:choose><c:when test='${demand.status == \"open\"}'>text-gray-400</c:when><c:otherwise>text-gray-300</c:otherwise></c:choose>">
                                <span class="flex items-center gap-1">
                                    <span class="relative inline-flex">
                                        <img src="${demand.authorAvatar}" alt=""
                                             class="w-5 h-5 rounded-full object-cover ${empty demand.authorAvatar ? 'hidden' : ''}"
                                             onerror="this.classList.add('hidden');this.nextElementSibling.classList.remove('hidden')">
                                        <span class="w-5 h-5 bg-blue-500 text-white rounded-full flex items-center justify-center text-[10px] font-bold ${not empty demand.authorAvatar ? 'hidden' : ''}">${fn:substring(demand.authorName, 0, 1)}</span>
                                    </span>
                                    ${demand.authorName}
                                </span>
                                <span><i class="fa fa-clock-o mr-0.5"></i> ${demand.createdAt}</span>
                            </div>
                        </div>
                        <div class="ml-4 text-center shrink-0">
                            <div class="text-xl font-bold <c:choose><c:when test='${demand.status == \"open\"}'>text-orange-500</c:when><c:otherwise>text-gray-300</c:otherwise></c:choose>">${demand.score}</div>
                            <div class="text-xs text-gray-400">积分</div>
                        </div>
                    </div>
                </div>
                </a>
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
