<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 面包屑 -->
<div class="flex items-center gap-2 text-sm text-gray-400 mb-4">
    <a href="${pageContext.request.contextPath}/" class="text-gray-500 hover:text-blue-500 no-underline">首页</a>
    <span>/</span>
    <span class="text-gray-700">发布帖子</span>
</div>

<c:if test="${not empty error}">
    <div class="flex items-center gap-2 bg-red-50 text-red-600 border border-red-200 rounded px-4 py-2.5 text-sm mb-5">
        <i class="fa fa-exclamation-circle"></i> ${error}
    </div>
</c:if>

<!-- 左右分栏布局（可拖拽调整） -->
<div class="flex" style="gap:0;">
    <!-- ====== 左侧：表单 ====== -->
    <div class="flex-1 min-w-0" style="margin-right:12px;">
        <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
            <h2 class="text-xl font-bold text-gray-900 mb-6">
                <i class="fa fa-pencil mr-1"></i> 发布帖子
            </h2>

            <form action="${pageContext.request.contextPath}/post/create" method="post" enctype="multipart/form-data" id="postForm">
                <!-- 板块选择 -->
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">选择板块 *</label>
                    <select name="categoryId" id="preCategory" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 bg-white" required>
                        <option value="">-- 请选择板块 --</option>
                        <c:forEach var="cat" items="${applicationScope.categoryList}">
                            <option value="${cat.id}">${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- 标题 -->
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">标题 *</label>
                    <div class="relative">
                        <input type="text" name="title" id="postTitle" value="${param.title}"
                               class="w-full px-3 py-2 pr-16 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200"
                               placeholder="请输入帖子标题（最多100字）" maxlength="100" required>
                        <span id="titleCount" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-xs text-gray-400">0/100</span>
                    </div>
                </div>

                <!-- 关键词 -->
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">关键词（可选，逗号分隔）</label>
                    <input type="text" name="keywords" id="preKeywords" value="${param.keywords}" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200" placeholder="如：Java, Spring Boot, 教程" maxlength="200">
                </div>

                <!-- 内容 -->
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">内容 *</label>
                    <!-- 编辑工具栏 -->
                    <div id="editorToolbar" class="flex items-center gap-1 bg-gray-50 border border-b-0 border-gray-300 px-2 py-1.5 flex-wrap rounded-t-lg">
                        <button type="button" onclick="insertMd('h1')" class="px-2 py-1 text-xs font-bold text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="一级标题">H1</button>
                        <button type="button" onclick="insertMd('h2')" class="px-2 py-1 text-xs font-bold text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="二级标题">H2</button>
                        <button type="button" onclick="insertMd('h3')" class="px-2 py-1 text-xs font-bold text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="三级标题">H3</button>
                        <span class="w-px h-5 bg-gray-300 mx-0.5"></span>
                        <button type="button" onclick="insertMd('bold')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="加粗"><i class="fa fa-bold"></i></button>
                        <button type="button" onclick="insertMd('italic')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="斜体"><i class="fa fa-italic"></i></button>
                        <button type="button" onclick="insertMd('quote')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="引用"><i class="fa fa-quote-right"></i></button>
                        <span class="w-px h-5 bg-gray-300 mx-0.5"></span>
                        <button type="button" onclick="insertMd('link')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="链接"><i class="fa fa-link"></i></button>
                        <button type="button" onclick="insertMd('image')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="图片"><i class="fa fa-image"></i></button>
                        <button type="button" id="crtUploadBtn" class="px-2 py-1 text-sm text-blue-600 hover:bg-blue-50 rounded cursor-pointer flex items-center gap-1" title="上传插图"><i class="fa fa-upload"></i> 插图</button>
                        <input type="file" id="crtFileInput" accept="image/*" class="hidden">
                        <span id="crtUploadStatus" class="text-xs text-green-500 ml-1 hidden">上传成功！</span>
                        <span class="w-px h-5 bg-gray-300 mx-0.5"></span>
                        <button type="button" onclick="insertMd('code')" class="px-2 py-1 text-xs font-mono text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="行内代码">&lt;code&gt;</button>
                        <button type="button" onclick="insertMd('codeblock')" class="px-2 py-1 text-xs font-mono text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="代码块">&lt;/> 代码块</button>
                        <span class="w-px h-5 bg-gray-300 mx-0.5"></span>
                        <button type="button" onclick="insertMd('ul')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="无序列表"><i class="fa fa-list-ul"></i></button>
                        <button type="button" onclick="insertMd('ol')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="有序列表"><i class="fa fa-list-ol"></i></button>
                        <button type="button" onclick="insertMd('table')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="表格"><i class="fa fa-table"></i></button>
                        <button type="button" onclick="insertMd('hr')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="分割线"><i class="fa fa-minus"></i></button>
                    </div>

                    <textarea name="content" id="contentTextarea" rows="16"
                              class="w-full px-3 py-2 border border-gray-300 text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 resize-y font-mono"
                              placeholder="分享你的想法...

支持 Markdown 语法，工具栏助你快速排版。"
                              oninput="updateContentCount(); updatePreview();" required></textarea>
                    <div class="flex items-center justify-between mt-1">
                        <span id="contentCount" class="text-xs text-gray-400">0 字</span>
                    </div>
                </div>

                <!-- 封面图 -->
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">封面图片</label>
                    <div class="flex items-center gap-3 mb-2">
                        <input type="file" name="coverImage" accept="image/*" class="text-sm text-gray-500 file:mr-3 file:py-1.5 file:px-4 file:rounded file:border-0 file:text-sm file:bg-blue-50 file:text-blue-600 hover:file:bg-blue-100 cursor-pointer">
                        <span class="text-xs text-gray-400">或</span>
                    </div>
                    <input type="text" name="imageUrl" id="preImageUrl" value="${param.imageUrl}" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200" placeholder="或填入图片URL，如 https://..." maxlength="500" oninput="updatePreview()">
                    <p class="text-xs text-gray-400 mt-1">支持 jpg/png/gif/webp，最大5MB。上传优先于URL</p>
                </div>

                <!-- 按钮 -->
                <div class="flex items-center gap-3">
                    <button type="submit" id="submitBtn" class="inline-flex items-center gap-1.5 px-6 py-2.5 bg-blue-500 text-white text-sm font-medium rounded-md hover:bg-blue-600 transition cursor-pointer border-none">
                        <i class="fa fa-check"></i> 发布
                    </button>
                    <span class="text-xs text-gray-400">按 Ctrl+Enter 快速发布</span>
                    <a href="${pageContext.request.contextPath}/" class="inline-flex items-center gap-1 px-5 py-2.5 bg-gray-200 text-gray-600 text-sm rounded-md hover:bg-gray-300 no-underline transition ml-auto">取消</a>
                </div>
            </form>
        </div>
    </div>

    <!-- ====== 可拖拽分隔线 ====== -->
    <div id="resizeDivider" class="w-2 shrink-0 hidden lg:flex items-center justify-center cursor-col-resize select-none hover:bg-blue-50 transition-colors rounded" style="cursor:col-resize;">
        <div class="w-0.5 h-10 bg-gray-300 rounded-full"></div>
    </div>

    <!-- ====== 右侧：完整帖子预览 ====== -->
    <div id="rightPanel" class="shrink-0 hidden lg:block overflow-hidden" style="width:420px;">
        <div class="sticky top-[72px]">
            <div class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
                <!-- 预览封面 -->
                <div id="preCoverWrap" class="w-full bg-gray-100 hidden">
                    <img id="preCover" src="" alt="封面" class="w-full max-h-40 object-cover">
                </div>
                <div class="p-5">
                    <!-- 预览标签 -->
                    <div id="preBadgeArea" class="mb-2 hidden">
                        <span id="preBadgeElite" class="hidden inline-block px-2 py-0.5 text-xs font-medium text-pink-600 bg-pink-50 border border-pink-200 rounded mr-1">精华</span>
                        <span id="preBadgeTop" class="hidden inline-block px-2 py-0.5 text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded">置顶</span>
                    </div>
                    <!-- 预览标题 -->
                    <h1 id="preTitle" class="text-lg font-bold text-gray-900 mb-2 leading-snug">帖子标题将显示在此处</h1>
                    <!-- 预览关键词 -->
                    <div id="preKeywordsArea" class="flex items-center gap-1.5 flex-wrap mb-3 hidden"></div>
                    <!-- 预览作者行 -->
                    <div class="flex items-center gap-3 text-xs text-gray-400 pb-3 border-b border-gray-100 mb-3">
                        <span class="flex items-center gap-1.5">
                            <span class="w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-[10px] font-bold">${fn:substring(sessionScope.user.username, 0, 1)}</span>
                            <span class="text-gray-700 font-medium">${sessionScope.user.username}</span>
                        </span>
                        <span id="preCategoryName" class="text-gray-400">未选择板块</span>
                        <span><i class="fa fa-clock-o mr-0.5"></i> 刚刚</span>
                    </div>
                    <!-- 预览内容 -->
                    <div id="previewArea" class="text-sm text-gray-800 leading-relaxed min-h-[120px]">
                        <p class="text-gray-400">填写内容后将在此处实时预览...</p>
                    </div>
                    <!-- 预览交互按钮 -->
                    <div class="flex items-center gap-2 mt-4 pt-3 border-t border-gray-100">
                        <span class="inline-flex items-center gap-1 px-2.5 py-1 text-xs text-gray-400 bg-gray-100 rounded"><i class="fa fa-heart-o"></i> <span id="preLikeCount">0</span></span>
                        <span class="inline-flex items-center gap-1 px-2.5 py-1 text-xs text-gray-400 bg-gray-100 rounded"><i class="fa fa-bookmark-o"></i> <span id="preFavCount">0</span></span>
                        <span class="ml-auto text-xs text-gray-300"><i class="fa fa-eye"></i> <span id="preViewCount">0</span></span>
                    </div>
                </div>
            </div>
            <p class="text-xs text-gray-400 text-center mt-2"><i class="fa fa-eye"></i> 实时预览·编辑即更新</p>
        </div>
    </div>
</div>

<script>
// ========== DOM 引用 ==========
var titleInput = document.getElementById('postTitle');
var titleCount = document.getElementById('titleCount');
var contentTa = document.getElementById('contentTextarea');
var contentCount = document.getElementById('contentCount');
var previewArea = document.getElementById('previewArea');
var preTitle = document.getElementById('preTitle');
var preCategoryName = document.getElementById('preCategoryName');
var preKeywords = document.getElementById('preKeywords');
var preKeywordsArea = document.getElementById('preKeywordsArea');
var preCover = document.getElementById('preCover');
var preCoverWrap = document.getElementById('preCoverWrap');
var preImageUrl = document.getElementById('preImageUrl');
var preBadgeArea = document.getElementById('preBadgeArea');
var preBadgeElite = document.getElementById('preBadgeElite');
var preBadgeTop = document.getElementById('preBadgeTop');

// ========== 实时字数统计 ==========
titleInput.addEventListener('input', function() {
    titleCount.textContent = this.value.length + '/100';
    updatePreview();
});

document.getElementById('preKeywords').addEventListener('input', updatePreview);
document.getElementById('preCategory').addEventListener('change', updatePreview);

function updateContentCount() {
    var len = contentTa.value.length;
    var lines = contentTa.value === '' ? 0 : contentTa.value.split('\n').length;
    contentCount.textContent = len + ' 字' + (lines > 1 ? ' · ' + lines + ' 行' : '');
}

// ========== 完整预览更新 ==========
function updatePreview() {
    // 标题
    var title = titleInput.value.trim();
    preTitle.textContent = title || '帖子标题将显示在此处';

    // 板块
    var catSelect = document.getElementById('preCategory');
    var catName = catSelect.options[catSelect.selectedIndex]?.text || '未选择板块';
    preCategoryName.textContent = catName;

    // 关键词
    var kw = document.getElementById('preKeywords').value.trim();
    preKeywordsArea.innerHTML = '';
    if (kw) {
        preKeywordsArea.classList.remove('hidden');
        kw.split(/[,，]/).forEach(function(k) {
            k = k.trim();
            if (k) {
                var span = document.createElement('span');
                span.className = 'inline-block px-2 py-0.5 text-xs bg-gray-100 text-gray-500 border border-gray-200 rounded-full';
                span.textContent = k;
                preKeywordsArea.appendChild(span);
            }
        });
    } else {
        preKeywordsArea.classList.add('hidden');
    }

    // 封面图
    var imageUrl = preImageUrl.value.trim();
    if (imageUrl) {
        preCoverWrap.classList.remove('hidden');
        preCover.src = imageUrl;
    } else {
        preCoverWrap.classList.add('hidden');
        preCover.src = '';
    }

    // 内容
    previewArea.innerHTML = renderMarkdown(contentTa.value);
}

// ========== 增强工具栏 ==========
function insertMd(type) {
    var ta = contentTa;
    var start = ta.selectionStart;
    var end = ta.selectionEnd;
    var text = ta.value;
    var selected = text.substring(start, end);
    var before, after;

    switch (type) {
        case 'h1': before = '# '; after = ''; break;
        case 'h2': before = '## '; after = ''; break;
        case 'h3': before = '### '; after = ''; break;
        case 'bold': before = '**'; after = '**'; break;
        case 'italic': before = '*'; after = '*'; break;
        case 'quote': before = '> '; after = ''; break;
        case 'link':
            if (selected) { before = '['; after = '](url)'; }
            else { before = '[链接文字](url)'; after = ''; }
            break;
        case 'image':
            if (selected) { before = '!['; after = '](url)'; }
            else { before = '![图片描述](url)'; after = ''; }
            break;
        case 'code': before = '`'; after = '`'; break;
        case 'codeblock': before = '\n```\n'; after = '\n```\n'; break;
        case 'ul':
            if (selected) { before = '- '; after = ''; }
            else { before = '- 列表项'; after = ''; }
            break;
        case 'ol':
            if (selected) { before = '1. '; after = ''; }
            else { before = '1. 列表项'; after = ''; }
            break;
        case 'table': before = '\n| 列1 | 列2 | 列3 |\n| --- | --- | --- |\n| 内容 | 内容 | 内容 |\n'; after = ''; break;
        case 'hr': before = '\n---\n'; after = ''; break;
        default: before = ''; after = '';
    }

    if (before === '' && after === '') return;
    var insert = before + selected + after;
    if (!selected && after === '') insert = before;

    ta.value = text.substring(0, start) + insert + text.substring(end);
    ta.focus();
    var cursorPos = start + insert.length;
    ta.selectionStart = cursorPos;
    ta.selectionEnd = cursorPos;
    updateContentCount();
    updatePreview();
}

// ========== 图片上传 ==========
document.getElementById('crtUploadBtn').onclick = function() {
    document.getElementById('crtFileInput').click();
};

document.getElementById('crtFileInput').onchange = function() {
    var file = this.files[0];
    if (!file) return;

    var formData = new FormData();
    formData.append('coverImage', file);

    var statusEl = document.getElementById('crtUploadStatus');
    statusEl.classList.remove('hidden');
    statusEl.textContent = '上传中...';
    statusEl.className = 'text-xs text-yellow-500 ml-1';

    fetch('${pageContext.request.contextPath}/post/uploadImage', {
        method: 'POST',
        body: formData
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.markdown) {
            var ta = contentTa;
            var start = ta.selectionStart;
            var text = ta.value;
            ta.value = text.substring(0, start) + data.markdown + '\n' + text.substring(ta.selectionEnd);
            ta.focus();
            ta.selectionStart = ta.selectionEnd = start + data.markdown.length + 1;
            statusEl.textContent = '上传成功！';
            statusEl.className = 'text-xs text-green-500 ml-1';
            updateContentCount();
            updatePreview();
        } else {
            statusEl.textContent = data.error || '上传失败';
            statusEl.className = 'text-xs text-red-500 ml-1';
        }
    })
    .catch(function() {
        statusEl.textContent = '上传失败';
        statusEl.className = 'text-xs text-red-500 ml-1';
    });
    this.value = '';
};

