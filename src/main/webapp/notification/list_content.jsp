<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="max-w-3xl mx-auto">
    <div class="mb-6 flex items-center justify-between">
        <h2 class="text-xl font-bold text-gray-800 flex items-center gap-2">
            <i class="fa fa-bell text-blue-500"></i> 我的通知
            <c:if test="${unreadCount > 0}">
                <span class="text-sm font-normal text-white bg-red-500 px-2 py-0.5 rounded-full">${unreadCount} 未读</span>
            </c:if>
        </h2>
        <c:if test="${unreadCount > 0}">
            <form method="post" action="${pageContext.request.contextPath}/notification/markRead" class="inline">
                <button type="submit" class="text-sm text-blue-500 hover:text-blue-600 transition cursor-pointer bg-transparent border-none">
                    <i class="fa fa-check-double"></i> 全部已读
                </button>
            </form>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${empty notificationList}">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 py-16 text-center">
                <i class="fa fa-bell-slash text-4xl text-gray-300 mb-3"></i>
                <p class="text-gray-400 text-sm">暂无通知</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden divide-y divide-gray-50">
                <c:forEach var="notif" items="${notificationList}">
                    <c:choose>
                        <c:when test="${not empty notif.targetUrl}">
                            <c:set var="notifLink" value="${pageContext.request.contextPath}${notif.targetUrl}" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="notifLink" value="${pageContext.request.contextPath}/notification/detail?id=${notif.id}" />
                        </c:otherwise>
                    </c:choose>
                    <a href="${notifLink}" data-notif-id="${notif.id}"
                       class="flex items-start gap-3 px-5 py-4 ${notif.isRead ? 'bg-white hover:bg-gray-50' : 'bg-blue-50/50 hover:bg-blue-100/50'} transition no-underline block ${not empty notif.targetUrl ? 'notif-mark-read' : ''}">
                        <div class="mt-0.5 shrink-0">
                            <c:choose>
                                <c:when test="${notif.type == 'report_result'}">
                                    <span class="w-8 h-8 bg-blue-100 text-blue-500 rounded-full flex items-center justify-center">
                                        <i class="fa fa-flag text-sm"></i>
                                    </span>
                                </c:when>
                                <c:when test="${notif.type == 'content_deleted'}">
                                    <span class="w-8 h-8 bg-red-100 text-red-500 rounded-full flex items-center justify-center">
                                        <i class="fa fa-trash text-sm"></i>
                                    </span>
                                </c:when>
                                <c:when test="${notif.type == 'new_reply'}">
                                    <span class="w-8 h-8 bg-green-100 text-green-500 rounded-full flex items-center justify-center">
                                        <i class="fa fa-comment text-sm"></i>
                                    </span>
                                </c:when>
                                <c:when test="${notif.type == 'new_like'}">
                                    <span class="w-8 h-8 bg-red-100 text-red-500 rounded-full flex items-center justify-center">
                                        <i class="fa fa-heart text-sm"></i>
                                    </span>
                                </c:when>
                                <c:when test="${notif.type == 'new_favorite'}">
                                    <span class="w-8 h-8 bg-yellow-100 text-yellow-500 rounded-full flex items-center justify-center">
                                        <i class="fa fa-bookmark text-sm"></i>
                                    </span>
                                </c:when>
                                <c:when test="${notif.type == 'reply_accepted'}">
                                    <span class="w-8 h-8 bg-purple-100 text-purple-500 rounded-full flex items-center justify-center">
                                        <i class="fa fa-trophy text-sm"></i>
                                    </span>
                                </c:when>
                                <c:when test="${notif.type == 'demand_reply'}">
                                    <span class="w-8 h-8 bg-orange-100 text-orange-500 rounded-full flex items-center justify-center">
                                        <i class="fa fa-gift text-sm"></i>
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="w-8 h-8 bg-gray-100 text-gray-500 rounded-full flex items-center justify-center">
                                        <i class="fa fa-info-circle text-sm"></i>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="flex-1 min-w-0">
                            <p class="text-sm ${notif.isRead ? 'text-gray-600' : 'text-gray-800 font-medium'}">${fn:escapeXml(notif.content)}</p>
                            <p class="text-xs text-gray-400 mt-1">
                                <fmt:formatDate value="${notif.createdAt}" pattern="yyyy-MM-dd HH:mm" />
                            </p>
                        </div>
                        <c:if test="${!notif.isRead}">
                            <span class="w-2 h-2 bg-blue-500 rounded-full mt-2 shrink-0"></span>
                        </c:if>
                    </a>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- 分页 -->
    <c:if test="${totalPages > 1}">
        <div class="mt-4 flex justify-center gap-1">
            <c:if test="${currentPage > 1}">
                <a href="${pageContext.request.contextPath}/notification/list?page=${currentPage - 1}"
                   class="px-3 py-1.5 text-sm bg-white border border-gray-200 rounded-lg text-gray-600 hover:bg-gray-50 transition no-underline">
                    <i class="fa fa-chevron-left"></i>
                </a>
            </c:if>
            <c:forEach begin="1" end="${totalPages}" var="i">
                <c:choose>
                    <c:when test="${i == currentPage}">
                        <span class="px-3 py-1.5 text-sm bg-blue-500 text-white rounded-lg">${i}</span>
                    </c:when>
                    <c:when test="${i <= 3 || i > totalPages - 2 || (i >= currentPage - 1 && i <= currentPage + 1)}">
                        <a href="${pageContext.request.contextPath}/notification/list?page=${i}"
                           class="px-3 py-1.5 text-sm bg-white border border-gray-200 rounded-lg text-gray-600 hover:bg-gray-50 transition no-underline">${i}</a>
                    </c:when>
                    <c:when test="${i == 4 || i == totalPages - 2}">
                        <span class="px-3 py-1.5 text-sm text-gray-400">...</span>
                    </c:when>
                </c:choose>
            </c:forEach>
            <c:if test="${currentPage < totalPages}">
                <a href="${pageContext.request.contextPath}/notification/list?page=${currentPage + 1}"
                   class="px-3 py-1.5 text-sm bg-white border border-gray-200 rounded-lg text-gray-600 hover:bg-gray-50 transition no-underline">
                    <i class="fa fa-chevron-right"></i>
                </a>
            </c:if>
        </div>
    </c:if>
</div>

<script>
// 点击通知直接跳转帖子时，先标记已读
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.notif-mark-read').forEach(function(el) {
        el.addEventListener('click', function() {
            var id = this.getAttribute('data-notif-id');
            if (id) {
                fetch('${pageContext.request.contextPath}/notification/markRead', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'id=' + id,
                    keepalive: true
                });
            }
        });
    });
});
</script>
