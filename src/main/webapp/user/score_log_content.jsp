<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 个人中心专用布局：左右分栏 -->
<div class="flex gap-5">
    <!-- 左侧边栏 -->
    <c:set var="activeMenu" value="score-log" scope="request" />
    <jsp:include page="/user/profile_sidebar.jsp" />

    <!-- 右侧主内容区 -->
    <main class="flex-1 min-w-0">
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-lg font-bold text-gray-900 mb-5 flex items-center gap-2">
                <i class="fa fa-history text-blue-500"></i> 积分记录
            </h2>

            <!-- 当前积分展示 -->
            <div class="text-center py-6 mb-5 bg-blue-50 rounded-lg border border-blue-100">
                <div class="text-4xl font-bold text-blue-500 mb-1">
                    <i class="fa fa-diamond"></i> ${totalScore}
                </div>
                <div class="text-sm text-gray-500">当前积分</div>
            </div>

            <!-- 积分记录表格 -->
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="border-b border-gray-200">
                            <th class="text-left py-3 px-3 font-semibold text-gray-600">时间</th>
                            <th class="text-left py-3 px-3 font-semibold text-gray-600">积分变动</th>
                            <th class="text-left py-3 px-3 font-semibold text-gray-600">原因</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty scoreLogs}">
                                <tr>
                                    <td colspan="3" class="py-8 text-center text-gray-400">
                                        <i class="fa fa-inbox text-3xl block mb-2"></i>
                                        暂无积分记录
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="log" items="${scoreLogs}">
                                    <tr class="border-b border-gray-100 hover:bg-gray-50">
                                        <td class="py-3 px-3 text-gray-600">${log.createdAt}</td>
                                        <td class="py-3 px-3 font-semibold ${log.score > 0 ? 'text-green-500' : 'text-red-500'}">
                                            ${log.score > 0 ? '+' : ''}${log.score}
                                        </td>
                                        <td class="py-3 px-3 text-gray-700">${log.reason}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- 分页 -->
            <c:if test="${not empty pagination}">
                ${pagination}
            </c:if>
        </div>
    </main>
</div>
