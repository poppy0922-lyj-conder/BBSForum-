<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 面包屑 -->
<div class="flex items-center gap-2 text-sm text-gray-400 mb-4">
    <a href="${pageContext.request.contextPath}/" class="text-gray-500 hover:text-blue-500 no-underline">首页</a>
    <span>/</span>
    <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}" class="text-gray-500 hover:text-blue-500 no-underline">帖子详情</a>
    <span>/</span>
    <span class="text-gray-700">编辑</span>
</div>

<!-- 表单 -->
<div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
    <h2 class="text-xl font-bold text-gray-900 mb-6">
        <i class="fa fa-edit mr-1"></i> 编辑帖子
    </h2>

    <c:if test="${not empty error}">
        <div class="flex items-center gap-2 bg-red-50 text-red-600 border border-red-200 rounded px-4 py-2.5 text-sm mb-5">
            <i class="fa fa-exclamation-circle"></i> ${error}
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/post/edit" method="post" enctype="multipart/form-data" id="editForm">
        <input type="hidden" name="id" value="${post.id}">

        <!-- 板块选择 -->
        <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">选择板块 *</label>
            <select name="categoryId" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 bg-white" required>
                <c:forEach var="cat" items="${applicationScope.categoryList}">
                    <option value="${cat.id}" ${cat.id == post.categoryId ? 'selected' : ''}>${cat.name}</option>
                </c:forEach>
            </select>
        </div>

        <!-- 标题 -->
        <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">标题 *</label>
            <div class="relative">
                <input type="text" name="title" id="editTitle" value="${post.title}"
                       class="w-full px-3 py-2 pr-16 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200"
                       maxlength="100" required>
                <span id="editTitleCount" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-xs text-gray-400">${post.title.length()}/100</span>
            </div>
        </div>

        <!-- 关键词 -->
        <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">关键词（可选，逗号分隔）</label>
            <input type="text" name="keywords" value="${post.keywords}" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200" placeholder="如：Java, Spring Boot, 教程" maxlength="200">
        </div>

        <!-- 内容 -->
        <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">内容 *</label>

            <!-- 编辑/预览 Tab 切换 -->
            <div class="flex items-center border-b border-gray-300">
                <button type="button" id="editTabEdit" class="px-4 py-2 text-sm font-medium text-blue-600 border-b-2 border-blue-500 cursor-pointer bg-transparent" onclick="editSwitchTab('edit')">
                    <i class="fa fa-pencil"></i> 编辑
                </button>
                <button type="button" id="editTabPreview" class="px-4 py-2 text-sm font-medium text-gray-500 border-b-2 border-transparent cursor-pointer bg-transparent hover:text-gray-700" onclick="editSwitchTab('preview')">
                    <i class="fa fa-eye"></i> 预览
                </button>
                <span id="editContentCount" class="ml-auto text-xs text-gray-400 pr-1"></span>
            </div>

            <!-- 编辑工具栏 -->
            <div id="editEditorToolbar" class="flex items-center gap-1 bg-gray-50 border border-b-0 border-gray-300 px-2 py-1.5 flex-wrap">
                <!-- 标题 -->
                <button type="button" onclick="editInsertMd('h1')" class="px-2 py-1 text-xs font-bold text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="一级标题">H1</button>
                <button type="button" onclick="editInsertMd('h2')" class="px-2 py-1 text-xs font-bold text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="二级标题">H2</button>
                <button type="button" onclick="editInsertMd('h3')" class="px-2 py-1 text-xs font-bold text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="三级标题">H3</button>
                <span class="w-px h-5 bg-gray-300 mx-0.5"></span>

                <!-- 文字样式 -->
                <button type="button" onclick="editInsertMd('bold')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="加粗"><i class="fa fa-bold"></i></button>
                <button type="button" onclick="editInsertMd('italic')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="斜体"><i class="fa fa-italic"></i></button>
                <button type="button" onclick="editInsertMd('quote')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="引用"><i class="fa fa-quote-right"></i></button>
                <span class="w-px h-5 bg-gray-300 mx-0.5"></span>

                <!-- 链接和媒体 -->
                <button type="button" onclick="editInsertMd('link')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="链接"><i class="fa fa-link"></i></button>
                <button type="button" onclick="editInsertMd('image')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="图片"><i class="fa fa-image"></i></button>
                <button type="button" id="editUploadBtn" class="px-2 py-1 text-sm text-blue-600 hover:bg-blue-50 rounded cursor-pointer flex items-center gap-1" title="上传插图">
                    <i class="fa fa-upload"></i> 插图
                </button>
                <input type="file" id="editFileInput" accept="image/*" class="hidden">
                <span id="editUploadStatus" class="text-xs text-green-500 ml-1 hidden">上传成功！</span>
                <span class="w-px h-5 bg-gray-300 mx-0.5"></span>

                <!-- 代码 -->
                <button type="button" onclick="editInsertMd('code')" class="px-2 py-1 text-xs font-mono text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="行内代码">&lt;code&gt;</button>
                <button type="button" onclick="editInsertMd('codeblock')" class="px-2 py-1 text-xs font-mono text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="代码块">&lt;/> 代码块</button>
                <span class="w-px h-5 bg-gray-300 mx-0.5"></span>

                <!-- 列表和结构 -->
                <button type="button" onclick="editInsertMd('ul')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="无序列表"><i class="fa fa-list-ul"></i></button>
                <button type="button" onclick="editInsertMd('ol')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="有序列表"><i class="fa fa-list-ol"></i></button>
                <button type="button" onclick="editInsertMd('table')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="表格"><i class="fa fa-table"></i></button>
                <button type="button" onclick="editInsertMd('hr')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="分割线"><i class="fa fa-minus"></i></button>
            </div>

            <!-- 编辑区 -->
            <textarea name="content" id="editContentTextarea" rows="14"
                      class="w-full px-3 py-2 border border-gray-300 text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 resize-y"
                      oninput="editUpdateContentCount()" required>${post.content}</textarea>

            <!-- 预览区（默认隐藏） -->
            <div id="editPreviewArea" class="w-full px-4 py-3 border border-gray-300 text-sm min-h-[200px] bg-white hidden prose prose-sm max-w-none"></div>
        </div>

        <!-- 封面图 -->
        <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">封面图片</label>
            <c:choose>
                <c:when test="${not empty post.imageUrl}">
                    <img src="${post.imageUrl}" class="w-40 h-24 object-cover rounded mb-2 border" onerror="this.style.display='none'" alt="当前封面">
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/cover/${post.id}?title=${fn:substring(post.title, 0, 1)}" class="w-40 h-24 object-cover rounded mb-2 border" alt="当前封面">
                </c:otherwise>
            </c:choose>
            <div class="flex items-center gap-3 mb-2">
                <input type="file" name="coverImage" accept="image/*" class="text-sm text-gray-500 file:mr-3 file:py-1.5 file:px-4 file:rounded file:border-0 file:text-sm file:bg-blue-50 file:text-blue-600 hover:file:bg-blue-100 cursor-pointer">
                <span class="text-xs text-gray-400">或</span>
            </div>
            <input type="text" name="imageUrl" value="${post.imageUrl}" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200" placeholder="或填入图片URL，如 https://..." maxlength="500">
            <p class="text-xs text-gray-400 mt-1">上传新图片会替换当前封面，仅修改URL则上传留空</p>
        </div>

        <!-- 按钮 -->
        <div class="flex items-center gap-3">
            <button type="submit" id="editSubmitBtn" class="inline-flex items-center gap-1.5 px-6 py-2.5 bg-blue-500 text-white text-sm font-medium rounded-md hover:bg-blue-600 transition cursor-pointer border-none">
                <i class="fa fa-save"></i> 保存修改
            </button>
            <span class="text-xs text-gray-400">按 Ctrl+Enter 快速保存</span>
            <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}" class="inline-flex items-center gap-1 px-5 py-2.5 bg-gray-200 text-gray-600 text-sm rounded-md hover:bg-gray-300 no-underline transition ml-auto">
                取消
            </a>
        </div>
    </form>
