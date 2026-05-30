<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - BBS技术社区</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>tailwind.config={theme:{extend:{colors:{primary:'#1677ff',danger:'#ff4d4f',warn:'#fa8c16',elite:'#eb2f96'}}}}</script>
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
</head>
<body class="bg-gray-100 min-h-screen">

<!-- 顶部导航 -->
<header class="bg-white shadow-sm sticky top-0 z-50 border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-6 h-14 flex items-center justify-between">
        <a href="${pageContext.request.contextPath}/" class="text-xl font-bold text-red-500 no-underline">
            <i class="fa fa-fire"></i> BBS技术社区
        </a>
        <nav class="flex gap-1 items-center">
            <a href="${pageContext.request.contextPath}/" class="px-4 py-1.5 text-sm text-gray-600 hover:bg-gray-100 rounded">首页</a>
            <c:forEach var="cat" items="${sessionScope.categoryList}">
                <a href="${pageContext.request.contextPath}/category?id=${cat.id}" class="px-4 py-1.5 text-sm text-gray-600 hover:bg-gray-100 rounded">${cat.name}</a>
            </c:forEach>
            <!-- 搜索框 -->
            <form action="${pageContext.request.contextPath}/post/search" method="get" class="ml-4 flex items-center">
                <input type="text" name="keyword" value="${param.keyword}" placeholder="搜索帖子..." class="w-40 px-3 py-1.5 text-sm border border-gray-300 rounded-l focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200" maxlength="50">
                <button type="submit" class="px-3 py-1.5 text-sm bg-gray-100 border border-l-0 border-gray-300 rounded-r text-gray-500 hover:bg-blue-500 hover:text-white hover:border-blue-500 transition cursor-pointer">
                    <i class="fa fa-search"></i>
                </button>
            </form>
        </nav>
        <div class="flex items-center gap-3">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <span class="w-8 h-8 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-bold">${fn:substring(sessionScope.user.username, 0, 1)}</span>
                    <span class="text-sm text-gray-700">${sessionScope.user.username}</span>
                    <c:if test="${sessionScope.user.role == 'admin'}">
                        <a href="${pageContext.request.contextPath}/admin" class="text-xs px-3 py-1 border border-gray-300 rounded text-gray-600 hover:text-blue-500 no-underline">管理</a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/user/profile" class="text-xs px-3 py-1 border border-gray-300 rounded text-gray-600 hover:text-blue-500 no-underline">我的</a>
                    <a href="${pageContext.request.contextPath}/logout" class="text-xs px-3 py-1 border border-gray-300 rounded text-gray-600 hover:text-blue-500 no-underline">退出</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/user/login" class="text-sm px-4 py-1.5 border border-gray-300 rounded text-gray-600 hover:text-blue-500 no-underline">登录</a>
                    <a href="${pageContext.request.contextPath}/user/register" class="text-sm px-4 py-1.5 bg-blue-500 text-white rounded hover:bg-blue-600 no-underline">注册</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>

<!-- 主体 -->
<div class="max-w-7xl mx-auto px-6 py-5 flex gap-5">
    <!-- 侧边栏 -->
    <aside class="w-56 shrink-0">
        <div class="bg-white rounded-lg shadow-sm overflow-hidden sticky top-[72px]">
            <div class="px-4 pt-4 pb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">论坛板块</div>
            <ul>
                <li><a href="${pageContext.request.contextPath}/" class="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-500 no-underline ${empty param.id ? 'bg-blue-50 text-blue-500 font-medium' : ''}"><i class="fa fa-home"></i> 全部帖子</a></li>
                <c:forEach var="cat" items="${sessionScope.categoryList}">
                    <li><a href="${pageContext.request.contextPath}/category?id=${cat.id}" class="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-500 no-underline"><i class="fa fa-folder-o"></i> ${cat.name}</a></li>
                </c:forEach>
            </ul>
            <c:if test="${not empty sessionScope.user}">
                <div class="border-t border-gray-100 mt-1 pt-1">
                    <div class="px-4 pt-3 pb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">创作中心</div>
                    <ul>
                        <li><a href="${pageContext.request.contextPath}/post/create" class="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-500 no-underline"><i class="fa fa-edit"></i> 写文章</a></li>
                        <li><a href="${pageContext.request.contextPath}/demand/create" class="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-500 no-underline"><i class="fa fa-gift"></i> 发布悬赏</a></li>
                    </ul>
                </div>
            </c:if>
            <div class="border-t border-gray-100 mt-1 pt-1 pb-2">
                <div class="px-4 pt-3 pb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">热门推荐</div>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/score/rank" class="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-500 no-underline"><i class="fa fa-trophy"></i> 积分排行</a></li>
                    <li><a href="${pageContext.request.contextPath}/demand" class="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-500 no-underline"><i class="fa fa-diamond"></i> 需求悬赏</a></li>
                </ul>
            </div>
        </div>
    </aside>

    <!-- 内容区 -->
    <main class="flex-1 min-w-0">
        <jsp:include page="${contentPage}" />
    </main>
</div>

<!-- 底部 -->
<footer class="bg-white border-t border-gray-200 py-5 mt-8 text-center text-xs text-gray-400">
    BBS技术社区 &copy; 2026 &middot; 课程设计项目
</footer>

<script src="${pageContext.request.contextPath}/js/common.js"></script>
</body>
</html>
