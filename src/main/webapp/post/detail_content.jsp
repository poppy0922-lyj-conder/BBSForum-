<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 面包屑 -->
<div class="flex items-center gap-2 text-sm text-gray-400 mb-4">
    <a href="${pageContext.request.contextPath}/" class="text-gray-500 hover:text-blue-500 no-underline">首页</a>
    <span>/</span>
    <a href="${pageContext.request.contextPath}/category?id=${post.categoryId}" class="text-gray-500 hover:text-blue-500 no-underline">${post.categoryName}</a>
    <span>/</span>
    <span class="text-gray-700">帖子详情</span>
</div>

<div class="flex gap-5">
<!-- ========== 左侧主体 ========== -->
<div class="flex-1 min-w-0">

<!-- 帖子主体 -->
<article class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden mb-6">
    <c:choose>
        <c:when test="${not empty post.imageUrl}">
            <div class="w-full bg-gray-100">
                <img src="${post.imageUrl}" alt="${post.title}" class="w-full max-h-80 object-cover" onerror="this.parentElement.style.display='none'">
            </div>
        </c:when>
        <c:otherwise>
            <div class="w-full bg-gray-100">
                <img src="${pageContext.request.contextPath}/cover/${post.id}?title=${fn:substring(post.title, 0, 1)}" alt="${post.title}" class="w-full max-h-80 object-cover">
            </div>
        </c:otherwise>
    </c:choose>
    <div class="p-6">
        <div class="mb-3">
            <c:if test="${post.isTop == 2}"><span class="inline-block px-2 py-0.5 text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-2">全局置顶</span></c:if>
            <c:if test="${post.isTop == 1}"><span class="inline-block px-2 py-0.5 text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-2">置顶</span></c:if>
            <c:if test="${post.isElite == 1}"><span class="inline-block px-2 py-0.5 text-xs font-medium text-pink-600 bg-pink-50 border border-pink-200 rounded">精华</span></c:if>
        </div>
        <h1 class="text-2xl font-bold text-gray-900 mb-4 leading-snug">${post.title}</h1>
        <c:if test="${not empty post.keywords}">
            <div class="flex items-center gap-1.5 flex-wrap mb-4">
                <c:forTokens var="kw" items="${post.keywords}" delims=",，">
                    <span class="inline-block px-2 py-0.5 text-xs bg-gray-100 text-gray-500 border border-gray-200 rounded-full">${kw}</span>
                </c:forTokens>
            </div>
        </c:if>
        <div class="flex items-center gap-5 text-sm text-gray-400 pb-5 border-b border-gray-100 flex-wrap">
            <span class="flex items-center gap-1.5">
                <span class="w-7 h-7 bg-blue-500 text-white rounded-full flex items-center justify-center text-xs font-bold">${fn:substring(post.authorName, 0, 1)}</span>
                <span class="text-gray-700 font-medium">${post.authorName}</span>
                <c:if test="${not empty sessionScope.user && sessionScope.user.id != post.userId}">
                    <button onclick="toggleFollow(${post.userId}, this)" class="ml-1 text-xs px-2 py-0.5 rounded border transition cursor-pointer ${userFollowed ? 'bg-blue-50 text-blue-600 border-blue-200 hover:bg-blue-100' : 'text-gray-500 border-gray-300 hover:bg-gray-100'}">
                        ${userFollowed ? '已关注' : '+ 关注'}
                    </button>
                </c:if>
            </span>
            <span><i class="fa fa-clock-o mr-1"></i> ${post.createdAt}</span>
            <span><i class="fa fa-eye mr-1"></i> ${post.viewCount} 次浏览</span>
        </div>
        <div id="aiSummaryBox" class="mb-5 <c:if test='${empty sessionScope.user || empty post.aiSummary}'>hidden</c:if>">
            <div class="bg-gradient-to-r from-purple-50 to-blue-50 border border-purple-200 rounded-lg p-4 flex items-start gap-3">
                <span class="text-lg mt-0.5">🤖</span>
                <div>
                    <span class="text-xs font-medium text-purple-600 bg-purple-100 px-2 py-0.5 rounded-full">AI 总结</span>
                    <p id="aiSummaryText" class="text-sm text-gray-700 mt-1.5 leading-relaxed">${post.aiSummary}</p>
                </div>
            </div>
        </div>
        <div class="py-6 text-gray-800 leading-relaxed text-[15px] post-content">
            ${post.contentRendered}
        </div>
        <div class="flex items-center gap-2 pt-4 border-t border-gray-100 flex-wrap">
            <button onclick="history.back()" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-gray-500 bg-gray-100 border border-gray-200 rounded hover:bg-gray-200 transition cursor-pointer">
                <i class="fa fa-arrow-left"></i> 返回
            </button>
            <button id="aiBtn" onclick="<c:choose><c:when test="${not empty sessionScope.user}">generateAiSummary(${post.id})</c:when><c:otherwise>alert('请先登录后再使用AI总结功能')</c:otherwise></c:choose>" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-purple-600 bg-purple-50 border border-purple-200 rounded hover:bg-purple-100 transition cursor-pointer">
                <i class="fa fa-magic"></i> <span id="aiBtnText">AI总结</span>
            </button>
            <c:if test="${not empty sessionScope.user}">
                <button onclick="toggleLike(${post.id}, this)" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm border rounded hover:bg-red-50 transition cursor-pointer ${userLiked ? 'text-red-600 bg-red-50 border-red-200' : 'text-gray-500 bg-white border-gray-200'}">
                    <i class="fa ${userLiked ? 'fa-heart' : 'fa-heart-o'}"></i> <span class="like-count">${post.likeCount}</span>
                </button>
                <button onclick="toggleFavorite(${post.id}, this)" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm border rounded hover:bg-yellow-50 transition cursor-pointer ${userFavorited ? 'text-yellow-600 bg-yellow-50 border-yellow-200' : 'text-gray-500 bg-white border-gray-200'}">
                    <i class="fa ${userFavorited ? 'fa-bookmark' : 'fa-bookmark-o'}"></i> <span class="favorite-count">${post.favoriteCount}</span>
                </button>
            </c:if>
            <c:if test="${sessionScope.user.id == post.userId || sessionScope.user.role == 'admin'}">
                <a href="${pageContext.request.contextPath}/post/edit?id=${post.id}" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-blue-600 bg-blue-50 border border-blue-200 rounded hover:bg-blue-100 no-underline transition">
                    <i class="fa fa-edit"></i> 编辑
                </a>
                <a href="${pageContext.request.contextPath}/post/delete?id=${post.id}" onclick="return confirm('确定删除此帖子？')" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-red-600 bg-red-50 border border-red-200 rounded hover:bg-red-100 no-underline transition">
                    <i class="fa fa-trash"></i> 删除
                </a>
            </c:if>
            <c:if test="${sessionScope.user.role == 'admin'}">
    <button onclick="adminAction('${pageContext.request.contextPath}/admin/post/top', ${post.id}, '板块置顶', '全局置顶', '取消置顶')"
            class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-orange-600 bg-orange-50 border border-orange-200 rounded hover:bg-orange-100 transition cursor-pointer active:scale-95">
        <i class="fa fa-arrow-up"></i>
        <c:choose>
            <c:when test="${post.isTop == 0}">设为板块置顶</c:when>
            <c:when test="${post.isTop == 1}">设为全局置顶</c:when>
            <c:otherwise>取消置顶</c:otherwise>
        </c:choose>
    </button>
    <button onclick="adminAction('${pageContext.request.contextPath}/admin/post/elite', ${post.id}, '加精', '取消加精')"
            class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-pink-600 bg-pink-50 border border-pink-200 rounded hover:bg-pink-100 transition cursor-pointer active:scale-95">
        <i class="fa fa-diamond"></i>
        <c:choose>
            <c:when test="${post.isElite == 0}">加精</c:when>
            <c:otherwise>取消加精</c:otherwise>
        </c:choose>
    </button>
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
                <c:forEach var="reply" items="${replyList}">
                    <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-5">
                        <div class="flex items-center gap-3 mb-3">
                            <span class="w-7 h-7 bg-green-500 text-white rounded-full flex items-center justify-center text-xs font-bold">${fn:substring(reply.authorName, 0, 1)}</span>
                            <span class="text-sm font-medium text-gray-700">${reply.authorName}</span>
                            <span class="text-xs text-gray-400">${reply.createdAt}</span>
                            <span class="text-xs text-gray-300 ml-auto">#${reply.floor}</span>
                        </div>
                        <p class="text-sm text-gray-700 leading-relaxed whitespace-pre-wrap">${reply.content}</p>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</section>

