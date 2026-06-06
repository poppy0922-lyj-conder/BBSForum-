<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="flex items-center justify-between mb-5">
    <div>
        <h2 class="text-xl font-bold text-gray-800">
            <i class="fa fa-trophy text-orange-500 mr-2"></i> 积分排行
        </h2>
        <p class="text-xs text-gray-400 mt-1">按总积分降序排列</p>
    </div>
    <c:if test="${not empty sessionScope.user}">
        <a href="${pageContext.request.contextPath}/score/record"
           class="px-4 py-2 text-sm bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition no-underline">
            <i class="fa fa-history"></i> 我的积分记录
        </a>
    </c:if>
</div>

<div class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
    <table class="data-table w-full">
        <thead class="bg-gray-50 border-b border-gray-100">
        <tr>
            <th class="px-5 py-3 text-left text-xs font-semibold text-gray-500 uppercase">排名</th>
            <th class="px-5 py-3 text-left text-xs font-semibold text-gray-500 uppercase">用户</th>
            <th class="px-5 py-3 text-right text-xs font-semibold text-gray-500 uppercase">总积分</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty rankList}">
                <tr>
                    <td colspan="3" class="px-5 py-10 text-center text-gray-400">
                        <i class="fa fa-inbox text-2xl mb-2 block"></i>
                        暂无数据
                    </td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="row" items="${rankList}" varStatus="status">
                    <tr class="hover:bg-gray-50 transition ${sessionScope.user.username == row.username ? 'bg-blue-50' : ''}">
                        <td class="px-5 py-3">
                            <c:choose>
                                <c:when test="${status.index == 0}">
                                    <span class="inline-flex items-center justify-center w-7 h-7 bg-yellow-400 text-white rounded-full text-sm font-bold">1</span>
                                </c:when>
                                <c:when test="${status.index == 1}">
                                    <span class="inline-flex items-center justify-center w-7 h-7 bg-gray-400 text-white rounded-full text-sm font-bold">2</span>
                                </c:when>
                                <c:when test="${status.index == 2}">
                                    <span class="inline-flex items-center justify-center w-7 h-7 bg-orange-500 text-white rounded-full text-sm font-bold">3</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-gray-500 font-medium">${status.index + 1}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-5 py-3">
                            <div class="flex items-center gap-2">
                                <div class="w-8 h-8 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-sm font-bold">
                                        ${fn:substring(row.username, 0, 1)}
                                </div>
                                <span class="font-medium text-gray-800">${row.username}</span>
                                <c:if test="${sessionScope.user.username == row.username}">
                                    <span class="text-xs px-2 py-0.5 bg-blue-100 text-blue-600 rounded-full">我</span>
                                </c:if>
                            </div>
                        </td>
                        <td class="px-5 py-3 text-right">
                                <span class="text-lg font-bold text-orange-500">
                                    <i class="fa fa-diamond text-sm mr-1"></i> ${row.score}
                                </span>
                        </td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<div class="mt-4 text-center text-xs text-gray-400">
    <i class="fa fa-info-circle"></i> 积分实时更新，积极参与社区互动可提升积分
</div>