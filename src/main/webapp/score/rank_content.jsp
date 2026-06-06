<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="flex items-center justify-between mb-5">
    <div>
        <h2 class="text-xl font-bold text-gray-800">
            <i class="fa fa-trophy text-orange-500 mr-2"></i> 积分排行
        </h2>
        <p class="text-xs text-gray-400 mt-1">按总积分降序排列，仅展示前100名</p>
    </div>
    <c:if test="${not empty sessionScope.user}">
        <a href="${pageContext.request.contextPath}/score/record"
           class="px-4 py-2 text-sm bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition no-underline shadow-sm">
            <i class="fa fa-history mr-1"></i> 我的积分记录
        </a>
    </c:if>
</div>

<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <table class="data-table w-full">
        <thead class="bg-gradient-to-r from-gray-50 to-gray-100 border-b border-gray-200">
        <tr>
            <th class="px-5 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">排名</th>
            <th class="px-5 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">用户</th>
            <th class="px-5 py-4 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">总积分</th>
        </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
        <c:choose>
            <c:when test="${empty rankList}">
                <tr>
                    <td colspan="3" class="px-5 py-12 text-center text-gray-400">
                        <i class="fa fa-trophy text-3xl mb-3 block text-gray-300"></i>
                        <p>暂无排行数据</p>
                        <p class="text-xs mt-1">发布悬赏或参与回复赚取积分</p>
                    </td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="row" items="${rankList}" varStatus="status">
                    <tr class="hover:bg-gray-50 transition duration-150 ${sessionScope.user.username == row.username ? 'bg-blue-50' : ''}">
                        <td class="px-5 py-3 whitespace-nowrap">
                            <c:choose>
                                <c:when test="${status.index == 0}">
                                    <div class="flex items-center gap-1">
                                        <span class="text-yellow-500 text-xl"><i class="fa fa-trophy"></i></span>
                                        <span class="font-bold text-gray-700 ml-1">1</span>
                                    </div>
                                </c:when>
                                <c:when test="${status.index == 1}">
                                    <div class="flex items-center gap-1">
                                        <span class="text-gray-400 text-xl"><i class="fa fa-trophy"></i></span>
                                        <span class="font-bold text-gray-700 ml-1">2</span>
                                    </div>
                                </c:when>
                                <c:when test="${status.index == 2}">
                                    <div class="flex items-center gap-1">
                                        <span class="text-amber-600 text-xl"><i class="fa fa-trophy"></i></span>
                                        <span class="font-bold text-gray-700 ml-1">3</span>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-gray-400 font-medium">${status.index + 1}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-5 py-3">
                            <div class="flex items-center gap-3">
                                <div class="w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold shadow-sm
                                    <c:choose>
                                        <c:when test="${status.index == 0}">bg-gradient-to-br from-yellow-400 to-yellow-500 text-white</c:when>
                                        <c:when test="${status.index == 1}">bg-gradient-to-br from-gray-400 to-gray-500 text-white</c:when>
                                        <c:when test="${status.index == 2}">bg-gradient-to-br from-amber-500 to-amber-600 text-white</c:when>
                                        <c:otherwise>bg-gray-100 text-gray-600</c:otherwise>
                                    </c:choose>
                                ">
                                        ${fn:substring(row.username, 0, 1)}
                                </div>
                                <div class="flex flex-col">
                                    <span class="font-semibold text-gray-800">${row.username}</span>
                                    <c:if test="${sessionScope.user.username == row.username}">
                                        <span class="text-xs text-blue-500">当前用户</span>
                                    </c:if>
                                </div>
                            </div>
                        </td>
                        <td class="px-5 py-3 text-right">
                            <div class="flex items-center justify-end gap-1">
                                <i class="fa fa-diamond text-amber-400 text-sm"></i>
                                <span class="text-xl font-bold text-orange-500">${row.score}</span>
                                <span class="text-xs text-gray-400 ml-0.5">分</span>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<div class="mt-5 flex justify-center gap-6 text-xs text-gray-400">
    <div class="flex items-center gap-1">
        <i class="fa fa-trophy text-yellow-500"></i>
        <span>冠 军</span>
    </div>
    <div class="flex items-center gap-1">
        <i class="fa fa-trophy text-gray-400"></i>
        <span>亚 军</span>
    </div>
    <div class="flex items-center gap-1">
        <i class="fa fa-trophy text-amber-600"></i>
        <span>季 军</span>
    </div>
    <div class="flex items-center gap-1">
        <i class="fa fa-diamond text-amber-400"></i>
        <span>积 分</span>
    </div>
</div>