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
<body class="bg-gray-100 min-h-screen flex flex-col">

<!-- 顶部导航 -->
<header class="bg-white shadow-sm sticky top-0 z-50 border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-6 h-14 flex items-center justify-between">
        <div class="flex items-center gap-3">
            <c:if test="${adminLayout}">
                <a href="${pageContext.request.contextPath}/" class="flex items-center gap-1 text-sm text-gray-500 hover:text-blue-500 no-underline transition" title="返回首页">
                    <i class="fa fa-home"></i> 返回首页
                </a>
                <span class="text-gray-300">|</span>
            </c:if>
            <a href="${pageContext.request.contextPath}/" class="text-xl font-bold text-red-500 no-underline">
                <i class="fa fa-fire"></i> BBS技术社区
            </a>
        </div>
        <div class="flex items-center gap-2">
            <!-- 搜索框 -->
            <form action="${pageContext.request.contextPath}/post/search" method="get" class="flex items-center">
                <input type="text" name="keyword" value="${param.keyword}" placeholder="搜索帖子..." class="w-48 px-3 py-1.5 text-sm border border-gray-300 rounded-l focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200" maxlength="50">
                <button type="submit" class="px-3 py-1.5 text-sm bg-gray-100 border border-l-0 border-gray-300 rounded-r text-gray-500 hover:bg-blue-500 hover:text-white hover:border-blue-500 transition cursor-pointer">
                    <i class="fa fa-search"></i>
                </button>
            </form>
            <!-- 热度榜 -->
            <a href="${pageContext.request.contextPath}/hot" class="flex items-center gap-1 px-3 py-1.5 text-sm text-orange-500 bg-orange-50 border border-orange-200 rounded hover:bg-orange-100 no-underline transition">
                <i class="fa fa-fire"></i> 热度榜
            </a>
        </div>
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

<!-- 通知提示 -->
<c:if test="${not empty param.success || not empty param.error}">
    <div class="max-w-7xl mx-auto px-6 pt-3">
        <c:choose>
            <c:when test="${not empty param.success}">
                <div class="flex items-center gap-2 px-4 py-3 bg-green-50 border border-green-200 rounded-lg text-sm text-green-700">
                    <i class="fa fa-check-circle"></i>
                    <span>
                        <c:choose>
                            <c:when test="${param.success == '1'}">发布成功！</c:when>
                            <c:otherwise>操作成功！</c:otherwise>
                        </c:choose>
                    </span>
                    <button onclick="this.parentElement.remove()" class="ml-auto text-green-500 hover:text-green-700 cursor-pointer">&times;</button>
                </div>
            </c:when>
            <c:when test="${not empty param.error}">
                <div class="flex items-center gap-2 px-4 py-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
                    <i class="fa fa-exclamation-circle"></i>
                    <span>
                        <c:choose>
                            <c:when test="${param.error == '1'}">操作失败，请重试</c:when>
                            <c:when test="${param.error == 'jifenbuzu'}">积分不足，无法发布悬赏</c:when>
                            <c:when test="${param.error == 'scorezero'}">悬赏积分必须大于 0</c:when>
                            <c:when test="${param.error == 'publish_failed'}">发布失败，请稍后重试</c:when>
                            <c:otherwise>操作失败：${param.error}</c:otherwise>
                        </c:choose>
                    </span>
                    <button onclick="this.parentElement.remove()" class="ml-auto text-red-500 hover:text-red-700 cursor-pointer">&times;</button>
                </div>
            </c:when>
        </c:choose>
    </div>
</c:if>

