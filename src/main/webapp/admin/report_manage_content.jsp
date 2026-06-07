<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="mb-6">
    <h2 class="text-xl font-bold text-gray-800 flex items-center gap-2">
        <i class="fa fa-flag text-red-500"></i> 举报管理
        <span class="text-sm font-normal text-gray-500 bg-gray-100 px-2 py-0.5 rounded-full">共 ${totalCount} 条</span>
    </h2>
</div>

<c:if test="${not empty successMsg}">
    <div class="mb-4 p-3 bg-green-50 border border-green-200 text-green-700 text-sm rounded-lg">${successMsg}</div>
</c:if>
<c:if test="${not empty param.error}">
    <div class="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg">操作失败，请重试</div>
</c:if>

<!-- 状态筛选栏 -->
<div class="mb-4">
    <form method="get" action="${pageContext.request.contextPath}/admin/report/list" class="flex flex-wrap items-center gap-2">
        <select name="status" class="px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:border-blue-400 bg-white">
            <option value="pending" ${currentStatus == 'pending' ? 'selected' : ''}>待处理</option>
            <option value="approved" ${currentStatus == 'approved' ? 'selected' : ''}>已通过</option>
            <option value="rejected" ${currentStatus == 'rejected' ? 'selected' : ''}>已驳回</option>
            <option value="all" ${currentStatus == 'all' ? 'selected' : ''}>全部</option>
        </select>
        <button type="submit" class="px-4 py-2 bg-blue-500 text-white text-sm rounded-lg hover:bg-blue-600 transition cursor-pointer">
            <i class="fa fa-filter"></i> 筛选
        </button>
    </form>
</div>

<!-- 举报列表表格 -->
<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <c:choose>
        <c:when test="${empty reportList}">
            <div class="py-16 text-center text-gray-400">
                <i class="fa fa-check-circle text-4xl mb-3 text-green-400"></i>
                <p>暂无举报记录</p>
            </div>
        </c:when>
        <c:otherwise>
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-gray-500 text-xs uppercase">
                        <th class="px-4 py-3 text-left">ID</th>
                        <th class="px-4 py-3 text-left">举报人</th>
                        <th class="px-4 py-3 text-left">目标类型</th>
                        <th class="px-4 py-3 text-left">目标ID</th>
                        <th class="px-4 py-3 text-left">原因</th>
                        <th class="px-4 py-3 text-left">状态</th>
                        <th class="px-4 py-3 text-left">举报时间</th>
                        <th class="px-4 py-3 text-center">操作</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    <c:forEach var="report" items="${reportList}">
                        <tr class="hover:bg-gray-50 transition">
                            <td class="px-4 py-3 text-gray-600">${report.id}</td>
                            <td class="px-4 py-3 text-gray-700">${fn:escapeXml(report.reporterUsername)}</td>
                            <td class="px-4 py-3">
                                <c:choose>
                                    <c:when test="${report.targetType == 'post'}">
                                        <span class="inline-block px-2 py-0.5 bg-blue-50 text-blue-600 rounded text-xs">帖子</span>
                                    </c:when>
                                    <c:when test="${report.targetType == 'reply'}">
                                        <span class="inline-block px-2 py-0.5 bg-green-50 text-green-600 rounded text-xs">回复</span>
                                    </c:when>
                                    <c:when test="${report.targetType == 'demand'}">
                                        <span class="inline-block px-2 py-0.5 bg-purple-50 text-purple-600 rounded text-xs">需求</span>
                                    </c:when>
                                    <c:when test="${report.targetType == 'demand_reply'}">
                                        <span class="inline-block px-2 py-0.5 bg-amber-50 text-amber-600 rounded text-xs">需求回复</span>
                                    </c:when>
                                </c:choose>
                            </td>
                            <td class="px-4 py-3 text-gray-600">${report.targetId}</td>
                            <td class="px-4 py-3">
                                <c:choose>
                                    <c:when test="${report.reason == 'spam'}">垃圾广告</c:when>
                                    <c:when test="${report.reason == 'abuse'}">人身攻击</c:when>
                                    <c:when test="${report.reason == 'illegal'}">政治敏感</c:when>
                                    <c:when test="${report.reason == 'porn'}">色情低俗</c:when>
                                    <c:when test="${report.reason == 'other'}">其他</c:when>
                                    <c:otherwise>${report.reason}</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="px-4 py-3">
                                <c:choose>
                                    <c:when test="${report.status == 'pending'}">
                                        <span class="inline-block px-2 py-0.5 bg-yellow-100 text-yellow-700 rounded text-xs font-medium">待处理</span>
                                    </c:when>
                                    <c:when test="${report.status == 'approved'}">
                                        <span class="inline-block px-2 py-0.5 bg-green-100 text-green-700 rounded text-xs font-medium">已通过</span>
                                    </c:when>
                                    <c:when test="${report.status == 'rejected'}">
                                        <span class="inline-block px-2 py-0.5 bg-red-100 text-red-700 rounded text-xs font-medium">已驳回</span>
                                    </c:when>
                                </c:choose>
                            </td>
                            <td class="px-4 py-3 text-gray-500 text-xs">
                                <fmt:formatDate value="${report.createdAt}" pattern="yyyy-MM-dd HH:mm" />
                            </td>
                            <td class="px-4 py-3 text-center">
                                <c:choose>
                                    <c:when test="${report.status == 'pending'}">
                                        <button onclick="handleReport(${report.id})"
                                                class="px-3 py-1 bg-blue-500 text-white text-xs rounded-lg hover:bg-blue-600 transition cursor-pointer">
                                            <i class="fa fa-gavel"></i> 处理
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-xs text-gray-500">
                                            <fmt:formatDate value="${report.updatedAt}" pattern="yyyy-MM-dd HH:mm" />
                                        </span>
                                        <c:if test="${not empty report.handleNote}">
                                            <div class="text-xs text-gray-400 mt-0.5">${fn:escapeXml(report.handleNote)}</div>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</div>