</div>

<script>
// ========== 实时字数统计 ==========
var editTitle = document.getElementById('editTitle');
var editTitleCount = document.getElementById('editTitleCount');
var editContentTa = document.getElementById('editContentTextarea');
var editContentCount = document.getElementById('editContentCount');

editTitle.addEventListener('input', function() {
    editTitleCount.textContent = this.value.length + '/100';
});

function editUpdateContentCount() {
    var len = editContentTa.value.length;
    var lines = editContentTa.value === '' ? 0 : editContentTa.value.split('\n').length;
    editContentCount.textContent = len + ' 字' + (lines > 1 ? ' · ' + lines + ' 行' : '');
}

// ========== 增强工具栏 ==========
function editInsertMd(type) {
    var ta = editContentTa;
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

    var insert = before + selected + after;
    if (!selected && after === '') insert = before;

    ta.value = text.substring(0, start) + insert + text.substring(end);
    ta.focus();
    var cursorPos = start + insert.length;
    ta.selectionStart = cursorPos;
    ta.selectionEnd = cursorPos;
    editUpdateContentCount();
}

// ========== 图片上传 ==========
document.getElementById('editUploadBtn').onclick = function() {
    document.getElementById('editFileInput').click();
};

document.getElementById('editFileInput').onchange = function() {
    var file = this.files[0];
    if (!file) return;

    var formData = new FormData();
    formData.append('coverImage', file);

    var statusEl = document.getElementById('editUploadStatus');
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
            var ta = editContentTa;
            var start = ta.selectionStart;
            ta.value = ta.value.substring(0, start) + data.markdown + '\n' + ta.value.substring(ta.selectionEnd);
            ta.focus();
            ta.selectionStart = ta.selectionEnd = start + data.markdown.length + 1;
            statusEl.textContent = '上传成功！';
            statusEl.className = 'text-xs text-green-500 ml-1';
            editUpdateContentCount();
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

// ========== 实时预览 ==========
function editRenderMarkdown(text) {
    if (!text) return '<p class="text-gray-400">暂无内容</p>';

    var html = text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');

    html = html.replace(/```([\s\S]*?)```/g, function(m, code) {
        return '<pre class="bg-gray-900 text-gray-100 rounded-lg p-4 my-3 text-sm overflow-x-auto"><code>' + code.trim() + '</code></pre>';
    });
    html = html.replace(/`([^`]+)`/g, '<code class="bg-gray-100 text-red-500 px-1.5 py-0.5 rounded text-xs font-mono">$1</code>');
    html = html.replace(/^### (.+)$/gm, '<h3 class="text-lg font-bold mt-5 mb-2 text-gray-900">$1</h3>');
    html = html.replace(/^## (.+)$/gm, '<h2 class="text-xl font-bold mt-5 mb-2 text-gray-900">$1</h2>');
    html = html.replace(/^# (.+)$/gm, '<h1 class="text-2xl font-bold mt-6 mb-3 text-gray-900">$1</h1>');
    html = html.replace(/!\[([^\]]*)\]\(([^)]+)\)/g,
        '<img src="$2" alt="$1" class="max-w-full rounded-lg my-3" loading="lazy" onerror="this.style.display=\'none\'">');
    html = html.replace(/(?<!!)\[([^\]]*)\]\(([^)]+)\)/g,
        '<a href="$2" target="_blank" class="text-blue-500 hover:text-blue-600 underline">$1</a>');
    html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    html = html.replace(/(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)/g, '<em>$1</em>');
    html = html.replace(/^> (.+)$/gm, '<blockquote class="border-l-4 border-gray-300 pl-4 py-1 my-2 text-gray-600 italic">$1</blockquote>');
    html = html.replace(/^- (.+)$/gm, '<li class="text-gray-700 ml-4 list-disc">$1</li>');
    html = html.replace(/^\d+\. (.+)$/gm, '<li class="text-gray-700 ml-4 list-decimal">$1</li>');
    html = html.replace(/^---$/gm, '<hr class="my-4 border-gray-200">');
    html = html.replace(/\|(.+)\|\n\|[\s\-|]+\|\n((?:\|.+\|\n)*)/g, function(m, header, body) {
        var cells = header.split('|').filter(function(c) { return c.trim(); });
        var h = cells.map(function(c) { return '<th class="border border-gray-300 px-3 py-2 bg-gray-50 text-left text-xs font-semibold text-gray-600">' + c.trim() + '</th>'; }).join('');
        var b = body.trim().split('\n').map(function(row) {
            return '<tr>' + row.split('|').filter(function(c) { return c.trim(); }).map(function(c) { return '<td class="border border-gray-300 px-3 py-2 text-sm">' + c.trim() + '</td>'; }).join('') + '</tr>';
        }).join('');
        return '<table class="w-full border-collapse my-3"><thead><tr>' + h + '</tr></thead><tbody>' + b + '</tbody></table>';
    });
    html = html.replace(/(\r?\n){2,}/g, '</p><p class="mb-3">');
    html = html.replace(/(\r?\n)/g, '<br>');
    return '<p class="mb-3">' + html + '</p>';
}

function editSwitchTab(tab) {
    var tabEdit = document.getElementById('editTabEdit');
    var tabPreview = document.getElementById('editTabPreview');
    var toolbar = document.getElementById('editEditorToolbar');
    var textarea = editContentTa;
    var preview = document.getElementById('editPreviewArea');

    if (tab === 'edit') {
        tabEdit.className = 'px-4 py-2 text-sm font-medium text-blue-600 border-b-2 border-blue-500 cursor-pointer bg-transparent';
        tabPreview.className = 'px-4 py-2 text-sm font-medium text-gray-500 border-b-2 border-transparent cursor-pointer bg-transparent hover:text-gray-700';
        toolbar.style.display = 'flex';
        textarea.style.display = 'block';
        preview.style.display = 'none';
    } else {
        tabPreview.className = 'px-4 py-2 text-sm font-medium text-blue-600 border-b-2 border-blue-500 cursor-pointer bg-transparent';
        tabEdit.className = 'px-4 py-2 text-sm font-medium text-gray-500 border-b-2 border-transparent cursor-pointer bg-transparent hover:text-gray-700';
        toolbar.style.display = 'none';
        textarea.style.display = 'none';
        preview.style.display = 'block';
        preview.innerHTML = editRenderMarkdown(editContentTa.value);
    }
}

// ========== 防止重复提交 + Ctrl+Enter ==========
var editForm = document.getElementById('editForm');
var editSubmitBtn = document.getElementById('editSubmitBtn');

editForm.addEventListener('submit', function(e) {
    editSubmitBtn.disabled = true;
    editSubmitBtn.innerHTML = '<i class="fa fa-spinner fa-pulse"></i> 保存中...';
    editSubmitBtn.className = 'inline-flex items-center gap-1.5 px-6 py-2.5 bg-blue-400 text-white text-sm font-medium rounded-md cursor-not-allowed border-none';
});

editContentTa.addEventListener('keydown', function(e) {
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        e.preventDefault();
        if (editForm.checkValidity()) {
            editForm.requestSubmit();
        } else {
            editForm.reportValidity();
        }
    }
});

// 拖拽上传图片
editContentTa.addEventListener('dragover', function(e) {
    e.preventDefault();
    this.style.borderColor = '#3b82f6';
    this.style.backgroundColor = '#f0f7ff';
});

editContentTa.addEventListener('dragleave', function() {
    this.style.borderColor = '';
    this.style.backgroundColor = '';
});

editContentTa.addEventListener('drop', function(e) {
    e.preventDefault();
    this.style.borderColor = '';
    this.style.backgroundColor = '';

    var file = e.dataTransfer.files[0];
    if (file && file.type.startsWith('image/')) {
        var formData = new FormData();
        formData.append('coverImage', file);

        var start = this.selectionStart;
        this.value = this.value.substring(0, start) + '![上传中...]()' + this.value.substring(this.selectionEnd);

        fetch('${pageContext.request.contextPath}/post/uploadImage', {
            method: 'POST',
            body: formData
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.markdown) {
                var ta = editContentTa;
                var idx = ta.value.indexOf('![上传中...]()');
                if (idx !== -1) {
                    ta.value = ta.value.substring(0, idx) + data.markdown + ta.value.substring(idx + '![上传中...]()'.length);
                }
                editUpdateContentCount();
            }
        })
        .catch(function() {});
    }
});

// 初始化字数
editUpdateContentCount();
if (editTitle.value) editTitleCount.textContent = editTitle.value.length + '/100';
</script>