// ========== 实时预览渲染 ==========
function renderMarkdown(text) {
    if (!text) return '<p class="text-gray-400">暂无内容</p>';

    var html = text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');

    // 代码块
    html = html.replace(/```([\s\S]*?)```/g, function(match, code) {
        return '<pre class="bg-gray-900 text-gray-100 rounded-lg p-4 my-3 text-sm overflow-x-auto"><code>' + code.trim() + '</code></pre>';
    });
    // 行内代码
    html = html.replace(/`([^`]+)`/g, '<code class="bg-gray-100 text-red-500 px-1.5 py-0.5 rounded text-xs font-mono">$1</code>');
    // 标题
    html = html.replace(/^### (.+)$/gm, '<h3 class="text-lg font-bold mt-4 mb-2 text-gray-900">$1</h3>');
    html = html.replace(/^## (.+)$/gm, '<h2 class="text-xl font-bold mt-5 mb-2 text-gray-900">$1</h2>');
    html = html.replace(/^# (.+)$/gm, '<h1 class="text-2xl font-bold mt-5 mb-3 text-gray-900">$1</h1>');
    // 图片
    html = html.replace(/!\[([^\]]*)\]\(([^)]+)\)/g,
        '<img src="$2" alt="$1" class="max-w-full rounded-lg my-3" loading="lazy" onerror="this.style.display=\'none\'">');
    // 链接
    html = html.replace(/(?<!!)\[([^\]]*)\]\(([^)]+)\)/g,
        '<a href="$2" target="_blank" class="text-blue-500 hover:text-blue-600 underline">$1</a>');
    // 加粗和斜体
    html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    html = html.replace(/(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)/g, '<em>$1</em>');
    // 引用
    html = html.replace(/^> (.+)$/gm, '<blockquote class="border-l-4 border-gray-300 pl-4 py-1 my-2 text-gray-600 italic">$1</blockquote>');
    // 无序列表
    html = html.replace(/^- (.+)$/gm, '<li class="text-gray-700 ml-4 list-disc">$1</li>');
    // 有序列表
    html = html.replace(/^\d+\. (.+)$/gm, '<li class="text-gray-700 ml-4 list-decimal">$1</li>');
    // 分割线
    html = html.replace(/^---$/gm, '<hr class="my-4 border-gray-200">');
    // 表格
    html = html.replace(/\|(.+)\|\n\|[\s\-|]+\|\n((?:\|.+\|\n)*)/g, function(match, header, body) {
        var cells = header.split('|').filter(function(c) { return c.trim(); });
        var headerHtml = cells.map(function(c) { return '<th class="border border-gray-300 px-3 py-2 bg-gray-50 text-left text-xs font-semibold text-gray-600">' + c.trim() + '</th>'; }).join('');
        var bodyRows = body.trim().split('\n').map(function(row) {
            var rowCells = row.split('|').filter(function(c) { return c.trim(); });
            return '<tr>' + rowCells.map(function(c) { return '<td class="border border-gray-300 px-3 py-2 text-sm">' + c.trim() + '</td>'; }).join('') + '</tr>';
        }).join('');
        return '<table class="w-full border-collapse my-3"><thead><tr>' + headerHtml + '</tr></thead><tbody>' + bodyRows + '</tbody></table>';
    });
    // 段落
    html = html.replace(/(\r?\n){2,}/g, '</p><p class="mb-3">');
    html = html.replace(/(\r?\n)/g, '<br>');
    html = '<p class="mb-3">' + html + '</p>';
    return html;
}

// ========== 防止重复提交 + Ctrl+Enter ==========
var postForm = document.getElementById('postForm');
var submitBtn = document.getElementById('submitBtn');

postForm.addEventListener('submit', function() {
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fa fa-spinner fa-pulse"></i> 发布中...';
    submitBtn.className = 'inline-flex items-center gap-1.5 px-6 py-2.5 bg-blue-400 text-white text-sm font-medium rounded-md cursor-not-allowed border-none';
});

contentTa.addEventListener('keydown', function(e) {
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        e.preventDefault();
        if (postForm.checkValidity()) { postForm.requestSubmit(); }
        else { postForm.reportValidity(); }
    }
});

// 拖拽上传图片
contentTa.addEventListener('dragover', function(e) {
    e.preventDefault();
    this.style.borderColor = '#3b82f6';
    this.style.backgroundColor = '#f0f7ff';
});

contentTa.addEventListener('dragleave', function() {
    this.style.borderColor = '';
    this.style.backgroundColor = '';
});

contentTa.addEventListener('drop', function(e) {
    e.preventDefault();
    this.style.borderColor = '';
    this.style.backgroundColor = '';
    var file = e.dataTransfer.files[0];
    if (file && file.type.startsWith('image/')) {
        var formData = new FormData();
        formData.append('coverImage', file);
        var start = this.selectionStart;
        this.value = this.value.substring(0, start) + '![上传中...]()' + this.value.substring(this.selectionEnd);
        this.selectionStart = this.selectionEnd = start + '![上传中...]()'.length;
        fetch('${pageContext.request.contextPath}/post/uploadImage', { method: 'POST', body: formData })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.markdown) {
                var ta = contentTa;
                var idx = ta.value.indexOf('![上传中...]()');
                if (idx !== -1) {
                    ta.value = ta.value.substring(0, idx) + data.markdown + ta.value.substring(idx + '![上传中...]()'.length);
                }
                updateContentCount();
                updatePreview();
            }
        }).catch(function() {});
    }
});

// 初始化
updateContentCount();
updatePreview();
if (titleInput.value) titleCount.textContent = titleInput.value.length + '/100';

// ========== 可拖拽调整左右宽度 ==========
(function() {
    var divider = document.getElementById('resizeDivider');
    var rightPanel = document.getElementById('rightPanel');
    if (!divider || !rightPanel) return;
    var isDragging = false;

    divider.addEventListener('mousedown', function(e) {
        isDragging = true;
        document.body.style.cursor = 'col-resize';
        document.body.style.userSelect = 'none';
        e.preventDefault();
    });

    document.addEventListener('mousemove', function(e) {
        if (!isDragging) return;
        var containerRect = divider.parentElement.getBoundingClientRect();
        var containerRight = containerRect.right;
        var rightWidth = containerRight - e.clientX;
        // 限制最小 300px，最大 600px
        rightWidth = Math.max(300, Math.min(600, rightWidth));
        rightPanel.style.width = rightWidth + 'px';
    });

    document.addEventListener('mouseup', function() {
        if (isDragging) {
            isDragging = false;
            document.body.style.cursor = '';
            document.body.style.userSelect = '';
        }
    });
})();
</script>
