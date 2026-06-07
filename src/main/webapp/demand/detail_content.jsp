<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 面包屑 -->
<div class="flex items-center gap-2 text-sm text-gray-400 mb-4">
    <a href="${pageContext.request.contextPath}/" class="text-gray-500 hover:text-blue-500 no-underline">首页</a>
    <span>/</span>
    <a href="${pageContext.request.contextPath}/demand" class="text-gray-500 hover:text-blue-500 no-underline">需求列表</a>
    <span>/</span>
    <span class="text-gray-700">需求详情</span>
</div>

<c:if test="${param.updated == '1'}">
    <div class="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg text-sm text-green-700">
        <i class="fa fa-check-circle mr-1"></i> 需求已更新
    </div>
</c:if>
<c:if test="${param.accepted == '1'}">
    <div class="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg text-sm text-green-700">
        <i class="fa fa-check-circle mr-1"></i> 已成功采纳回复，积分已转给回复者
    </div>
</c:if>
<c:if test="${not empty param.error}">
    <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-600">
        <i class="fa fa-exclamation-circle mr-1"></i>
        <c:choose>
            <c:when test="${param.error == 'edit_failed'}">编辑失败，请稍后重试</c:when>
            <c:when test="${param.error == 'accept_failed'}">采纳回复失败，请稍后重试</c:when>
            <c:otherwise>操作失败：${param.error}</c:otherwise>
        </c:choose>
    </div>
</c:if>

<div class="flex gap-5">
<!-- ========== 左侧主体 ========== -->
<div class="flex-1 min-w-0">

<!-- 需求主体 -->
<article class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden mb-6">
    <div class="p-6">
        <div class="mb-3 flex items-center gap-2 flex-wrap">
            <c:choose>
                <c:when test="${demand.status == 'open'}">
                    <span class="inline-block px-2 py-0.5 text-xs font-medium text-green-600 bg-green-50 border border-green-200 rounded">进行中</span>
                </c:when>
                <c:otherwise>
                    <span class="inline-block px-2 py-0.5 text-xs font-medium text-gray-500 bg-gray-100 border border-gray-200 rounded">已结束</span>
                </c:otherwise>
            </c:choose>
            <span class="inline-flex items-center gap-1 px-2 py-0.5 text-xs font-medium text-orange-600 bg-orange-50 border border-orange-200 rounded">
                <i class="fa fa-diamond"></i> ${demand.score} 积分
            </span>
        </div>

        <h1 class="text-2xl font-bold text-gray-900 mb-4 leading-snug">${demand.title}</h1>

        <div class="flex items-center gap-5 text-sm text-gray-400 pb-5 border-b border-gray-100 flex-wrap">
            <span class="flex items-center gap-1.5">
                <span class="w-7 h-7 bg-orange-400 text-white rounded-full flex items-center justify-center text-xs font-bold">${fn:substring(demand.authorName, 0, 1)}</span>
                <span class="text-gray-700 font-medium">${demand.authorName}</span>
            </span>
            <span><i class="fa fa-clock-o mr-1"></i> ${demand.createdAt}</span>
            <span><i class="fa fa-tag mr-1"></i> ${demand.status == 'open' ? '进行中' : '已结束'}</span>
        </div>

        <div class="py-6 text-gray-800 leading-relaxed text-[15px]">
            ${demand.content}
        </div>

        <div class="flex items-center gap-2 pt-4 border-t border-gray-100 flex-wrap">
            <button onclick="history.back()" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-gray-500 bg-gray-100 border border-gray-200 rounded hover:bg-gray-200 transition cursor-pointer">
                <i class="fa fa-arrow-left"></i> 返回
            </button>
            <c:if test="${sessionScope.user.id == demand.userId && demand.status == 'open'}">
                <a href="${pageContext.request.contextPath}/demand/update?id=${demand.id}"
                   class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-blue-600 bg-blue-50 border border-blue-200 rounded hover:bg-blue-100 no-underline transition">
                    <i class="fa fa-edit"></i> 编辑
                </a>
            </c:if>
        </div>
    </div>
</article>