<!-- 主体 -->
<div class="flex-1">
<c:choose>
    <c:when test="${showSidebar}">
    <div class="max-w-7xl mx-auto px-6 py-5 flex gap-5">
        <!-- 侧边栏 -->
        <aside class="w-60 shrink-0">
        <div class="bg-white rounded-lg shadow-sm overflow-hidden sticky top-[72px]">
            <div class="px-4 pt-4 pb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">论坛板块</div>
            <ul>
                <li>
                    <a href="${pageContext.request.contextPath}/" class="flex items-start gap-2 px-4 py-3 no-underline ${empty currentCategory and empty demandActive ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                        <i class="fa fa-home mt-0.5"></i>
                        <div>
                            <div class="text-sm">全部帖子</div>
                            <div class="text-[11px] font-normal mt-0.5 ${empty currentCategory and empty demandActive ? 'text-blue-400' : 'text-gray-400'}">浏览所有板块的最新帖子</div>
                        </div>
                    </a>
                </li>
                <c:forEach var="cat" items="${applicationScope.categoryList}">
                    <c:if test="${cat.name != '需求悬赏'}">
                    <li>
                        <a href="${pageContext.request.contextPath}/category?id=${cat.id}" class="flex items-start gap-2 px-4 py-3 no-underline ${not empty currentCategory && currentCategory.id == cat.id ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                            <i class="fa fa-folder-o mt-0.5"></i>
                            <div>
                                <div class="text-sm">${cat.name}</div>
                                <div class="text-[11px] font-normal mt-0.5 ${not empty currentCategory && currentCategory.id == cat.id ? 'text-blue-400' : 'text-gray-400'}">${empty cat.description ? '浏览该板块帖子' : cat.description}</div>
                            </div>
                        </a>
                    </li>
                    </c:if>
                </c:forEach>
            </ul>
            <c:if test="${not empty sessionScope.user}">
                <div class="border-t border-gray-100 mt-1 pt-1">
                    <div class="px-4 pt-3 pb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">创作中心</div>
                    <ul>
                        <li>
                            <a href="${pageContext.request.contextPath}/post/create" class="flex items-start gap-2 px-4 py-3 no-underline text-gray-700 hover:bg-blue-50 hover:text-blue-500">
                                <i class="fa fa-edit mt-0.5"></i>
                                <div>
                                    <div class="text-sm">写文章</div>
                                    <div class="text-[11px] text-gray-400 font-normal mt-0.5">分享知识，发布技术帖子</div>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/demand/create" class="flex items-start gap-2 px-4 py-3 no-underline ${param.error == '1' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                                <i class="fa fa-gift mt-0.5"></i>
                                <div>
                                    <div class="text-sm">发布悬赏</div>
                                    <div class="text-[11px] text-gray-400 font-normal mt-0.5">发布需求，吸引他人解答</div>
                                </div>
                            </a>
                        </li>
                    </ul>
                </div>
            </c:if>
            <div class="border-t border-gray-100 mt-1 pt-1 pb-2">
                <div class="px-4 pt-3 pb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">热门推荐</div>
                <ul>
                    <li>
                        <a href="${pageContext.request.contextPath}/score/rank" class="flex items-start gap-2 px-4 py-3 no-underline text-gray-700 hover:bg-blue-50 hover:text-blue-500">
                            <i class="fa fa-trophy mt-0.5"></i>
                            <div>
                                <div class="text-sm">积分排行</div>
                                <div class="text-[11px] text-gray-400 font-normal mt-0.5">查看社区活跃用户排行</div>
                            </div>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/demand" class="flex items-start gap-2 px-4 py-3 no-underline ${demandActive ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                            <i class="fa fa-diamond mt-0.5"></i>
                            <div>
                                <div class="text-sm">需求悬赏</div>
                                <div class="text-[11px] text-gray-400 font-normal mt-0.5">浏览悬赏需求，赚取积分</div>
                            </div>
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </aside>

    <!-- 内容区 -->
    <main class="flex-1 min-w-0">
        <jsp:include page="${contentPage}" />
    </main>

    <!-- 右侧面板 -->
    <aside class="w-64 shrink-0 hidden lg:block">
        <div class="sticky top-[72px] space-y-4">

            <!-- 实时数据面板 -->
            <div class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
                <div class="px-4 py-3 border-b border-gray-100">
                    <h3 class="text-sm font-semibold text-gray-800"><i class="fa fa-bar-chart mr-1.5 text-blue-500"></i> 实时数据</h3>
                </div>
                <div class="grid grid-cols-2 gap-0">
                    <div class="px-4 py-3 border-r border-b border-gray-50">
                        <div class="text-lg font-bold text-blue-500">${statsPostCount}</div>
                        <div class="text-xs text-gray-400 mt-0.5">帖子总数</div>
                    </div>
                    <div class="px-4 py-3 border-b border-gray-50">
                        <div class="text-lg font-bold text-green-500">${statsReplyCount}</div>
                        <div class="text-xs text-gray-400 mt-0.5">评论总数</div>
                    </div>
                    <div class="px-4 py-3 border-r border-gray-50">
                        <div class="text-lg font-bold text-purple-500">${statsUserCount}</div>
                        <div class="text-xs text-gray-400 mt-0.5">用户总数</div>
                    </div>
                    <div class="px-4 py-3">
                        <div class="text-lg font-bold text-orange-500">${statsDemandCount}</div>
                        <div class="text-xs text-gray-400 mt-0.5">需求总数</div>
                    </div>
                </div>
            </div>

            <!-- 热门标签 -->
            <c:if test="${not empty statsHotKeywords}">
                <div class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
                    <div class="px-4 py-3 border-b border-gray-100">
                        <h3 class="text-sm font-semibold text-gray-800"><i class="fa fa-tags mr-1.5 text-orange-500"></i> 热门标签</h3>
                    </div>
                    <div class="px-4 py-3 flex flex-wrap gap-1.5">
                        <c:forEach var="kw" items="${statsHotKeywords}" varStatus="vs">
                            <a href="${pageContext.request.contextPath}/post/search?keyword=${kw.key}"
                               class="inline-block px-2.5 py-1 text-xs rounded-full border transition
                                   <c:choose>
                                       <c:when test="${vs.index == 0}">bg-orange-50 text-orange-600 border-orange-200 hover:bg-orange-100</c:when>
                                       <c:when test="${vs.index < 3}">bg-blue-50 text-blue-600 border-blue-200 hover:bg-blue-100</c:when>
                                       <c:otherwise>bg-gray-50 text-gray-500 border-gray-200 hover:bg-gray-100</c:otherwise>
                                   </c:choose> no-underline">
                                ${kw.key}
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

        </div>
    </aside>
</div>
</c:when>
<c:when test="${adminLayout}">
<div class="max-w-7xl mx-auto px-6 py-5 flex gap-5">
    <!-- 管理后台侧边栏 -->
    <aside class="w-60 shrink-0">
        <div class="bg-white rounded-lg shadow-sm overflow-hidden sticky top-[72px]">
            <div class="px-4 pt-4 pb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">
                <i class="fa fa-shield"></i> 后台管理
            </div>
            <ul>
                <li>
                    <a href="${pageContext.request.contextPath}/admin"
                       class="flex items-start gap-2 px-4 py-3 no-underline ${adminActiveMenu == 'dashboard' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                        <i class="fa fa-dashboard mt-0.5"></i>
                        <div>
                            <div class="text-sm">控制台</div>
                            <div class="text-[11px] ${adminActiveMenu == 'dashboard' ? 'text-blue-400' : 'text-gray-400'} font-normal mt-0.5">站点数据概览</div>
                        </div>
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/categories"
                       class="flex items-start gap-2 px-4 py-3 no-underline ${adminActiveMenu == 'categories' or adminActiveMenu == 'category_edit' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                        <i class="fa fa-th-list mt-0.5"></i>
                        <div>
                            <div class="text-sm">板块管理</div>
                            <div class="text-[11px] ${adminActiveMenu == 'categories' or adminActiveMenu == 'category_edit' ? 'text-blue-400' : 'text-gray-400'} font-normal mt-0.5">添加/编辑/删除板块</div>
                        </div>
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/post/manage"
                       class="flex items-start gap-2 px-4 py-3 no-underline ${adminActiveMenu == 'posts' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                        <i class="fa fa-file-text mt-0.5"></i>
                        <div>
                            <div class="text-sm">帖子管理</div>
                            <div class="text-[11px] ${adminActiveMenu == 'posts' ? 'text-blue-400' : 'text-gray-400'} font-normal mt-0.5">置顶/加精/编辑帖子</div>
                        </div>
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/users"
                       class="flex items-start gap-2 px-4 py-3 no-underline ${adminActiveMenu == 'users' or adminActiveMenu == 'user_edit' ? 'bg-blue-50 text-blue-500 font-medium' : 'text-gray-700 hover:bg-blue-50 hover:text-blue-500'}">
                        <i class="fa fa-users mt-0.5"></i>
                        <div>
                            <div class="text-sm">用户管理</div>
                            <div class="text-[11px] ${adminActiveMenu == 'users' or adminActiveMenu == 'user_edit' ? 'text-blue-400' : 'text-gray-400'} font-normal mt-0.5">查看/编辑/删除用户</div>
                        </div>
                    </a>
                </li>
            </ul>
        </div>
    </aside>

    <!-- 管理内容区 -->
    <main class="flex-1 min-w-0">
        <jsp:include page="${contentPage}" />
    </main>
</div>
</c:when>
<c:otherwise>
<div class="max-w-6xl mx-auto px-6 py-5">
    <main>
        <jsp:include page="${contentPage}" />
    </main>
</div>
</c:otherwise>
</c:choose>
</div>

<!-- 底部 -->
<footer class="bg-white border-t border-gray-200 py-5 mt-auto text-center text-xs text-gray-400">
    BBS技术社区 &copy; 2026 &middot; 课程设计项目
</footer>

<script src="${pageContext.request.contextPath}/js/common.js"></script>

<!-- 统一提示弹窗 -->
<div id="modalOverlay" class="fixed inset-0 z-50 hidden flex items-center justify-center bg-black/40" style="display:none;">
    <div id="modalBox" class="bg-white rounded-xl shadow-2xl max-w-sm w-full mx-4 overflow-hidden animate-modal">
        <div id="modalIconArea" class="p-5 text-center pb-2">
            <div id="modalIconWrap" class="w-14 h-14 mx-auto mb-3 rounded-full flex items-center justify-center">
                <i id="modalIcon" class="fa fa-info-circle text-2xl"></i>
            </div>
            <h4 id="modalTitle" class="text-lg font-semibold text-gray-900 mb-2">提示</h4>
            <p id="modalMsg" class="text-sm text-gray-500 leading-relaxed">消息内容</p>
        </div>
        <div id="modalBtnArea" class="flex border-t border-gray-100">
            <button id="modalBtnCancel" class="hidden flex-1 py-3 text-sm text-gray-500 hover:bg-gray-50 transition cursor-pointer border-none bg-transparent">取消</button>
            <button id="modalBtnConfirm" onclick="modalResolve(true)" class="flex-1 py-3 text-sm font-medium hover:bg-blue-50 transition cursor-pointer border-none bg-transparent">
                <i class="fa fa-check"></i> 确定
            </button>
        </div>
    </div>
</div>

<style>
.animate-modal { animation: modalFadeIn 0.15s ease-out; }
@keyframes modalFadeIn { from { opacity:0; transform:scale(0.95); } to { opacity:1; transform:scale(1); } }
</style>

<script>
var _modalResolve = null;

function modalResolve(val) {
    if (_modalResolve) _modalResolve(val);
    _modalResolve = null;
    document.getElementById('modalOverlay').style.display = 'none';
}

// 重写 alert
window.alert = function(msg) {
    return new Promise(function(resolve) {
        _modalResolve = resolve;
        var overlay = document.getElementById('modalOverlay');
        document.getElementById('modalIconWrap').className = 'w-14 h-14 mx-auto mb-3 rounded-full flex items-center justify-center bg-blue-50 border border-blue-200';
        document.getElementById('modalIcon').className = 'fa fa-info-circle text-2xl text-blue-500';
        document.getElementById('modalTitle').textContent = '提示';
        document.getElementById('modalMsg').textContent = msg;
        document.getElementById('modalBtnCancel').style.display = 'none';
        document.getElementById('modalBtnConfirm').innerHTML = '<i class="fa fa-check"></i> 确定';
        document.getElementById('modalBtnConfirm').className = 'flex-1 py-3 text-sm font-medium text-blue-600 hover:bg-blue-50 transition cursor-pointer border-none bg-transparent';
        overlay.style.display = 'flex';
    });
};

// 确认弹窗（返回 Promise<boolean>）
function showConfirm(msg) {
    return new Promise(function(resolve) {
        _modalResolve = resolve;
        var overlay = document.getElementById('modalOverlay');
        document.getElementById('modalIconWrap').className = 'w-14 h-14 mx-auto mb-3 rounded-full flex items-center justify-center bg-orange-50 border border-orange-200';
        document.getElementById('modalIcon').className = 'fa fa-question-circle text-2xl text-orange-500';
        document.getElementById('modalTitle').textContent = '确认操作';
        document.getElementById('modalMsg').textContent = msg;
        document.getElementById('modalBtnCancel').style.display = 'block';
        document.getElementById('modalBtnCancel').className = 'flex-1 py-3 text-sm text-gray-500 hover:bg-gray-50 transition cursor-pointer border-none bg-transparent';
        document.getElementById('modalBtnCancel').onclick = function() { modalResolve(false); };
        document.getElementById('modalBtnConfirm').innerHTML = '<i class="fa fa-check"></i> 确定';
        document.getElementById('modalBtnConfirm').className = 'flex-1 py-3 text-sm font-medium text-orange-600 hover:bg-orange-50 transition cursor-pointer border-none bg-transparent border-l border-gray-100';
        overlay.style.display = 'flex';
    });
}

// 错误弹窗
function showError(msg) {
    return new Promise(function(resolve) {
        _modalResolve = resolve;
        var overlay = document.getElementById('modalOverlay');
        document.getElementById('modalIconWrap').className = 'w-14 h-14 mx-auto mb-3 rounded-full flex items-center justify-center bg-red-50 border border-red-200';
        document.getElementById('modalIcon').className = 'fa fa-exclamation-circle text-2xl text-red-500';
        document.getElementById('modalTitle').textContent = '操作失败';
        document.getElementById('modalMsg').textContent = msg;
        document.getElementById('modalBtnCancel').style.display = 'none';
        document.getElementById('modalBtnConfirm').innerHTML = '<i class="fa fa-check"></i> 知道了';
        document.getElementById('modalBtnConfirm').className = 'flex-1 py-3 text-sm font-medium text-blue-600 hover:bg-blue-50 transition cursor-pointer border-none bg-transparent';
        overlay.style.display = 'flex';
    });
}

// 点击遮罩关闭提示
document.getElementById('modalOverlay').addEventListener('click', function(e) {
    if (e.target === this && document.getElementById('modalBtnCancel').style.display !== 'none') {
        modalResolve(false);
    }
});
</script>
</body>
</html>
