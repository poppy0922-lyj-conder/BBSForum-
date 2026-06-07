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
                <i class="fa fa-gift text-blue-500"></i> 我的悬赏
            </h2>

            <c:choose>
                <c:when test="${empty demandList}">
                    <div class="text-center py-12 text-gray-400">
                        <i class="fa fa-gift text-4xl block mb-3 text-gray-300"></i>
                        <p class="text-sm">还没有发布过悬赏，去<a href="${pageContext.request.contextPath}/demand/create" class="text-blue-500 no-underline">发布一个</a>吧！</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="space-y-3">
                        <c:forEach var="demand" items="${demandList}">
                            <div class="p-4 border border-gray-100 rounded-lg hover:bg-gray-50 transition">
                                <div class="flex items-start justify-between gap-3">
                                    <div class="flex-1 min-w-0">
                                        <a href="${pageContext.request.contextPath}/demand/detail?id=${demand.id}" class="text-sm font-medium text-gray-900 hover:text-blue-500 no-underline line-clamp-1">
                                            ${demand.title}
                                        </a>
                                        <p class="text-xs text-gray-400 mt-1 line-clamp-2">${demand.content}</p>
                                        <div class="flex items-center gap-3 mt-2 text-xs text-gray-400">
                                            <span class="text-orange-500 font-medium"><i class="fa fa-diamond"></i> ${demand.score} 积分</span>
                                            <span>
                                                <c:choose>
                                                    <c:when test="${demand.status == 'open'}"><span class="text-green-500">进行中</span></c:when>
                                                    <c:otherwise><span class="text-gray-400">已结束</span></c:otherwise>
                                                </c:choose>
                                            </span>
                                            <span><i class="fa fa-comment-o"></i> ${demand.replyCount} 回复</span>
                                            <span>${fn:substring(demand.createdAt, 0, 16)}</span>
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