<!-- 回复表单 -->
<c:choose>
    <c:when test="${not empty sessionScope.user}">
        <section class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
            <h3 class="text-base font-semibold text-gray-900 mb-4"><i class="fa fa-reply mr-1"></i> 发表回复</h3>
            <form action="${pageContext.request.contextPath}/post/reply" method="post">
                <input type="hidden" name="postId" value="${post.id}">
                <textarea name="content" rows="4" placeholder="写下你的回复..." class="w-full px-4 py-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 resize-none mb-4" required></textarea>
                <button type="submit" class="inline-flex items-center gap-1.5 px-5 py-2 bg-blue-500 text-white text-sm rounded-md hover:bg-blue-600 transition cursor-pointer border-none">
                    <i class="fa fa-send"></i> 提交回复
                </button>
            </form>
        </section>
    </c:when>
    <c:otherwise>
        <div class="bg-gray-50 rounded-lg border border-gray-200 p-6 text-center">
            <p class="text-sm text-gray-500 mb-3">登录后才能发表回复</p>
            <a href="${pageContext.request.contextPath}/user/login" class="inline-flex items-center gap-1 px-4 py-2 bg-blue-500 text-white text-sm rounded-md hover:bg-blue-600 no-underline transition">
                <i class="fa fa-sign-in"></i> 立即登录
            </a>
        </div>
        <script>
        // 未登录时，回复表单区域获得焦点自动弹窗提示
        document.addEventListener('DOMContentLoaded', function() {
            var replyForm = document.querySelector('section.bg-white.rounded-lg.shadow-sm form');
            if (replyForm) {
                replyForm.addEventListener('click', function(e) {
                    alert('请先登录后再发表回复');
                    e.preventDefault();
                });
            }
        });
        </script>
    </c:otherwise>
