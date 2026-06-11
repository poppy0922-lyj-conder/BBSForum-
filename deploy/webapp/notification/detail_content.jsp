<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="max-w-3xl mx-auto">
    <!-- 返回按钮 -->
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/notification/list"
           class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-gray-500 bg-gray-100 border border-gray-200 rounded hover:bg-gray-200 transition no-underline">
            <i class="fa fa-arrow-left"></i> 返回通知列表
        </a>
    </div>

    <!-- 通知基本信息 -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-4">
        <div class="flex items-start gap-4">
            <div class="shrink-0">
                <c:choose>
                    <c:when test="${notification.type == 'report_result'}">
                        <span class="w-12 h-12 bg-blue-100 text-blue-500 rounded-full flex items-center justify-center">
                            <i class="fa fa-flag text-xl"></i>
                        </span>
                    </c:when>
                    <c:when test="${notification.type == 'content_deleted'}">
                        <span class="w-12 h-12 bg-red-100 text-red-500 rounded-full flex items-center justify-center">
                            <i class="fa fa-trash text-xl"></i>
                        </span>
                    </c:when>
                    <c:when test="${notification.type == 'new_reply'}">
                        <span class="w-12 h-12 bg-green-100 text-green-500 rounded-full flex items-center justify-center">
                            <i class="fa fa-comment text-xl"></i>
                        </span>
                    </c:when>
                    <c:when test="${notification.type == 'new_like'}">
                        <span class="w-12 h-12 bg-red-100 text-red-500 rounded-full flex items-center justify-center">
                            <i class="fa fa-heart text-xl"></i>
                        </span>
                    </c:when>
                    <c:when test="${notification.type == 'new_favorite'}">
                        <span class="w-12 h-12 bg-yellow-100 text-yellow-500 rounded-full flex items-center justify-center">
                            <i class="fa fa-bookmark text-xl"></i>
                        </span>
                    </c:when>
                    <c:when test="${notification.type == 'reply_accepted'}">
                        <span class="w-12 h-12 bg-purple-100 text-purple-500 rounded-full flex items-center justify-center">
                            <i class="fa fa-trophy text-xl"></i>
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="w-12 h-12 bg-gray-100 text-gray-500 rounded-full flex items-center justify-center">
                            <i class="fa fa-info-circle text-xl"></i>
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="flex-1">
                <h3 class="text-lg font-semibold text-gray-800 mb-2">
                    <c:choose>
                        <c:when test="${notification.type == 'report_result'}">举报处理结果</c:when>
                        <c:when test="${notification.type == 'content_deleted'}">内容删除通知</c:when>
                        <c:when test="${notification.type == 'new_reply'}">新回复</c:when>
                        <c:when test="${notification.type == 'new_like'}">点赞通知</c:when>
                        <c:when test="${notification.type == 'new_favorite'}">收藏通知</c:when>
                        <c:when test="${notification.type == 'reply_accepted'}">采纳通知</c:when>
                        <c:otherwise>系统通知</c:otherwise>
                    </c:choose>
                </h3>
                <p class="text-sm text-gray-700 leading-relaxed">${fn:escapeXml(notification.content)}</p>
                <p class="text-xs text-gray-400 mt-3">
                    <i class="fa fa-clock-o mr-1"></i>
                    <fmt:formatDate value="${notification.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                </p>
                <c:if test="${not empty notification.targetUrl}">
                    <div class="mt-4 pt-4 border-t border-gray-100">
                        <a href="${pageContext.request.contextPath}${notification.targetUrl}"
                           class="inline-flex items-center gap-2 px-4 py-2 bg-blue-500 text-white text-sm rounded-lg hover:bg-blue-600 transition no-underline">
                            <i class="fa fa-external-link"></i> 查看相关帖子
                        </a>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- 关联举报详情 -->
    <c:if test="${not empty reportDetail}">
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h4 class="text-sm font-semibold text-gray-700 mb-4 flex items-center gap-2">
                <i class="fa fa-list-alt text-blue-500"></i> 举报详情
            </h4>
            <div class="grid grid-cols-2 gap-4 text-sm">
                <div>
                    <span class="text-gray-400">举报ID：</span>
                    <span class="text-gray-700">#${reportDetail.reportId}</span>
                </div>
                <div>
                    <span class="text-gray-400">举报人：</span>
                    <span class="text-gray-700">${fn:escapeXml(reportDetail.reporterUsername)}</span>
                </div>
                <div>
                    <span class="text-gray-400">目标类型：</span>
                    <c:choose>
                        <c:when test="${reportDetail.targetType == 'post'}">
                            <span class="inline-block px-2 py-0.5 bg-blue-50 text-blue-600 rounded text-xs">帖子</span>
                        </c:when>
                        <c:when test="${reportDetail.targetType == 'reply'}">
                            <span class="inline-block px-2 py-0.5 bg-green-50 text-green-600 rounded text-xs">回复</span>
                        </c:when>
                        <c:when test="${reportDetail.targetType == 'demand'}">
                            <span class="inline-block px-2 py-0.5 bg-purple-50 text-purple-600 rounded text-xs">需求</span>
                        </c:when>
                        <c:when test="${reportDetail.targetType == 'demand_reply'}">
                            <span class="inline-block px-2 py-0.5 bg-amber-50 text-amber-600 rounded text-xs">需求回复</span>
                        </c:when>
                    </c:choose>
                </div>
                <div>
                    <span class="text-gray-400">目标ID：</span>
                    <span class="text-gray-700">${reportDetail.targetId}</span>
                </div>
                <div>
                    <span class="text-gray-400">举报原因：</span>
                    <c:choose>
                        <c:when test="${reportDetail.reason == 'spam'}">垃圾广告</c:when>
                        <c:when test="${reportDetail.reason == 'abuse'}">人身攻击</c:when>
                        <c:when test="${reportDetail.reason == 'illegal'}">政治敏感</c:when>
                        <c:when test="${reportDetail.reason == 'porn'}">色情低俗</c:when>
                        <c:when test="${reportDetail.reason == 'other'}">其他</c:when>
                        <c:otherwise>${reportDetail.reason}</c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <span class="text-gray-400">处理状态：</span>
                    <c:choose>
                        <c:when test="${reportDetail.status == 'approved'}">
                            <span class="inline-block px-2 py-0.5 bg-green-100 text-green-700 rounded text-xs font-medium">已通过</span>
                        </c:when>
                        <c:when test="${reportDetail.status == 'rejected'}">
                            <span class="inline-block px-2 py-0.5 bg-red-100 text-red-700 rounded text-xs font-medium">已驳回</span>
                        </c:when>
                        <c:otherwise>
                            <span class="inline-block px-2 py-0.5 bg-yellow-100 text-yellow-700 rounded text-xs font-medium">待处理</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="col-span-2">
                    <span class="text-gray-400">处理备注：</span>
                    <span class="text-gray-700">${not empty reportDetail.handleNote ? fn:escapeXml(reportDetail.handleNote) : '无'}</span>
                </div>
                <div>
                    <span class="text-gray-400">举报时间：</span>
                    <span class="text-gray-700"><fmt:formatDate value="${reportDetail.reportCreatedAt}" pattern="yyyy-MM-dd HH:mm" /></span>
                </div>
                <div>
                    <span class="text-gray-400">处理时间：</span>
                    <span class="text-gray-700"><fmt:formatDate value="${reportDetail.reportUpdatedAt}" pattern="yyyy-MM-dd HH:mm" /></span>
                </div>
            </div>
        </div>
    </c:if>
</div>
