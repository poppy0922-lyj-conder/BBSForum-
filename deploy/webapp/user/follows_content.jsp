<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 个人中心专用布局：左右分栏 -->
<div class="flex gap-5">
    <!-- 左侧边栏 -->
    <c:set var="activeMenu" value="follows" scope="request" />
    <jsp:include page="/user/profile_sidebar.jsp" />

    <!-- 右侧主内容区 -->
    <main class="flex-1 min-w-0">
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-lg font-bold text-gray-900 mb-5 flex items-center gap-2">
                <i class="fa fa-users text-blue-500"></i> 我的关注
            </h2>

            <c:choose>
                <c:when test="${empty followList}">
                    <div class="text-center py-12 text-gray-400">
                        <i class="fa fa-user-plus text-4xl block mb-3"></i>
                        <p class="text-sm">还没有关注任何人，去浏览帖子关注感兴趣的作者吧！</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="space-y-3">
                        <c:forEach var="f" items="${followList}">
                            <div class="flex items-center gap-3 p-4 border border-gray-100 rounded-lg hover:bg-gray-50 transition">
                                <span class="w-9 h-9 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-bold shrink-0">${fn:substring(f.username, 0, 1)}</span>
                                <div class="flex-1 min-w-0">
                                    <div class="text-sm font-medium text-gray-900">${f.username}</div>
                                    <div class="text-xs text-gray-400 mt-0.5">
                                        ${empty f.jobType ? '未填写工作性质' : f.jobType}
                                        <c:if test="${not empty f.jobLocation}"> · ${f.jobLocation}</c:if>
                                    </div>
                                </div>
                                <button onclick="unfollow(${f.id}, this)" class="text-xs px-3 py-1.5 border border-gray-300 rounded text-gray-500 hover:text-red-600 hover:border-red-200 hover:bg-red-50 transition cursor-pointer bg-transparent">
                                    <i class="fa fa-user-times"></i> 取消关注
                                </button>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<script>
async function unfollow(userId, btn) {
    var ok = await showConfirm('确定取消关注？');
    if (!ok) return;
    fetch('${pageContext.request.contextPath}/interact/follow', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'userId=' + userId
    }).then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.ok) {
            var card = btn.closest('.flex');
            card.style.transition = 'opacity 0.3s';
            card.style.opacity = '0';
            setTimeout(function() { card.remove(); }, 300);
        } else {
            alert(data.msg || '操作失败');
        }
    }).catch(function() { alert('网络错误'); });
}
</script>