</c:choose>

</div><!-- /左侧主体 -->

<!-- ========== 右侧相关推荐 ========== -->
<c:if test="${not empty relatedPosts}">
<aside class="w-64 shrink-0 hidden lg:block">
    <div class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden sticky top-[72px]">
        <div class="px-4 py-3 border-b border-gray-100">
            <h3 class="text-sm font-semibold text-gray-900"><i class="fa fa-lightbulb-o mr-1 text-yellow-500"></i> 相关推荐</h3>
        </div>
        <div class="divide-y divide-gray-50">
            <c:forEach var="rp" items="${relatedPosts}">
                <a href="${pageContext.request.contextPath}/post/detail?id=${rp.id}" class="block px-4 py-3 hover:bg-blue-50 transition no-underline">
                    <p class="text-sm text-gray-700 leading-snug line-clamp-2 mb-1.5">${rp.title}</p>
                    <div class="flex items-center gap-2 text-xs text-gray-400">
                        <span>${rp.authorName}</span>
                        <span><i class="fa fa-eye"></i> ${rp.viewCount}</span>
                    </div>
                </a>
            </c:forEach>
        </div>
    </div>
</aside>
</c:if>

</div><!-- /flex -->

<script>
    // 当前帖子的状态，供 adminAction 正确显示提示信息
    window.currentPost = {
        isTop: ${post.isTop},
        isElite: ${post.isElite}
    };
</script>

<script>
function generateAiSummary(postId) {
    var btn = document.getElementById('aiBtn');
    var btnText = document.getElementById('aiBtnText');
    var box = document.getElementById('aiSummaryBox');
    var text = document.getElementById('aiSummaryText');
    btn.disabled = true;
    btnText.textContent = '生成中...';
    fetch('${pageContext.request.contextPath}/post/aiSummary', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'id=' + postId
    }).then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.summary) {
            text.textContent = data.summary;
            text.style.color = '';
            box.classList.remove('hidden');
        } else {
            text.textContent = data.error || '生成失败';
            text.style.color = '#ef4444';
            box.classList.remove('hidden');
            setTimeout(function() { box.classList.add('hidden'); text.style.color = ''; }, 3000);
        }
        btnText.textContent = 'AI总结';
        btn.disabled = false;
    }).catch(function() {
        text.textContent = '网络错误，请重试';
        text.style.color = '#ef4444';
        box.classList.remove('hidden');
        btnText.textContent = 'AI总结';
        btn.disabled = false;
    });
}

function toggleFollow(authorId, btn) {
    fetch('${pageContext.request.contextPath}/interact/follow', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'userId=' + authorId
    }).then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.ok) {
            if (data.action === 'follow') {
                btn.textContent = '已关注';
                btn.className = 'ml-1 text-xs px-2 py-0.5 rounded border transition cursor-pointer bg-blue-50 text-blue-600 border-blue-200 hover:bg-blue-100';
            } else {
                btn.textContent = '+ 关注';
                btn.className = 'ml-1 text-xs px-2 py-0.5 rounded border transition cursor-pointer text-gray-500 border-gray-300 hover:bg-gray-100';
            }
        } else {
            alert(data.msg || '操作失败');
        }
    }).catch(function() { alert('网络错误，请重试'); });
}

