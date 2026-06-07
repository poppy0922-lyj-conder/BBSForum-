<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 个人中心左侧边栏（公共组件） -->
<aside class="w-60 shrink-0">
    <div class="bg-white rounded-lg shadow-sm overflow-hidden sticky top-[72px]">
        <!-- 标题 -->
        <div class="px-4 pt-4 pb-2 flex items-center gap-2 text-gray-800">
            <i class="fa fa-user-circle text-lg text-blue-500"></i>
            <span class="font-semibold">个人中心</span>
        </div>
        <!-- 二级导航菜单 -->
        <ul>
            <li>
                <a href="${pageContext.request.contextPath}/user/profile" class="flex items-center gap-2 px-4 py-2.5 text-sm no-underline ${activeMenu == 'profile' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                    <i class="fa fa-id-card-o w-4 text-center"></i> 基本信息
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/user/profile/posts" class="flex items-center gap-2 px-4 py-2.5 text-sm no-underline ${activeMenu == 'posts' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                    <i class="fa fa-file-text-o w-4 text-center"></i> 发布帖子
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/user/profile/demands" class="flex items-center gap-2 px-4 py-2.5 text-sm no-underline ${activeMenu == 'demands' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                    <i class="fa fa-gift w-4 text-center"></i> 我的悬赏
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/user/profile/follows" class="flex items-center gap-2 px-4 py-2.5 text-sm no-underline ${activeMenu == 'follows' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                    <i class="fa fa-user-plus w-4 text-center"></i> 我的关注
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/user/profile/likes" class="flex items-center gap-2 px-4 py-2.5 text-sm no-underline ${activeMenu == 'likes' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                    <i class="fa fa-thumbs-o-up w-4 text-center"></i> 我的点赞
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/user/profile/favorites" class="flex items-center gap-2 px-4 py-2.5 text-sm no-underline ${activeMenu == 'favorites' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                    <i class="fa fa-star-o w-4 text-center"></i> 我的收藏
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/user/score-log" class="flex items-center gap-2 px-4 py-2.5 text-sm no-underline ${activeMenu == 'score-log' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                    <i class="fa fa-history w-4 text-center"></i> 积分记录
                </a>
            </li>
        </ul>
        <!-- 边栏底部辅助功能 -->
        <div class="border-t border-gray-100 mt-1 pt-1 pb-2">
            <a href="${pageContext.request.contextPath}/user/profile/edit" class="flex items-center gap-2 px-4 py-2.5 text-sm no-underline text-gray-700 hover:bg-blue-50 hover:text-blue-500">
                <i class="fa fa-edit w-4 text-center"></i> 编辑资料
            </a>
        </div>
        <!-- 最近积分记录模块 -->
        <div class="border-t border-gray-100 mt-1 pt-3 pb-3 px-4">
            <h4 class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">最近积分记录</h4>
            <c:choose>
                <c:when test="${empty scoreLogs}">
                    <p class="text-xs text-gray-400 py-2">暂无记录</p>
                </c:when>
                <c:otherwise>
                    <table class="w-full text-xs">
                        <thead>
                            <tr class="text-gray-400">
                                <th class="text-left font-normal pb-1">时间</th>
                                <th class="text-left font-normal pb-1">积分</th>
                                <th class="text-left font-normal pb-1">原因</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="log" items="${scoreLogs}">
                                <tr class="border-b border-gray-50">
                                    <td class="py-1.5 text-gray-500">${fn:substring(log.createdAt, 0, 10)}</td>
                                    <td class="py-1.5 font-semibold ${log.score > 0 ? 'text-green-500' : 'text-red-500'}">
                                        ${log.score > 0 ? '+' : ''}${log.score}
                                    </td>
                                    <td class="py-1.5 text-gray-600 truncate max-w-[80px]" title="${log.reason}">${log.reason}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    <div class="mt-2 text-right">
                        <a href="${pageContext.request.contextPath}/user/score-log" class="text-xs text-blue-500 hover:text-blue-600 no-underline">
                            查看全部 <i class="fa fa-angle-right"></i>
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</aside>
