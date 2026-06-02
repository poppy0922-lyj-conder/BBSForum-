<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
            <input type="text" name="title" value="${post.title}" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200" maxlength="100" required>
        </div>

        <!-- 关键词 -->
        <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">关键词（可选，逗号分隔）</label>
            <input type="text" name="keywords" value="${post.keywords}" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200" placeholder="如：Java, Spring Boot, 教程" maxlength="200">
        </div>

        <!-- 内容 -->
        <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">内容 *</label>
            <div class="flex items-center gap-1 mb-2 bg-gray-50 rounded-t-lg border border-b-0 border-gray-300 px-2 py-1.5">
                <button type="button" onclick="edit_insertMarkdown('**', '**')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="加粗"><i class="fa fa-bold"></i></button>
                <button type="button" onclick="edit_insertMarkdown('[', '](url)')" class="px-2 py-1 text-sm text-gray-600 hover:bg-gray-200 rounded cursor-pointer" title="链接"><i class="fa fa-link"></i></button>
                <span class="w-px h-5 bg-gray-300 mx-1"></span>
                <button type="button" id="editInlineUploadBtn" class="px-2 py-1 text-sm text-blue-600 hover:bg-blue-50 rounded cursor-pointer flex items-center gap-1" title="上传插图">
                    <i class="fa fa-image"></i> 插图
                </button>
                <input type="file" id="editInlineFileInput" accept="image/*" class="hidden" onchange="edit_uploadInlineImage()">
                <span class="text-xs text-gray-400 ml-2">或输入 ![描述](图片URL)</span>
                <span id="editUploadStatus" class="text-xs text-green-500 ml-2 hidden">上传成功！</span>
            </div>
            <textarea name="content" id="editContentTextarea" rows="14" class="w-full px-3 py-2 border border-gray-300 rounded-b-lg rounded-t-none text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 resize-none" placeholder="分享你的想法..." required>${post.content}</textarea>
        </div>

        <!-- 封面图 -->
        <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">封面图片</label>
            <c:if test="${not empty post.imageUrl}">
                <img src="${post.imageUrl}" class="w-40 h-24 object-cover rounded mb-2 border" onerror="this.style.display='none'" alt="当前封面">
            </c:if>
            <div class="flex items-center gap-3 mb-2">
                <input type="file" name="coverImage" accept="image/*" class="text-sm text-gray-500 file:mr-3 file:py-1.5 file:px-4 file:rounded file:border-0 file:text-sm file:bg-blue-50 file:text-blue-600 hover:file:bg-blue-100 cursor-pointer">
                <span class="text-xs text-gray-400">或</span>
            </div>
            <input type="text" name="imageUrl" value="${post.imageUrl}" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200" placeholder="或填入图片URL，如 https://..." maxlength="500">
            <p class="text-xs text-gray-400 mt-1">上传新图片会替换当前封面，仅修改URL则上传留空</p>
        </div>

        <!-- 按钮 -->
        <div class="flex items-center gap-3">
            <button type="submit" class="inline-flex items-center gap-1.5 px-6 py-2.5 bg-blue-500 text-white text-sm font-medium rounded-md hover:bg-blue-600 transition cursor-pointer border-none">
                <i class="fa fa-save"></i> 保存修改
            </button>
            <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}" class="inline-flex items-center gap-1 px-5 py-2.5 bg-gray-200 text-gray-600 text-sm rounded-md hover:bg-gray-300 no-underline transition">
                取消
            </a>
        </div>
    </form>
</div>

<script>
function edit_insertMarkdown(before, after) {
    var ta = document.getElementById('editContentTextarea');
    var start = ta.selectionStart, end = ta.selectionEnd;
    var text = ta.value, selected = text.substring(start, end);
    ta.value = text.substring(0, start) + before + selected + after + text.substring(end);
    ta.focus();
    ta.selectionStart = start + before.length;
    ta.selectionEnd = start + before.length + selected.length;
}
document.getElementById('editInlineUploadBtn').onclick = function() { document.getElementById('editInlineFileInput').click(); };
function edit_uploadInlineImage() {
    var file = document.getElementById('editInlineFileInput').files[0];
    if (!file) return;
    var fd = new FormData(); fd.append('coverImage', file);
    var s = document.getElementById('editUploadStatus');
    s.classList.remove('hidden'); s.textContent = '上传中...'; s.className = 'text-xs text-yellow-500 ml-2';
    fetch('${pageContext.request.contextPath}/post/uploadImage', { method: 'POST', body: fd })
    .then(function(r) { return r.json(); })
    .then(function(d) {
        if (d.markdown) { edit_insertMarkdown(d.markdown + '\n', ''); s.textContent = '上传成功！'; s.className = 'text-xs text-green-500 ml-2'; }
        else { s.textContent = d.error; s.className = 'text-xs text-red-500 ml-2'; }
    })
    .catch(function() { s.textContent = '上传失败'; s.className = 'text-xs text-red-500 ml-2'; });
    document.getElementById('editInlineFileInput').value = '';
}
</script>