<!-- 回复列表 -->
<section class="mb-6">
    <h3 class="text-lg font-semibold text-gray-900 mb-4">
        <i class="fa fa-comments mr-1"></i> 回复（${replyCount}）
    </h3>
    <c:choose>
        <c:when test="${empty replyList}">
            <div class="text-center py-12 bg-white rounded-lg border border-gray-100 text-gray-400">
                <i class="fa fa-commenting-o text-4xl block mb-3"></i>
                <p class="text-sm">暂无回复，快来抢沙发！</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="space-y-3">
                <c:forEach var="reply" items="${replyList}" varStatus="status">
                    <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-5 <c:if test='${reply.id == demand.bestReplyId}'>ring-2 ring-orange-300 border-orange-200</c:if>">
                        <div class="flex items-center gap-3 mb-3">
                            <span class="w-7 h-7 bg-green-500 text-white rounded-full flex items-center justify-center text-xs font-bold">${fn:substring(reply.authorName, 0, 1)}</span>
                            <span class="text-sm font-medium text-gray-700">${reply.authorName}</span>
                            <span class="text-xs text-gray-400">${reply.createdAt}</span>
                            <c:if test="${reply.id == demand.bestReplyId}">
                                <span class="inline-flex items-center gap-1 px-1.5 py-0.5 text-xs font-medium text-orange-600 bg-orange-50 border border-orange-200 rounded-full">
                                    <i class="fa fa-check-circle"></i> 已采纳
                                </span>
                            </c:if>
                            <span class="text-xs text-gray-300 ml-auto">#${status.index + 1}</span>
                        </div>
                        <p class="text-sm text-gray-700 leading-relaxed whitespace-pre-wrap">${reply.content}</p>

                        <!-- 采纳按钮 -->
                        <c:if test="${sessionScope.user.id == demand.userId && demand.status == 'open' && reply.id != demand.bestReplyId}">
                            <div class="mt-3 pt-3 border-t border-gray-50">
                                <button onclick="showAcceptModal(${demand.id}, ${reply.id}, ${demand.score})"
                                   class="inline-flex items-center gap-1 px-3 py-1.5 text-xs text-orange-600 bg-orange-50 border border-orange-200 rounded hover:bg-orange-100 transition cursor-pointer">
                                    <i class="fa fa-check"></i> 采纳此回复
                                </button>
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</section>

<!-- 回复表单 -->
<c:choose>
    <c:when test="${not empty sessionScope.user && demand.status == 'open'}">
        <section class="bg-white rounded-lg shadow-sm border border-gray-100 p-6 mb-6">
            <h3 class="text-base font-semibold text-gray-900 mb-4"><i class="fa fa-reply mr-1"></i> 发表回复</h3>
            <form action="${pageContext.request.contextPath}/demand/reply" method="post">
                <input type="hidden" name="demandId" value="${demand.id}">
                <textarea name="content" rows="4" placeholder="写下你的回复..." class="w-full px-4 py-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 resize-none mb-4" required></textarea>
                <button type="submit" class="inline-flex items-center gap-1.5 px-5 py-2 bg-blue-500 text-white text-sm rounded-md hover:bg-blue-600 transition cursor-pointer border-none">
                    <i class="fa fa-send"></i> 提交回复
                </button>
            </form>
        </section>
    </c:when>
    <c:when test="${not empty sessionScope.user && demand.status == 'closed'}">
        <div class="bg-gray-50 rounded-lg border border-gray-200 p-6 text-center mb-6">
            <p class="text-sm text-gray-500"><i class="fa fa-lock mr-1"></i> 该需求已结束，无法继续回复</p>
        </div>
    </c:when>
    <c:otherwise>
        <div class="bg-gray-50 rounded-lg border border-gray-200 p-6 text-center mb-6">
            <p class="text-sm text-gray-500 mb-3">登录后才能发表回复</p>
            <a href="${pageContext.request.contextPath}/user/login" class="inline-flex items-center gap-1 px-4 py-2 bg-blue-500 text-white text-sm rounded-md hover:bg-blue-600 no-underline transition">
                <i class="fa fa-sign-in"></i> 立即登录
            </a>
        </div>
    </c:otherwise>
</c:choose>

</div><!-- /左侧主体 -->