function toggleLike(postId, btn) {
    fetch('${pageContext.request.contextPath}/interact/like', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'postId=' + postId
    }).then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.ok) {
            var icon = btn.querySelector('i');
            var countSpan = btn.querySelector('.like-count');
            if (data.action === 'like') {
                icon.className = 'fa fa-heart';
                btn.className = 'inline-flex items-center gap-1 px-3 py-1.5 text-sm border rounded hover:bg-red-50 transition cursor-pointer text-red-600 bg-red-50 border-red-200';
            } else {
                icon.className = 'fa fa-heart-o';
                btn.className = 'inline-flex items-center gap-1 px-3 py-1.5 text-sm border rounded hover:bg-red-50 transition cursor-pointer text-gray-500 bg-white border-gray-200';
            }
            countSpan.textContent = data.count;
        } else {
            alert(data.msg || '操作失败');
        }
    }).catch(function() { alert('网络错误，请重试'); });
}

function toggleFavorite(postId, btn) {
    fetch('${pageContext.request.contextPath}/interact/favorite', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'postId=' + postId
    }).then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.ok) {
            var icon = btn.querySelector('i');
            var countSpan = btn.querySelector('.favorite-count');
            if (data.action === 'favorite') {
                icon.className = 'fa fa-bookmark';
                btn.className = 'inline-flex items-center gap-1 px-3 py-1.5 text-sm border rounded hover:bg-yellow-50 transition cursor-pointer text-yellow-600 bg-yellow-50 border-yellow-200';
            } else {
                icon.className = 'fa fa-bookmark-o';
                btn.className = 'inline-flex items-center gap-1 px-3 py-1.5 text-sm border rounded hover:bg-yellow-50 transition cursor-pointer text-gray-500 bg-white border-gray-200';
            }
            countSpan.textContent = data.count;
        } else {
            alert(data.msg || '操作失败');
        }
    }).catch(function() { alert('网络错误，请重试'); });
}

function adminAction(url, postId, actionText, actionText2, actionText3) {
    console.log('开始执行操作:', url, '帖子ID:', postId);

    // 根据URL判断操作类型
    let actionType = '';
    let confirmMessage = '';

    if (url.includes('/admin/post/top')) {
        actionType = '置顶';
        if (typeof actionText !== 'undefined' && typeof actionText2 !== 'undefined' && typeof actionText3 !== 'undefined') {
            // 使用全局变量 currentPost
            if (window.currentPost && typeof window.currentPost.isTop !== 'undefined') {
                var topStatus = window.currentPost.isTop;
                if (topStatus === 0) {
                    confirmMessage = '确定要' + actionText + '此帖子吗？\n\n注意：置顶操作将使帖子在板块列表中置顶显示。';
                } else if (topStatus === 1) {
                    confirmMessage = '确定要' + actionText2 + '此帖子吗？\n\n注意：全局置顶将使帖子在首页置顶显示。';
                } else if (topStatus === 2) {
                    confirmMessage = '确定要' + actionText3 + '此帖子吗？\n\n注意：取消置顶后帖子将恢复正常显示顺序。';
                } else {
                    confirmMessage = '确定要' + actionText + '此帖子吗？';
                }
            } else {
                // 降级提示（理论上不会触发）
                confirmMessage = '确定要' + actionText + '此帖子吗？';
            }
        } else {
            confirmMessage = '确定要执行置顶操作吗？';
        }
    }
    else if (url.includes('/admin/post/elite')) {
        actionType = '加精';
        if (typeof actionText !== 'undefined' && typeof actionText2 !== 'undefined') {
            if (window.currentPost && typeof window.currentPost.isElite !== 'undefined') {
                var eliteStatus = window.currentPost.isElite;
                if (eliteStatus === 0) {
                    confirmMessage = '确定要' + actionText + '此帖子吗？\n\n注意：加精操作将标记此帖子为优质内容。';
                } else if (eliteStatus === 1) {
                    confirmMessage = '确定要' + actionText2 + '此帖子吗？\n\n注意：取消加精后帖子将不再显示精华标记。';
                } else {
                    confirmMessage = '确定要' + actionText + '此帖子吗？';
                }
            } else {
                confirmMessage = '确定要' + actionText + '此帖子吗？';
            }
        } else {
            confirmMessage = '确定要执行加精操作吗？';
        }
    }

    if (confirm(confirmMessage)) {
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'id=' + postId
        }).then(function(r) {
            console.log('请求成功:', r);
            if (r.ok) {
                location.reload();
            } else {
                alert('操作失败，服务器返回: ' + r.status);
            }
        }).catch(function(error) {
            console.error('请求失败:', error);
            alert('操作失败，请重试: ' + error.message);
        });
    } else {
        console.log('用户取消了操作');
    }
}
</script>