<!-- 分页 -->
<c:if test="${totalPages > 1}">
    <div class="mt-4 flex justify-center gap-1">
        <c:if test="${currentPage > 1}">
            <a href="${pageContext.request.contextPath}/admin/report/list?status=${currentStatus}&page=${currentPage - 1}"
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
                    <a href="${pageContext.request.contextPath}/admin/report/list?status=${currentStatus}&page=${i}"
                       class="px-3 py-1.5 text-sm bg-white border border-gray-200 rounded-lg text-gray-600 hover:bg-gray-50 transition no-underline">${i}</a>
                </c:when>
                <c:when test="${i == 4 || i == totalPages - 2}">
                    <span class="px-3 py-1.5 text-sm text-gray-400">...</span>
                </c:when>
            </c:choose>
        </c:forEach>
        <c:if test="${currentPage < totalPages}">
            <a href="${pageContext.request.contextPath}/admin/report/list?status=${currentStatus}&page=${currentPage + 1}"
               class="px-3 py-1.5 text-sm bg-white border border-gray-200 rounded-lg text-gray-600 hover:bg-gray-50 transition no-underline">
                <i class="fa fa-chevron-right"></i>
            </a>
        </c:if>
    </div>
</c:if>

<script>
function handleReport(reportId) {
    fetch('${pageContext.request.contextPath}/admin/report/preview?reportId=' + reportId)
        .then(function(r) { return r.text(); })
        .then(function(html) {
            var content = '<div class="text-left text-sm text-gray-700 mb-3 p-3 bg-gray-50 rounded-lg">' + html + '</div>' +
                '<select id="reportAction" class="w-full px-3 py-2 border border-gray-300 rounded mb-3 text-sm">' +
                '<option value="approve">通过（删除内容）</option>' +
                '<option value="reject">驳回（保留内容）</option>' +
                '</select>' +
                '<textarea id="handleNote" class="w-full px-3 py-2 border border-gray-300 rounded text-sm" rows="3" placeholder="处理备注（可选）" maxlength="200"></textarea>';
            showCustomModal('处理举报', content, {
                confirmText: '提交处理',
                onConfirm: function(done) {
                    var action = document.getElementById('reportAction').value;
                    var note = document.getElementById('handleNote').value;
                    done();
                    fetch('${pageContext.request.contextPath}/admin/report/handle', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'reportId=' + reportId + '&action=' + action + '&handleNote=' + encodeURIComponent(note)
                    }).then(function(r) {
                        if (r.redirected || r.ok) { location.reload(); }
                        else { alert('处理失败'); }
                    }).catch(function() { alert('网络错误，请重试'); });
                }
            });
        });
}
</script>