<!-- ========== 右侧信息 ========== -->
<aside class="w-64 shrink-0 hidden lg:block">
    <div class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden sticky top-[72px]">
        <div class="px-4 py-3 border-b border-gray-100">
            <h3 class="text-sm font-semibold text-gray-900"><i class="fa fa-info-circle mr-1 text-blue-500"></i> 需求信息</h3>
        </div>
        <div class="p-4 space-y-3">
            <div>
                <div class="text-xs text-gray-400 mb-1">发布者</div>
                <div class="flex items-center gap-2">
                    <span class="w-7 h-7 bg-orange-400 text-white rounded-full flex items-center justify-center text-xs font-bold">${fn:substring(demand.authorName, 0, 1)}</span>
                    <span class="text-sm font-medium text-gray-700">${demand.authorName}</span>
                </div>
            </div>
            <div>
                <div class="text-xs text-gray-400 mb-1">悬赏积分</div>
                <div class="text-lg font-bold text-orange-500">
                    <i class="fa fa-diamond"></i> ${demand.score}
                </div>
            </div>
            <div>
                <div class="text-xs text-gray-400 mb-1">状态</div>
                <c:choose>
                    <c:when test="${demand.status == 'open'}">
                        <span class="inline-flex items-center gap-1 px-2 py-0.5 text-xs font-medium text-green-600 bg-green-50 border border-green-200 rounded">
                            <i class="fa fa-circle text-[8px]"></i> 进行中
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="inline-flex items-center gap-1 px-2 py-0.5 text-xs font-medium text-gray-500 bg-gray-100 border border-gray-200 rounded">
                            <i class="fa fa-circle text-[8px]"></i> 已结束
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div>
                <div class="text-xs text-gray-400 mb-1">发布时间</div>
                <div class="text-sm text-gray-600">${demand.createdAt}</div>
            </div>
            <c:if test="${sessionScope.user.id == demand.userId && demand.status == 'open'}">
                <div class="pt-2 border-t border-gray-100">
                    <p class="text-xs text-gray-400 leading-relaxed">
                        <i class="fa fa-info-circle mr-1"></i> 你可以采纳一条最佳回复，采纳后积分将转给该回复者
                    </p>
                </div>
            </c:if>
        </div>
    </div>
</aside>

</div><!-- /flex -->

<!-- 采纳确认弹窗 -->
<div id="acceptModal" class="fixed inset-0 z-50 hidden flex items-center justify-center bg-black/40" style="display:none;">
    <div class="bg-white rounded-xl shadow-2xl max-w-sm w-full mx-4 overflow-hidden animate-fade-in">
        <div class="p-5 text-center">
            <div class="w-14 h-14 mx-auto mb-3 rounded-full bg-orange-50 border border-orange-200 flex items-center justify-center">
                <i class="fa fa-check-circle text-2xl text-orange-500"></i>
            </div>
            <h4 class="text-lg font-semibold text-gray-900 mb-2">确认采纳</h4>
            <p class="text-sm text-gray-500 mb-1">确定采纳此回复为最佳答案？</p>
            <p class="text-sm text-orange-600 font-medium" id="acceptScoreText">积分将转给该回复者</p>
        </div>
        <div class="flex border-t border-gray-100">
            <button onclick="closeAcceptModal()" class="flex-1 py-3 text-sm text-gray-500 hover:bg-gray-50 transition cursor-pointer border-none bg-transparent">取消</button>
            <button id="acceptConfirmBtn" onclick="doAccept()" class="flex-1 py-3 text-sm text-orange-600 font-medium hover:bg-orange-50 transition cursor-pointer border-none bg-transparent border-l border-gray-100">
                <i class="fa fa-check"></i> 确定采纳
            </button>
        </div>
    </div>
</div>

<style>
.animate-fade-in { animation: fadeIn 0.15s ease-out; }
@keyframes fadeIn { from { opacity:0; transform:scale(0.95); } to { opacity:1; transform:scale(1); } }
</style>

<script>
var acceptData = { demandId: null, replyId: null };

function showAcceptModal(demandId, replyId, score) {
    acceptData.demandId = demandId;
    acceptData.replyId = replyId;
    document.getElementById('acceptScoreText').textContent = '将转给该回复者 ' + score + ' 积分';
    document.getElementById('acceptModal').style.display = 'flex';
}

function closeAcceptModal() {
    document.getElementById('acceptModal').style.display = 'none';
}

function doAccept() {
    var btn = document.getElementById('acceptConfirmBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa fa-spinner fa-pulse"></i> 处理中...';

    fetch('${pageContext.request.contextPath}/demand/accept', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'demandId=' + acceptData.demandId + '&replyId=' + acceptData.replyId
    }).then(function(r) {
        if (r.ok) {
            location.reload();
        } else {
            alert('操作失败，请重试');
            btn.disabled = false;
            btn.innerHTML = '<i class="fa fa-check"></i> 确定采纳';
            closeAcceptModal();
        }
    }).catch(function() {
        alert('网络错误');
        btn.disabled = false;
        btn.innerHTML = '<i class="fa fa-check"></i> 确定采纳';
        closeAcceptModal();
    });
}

// 点击遮罩层关闭
document.getElementById('acceptModal').addEventListener('click', function(e) {
    if (e.target === this) closeAcceptModal();
});
</script>
