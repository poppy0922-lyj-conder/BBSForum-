<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="flex gap-5">
    <!-- 左侧边栏 -->
    <jsp:include page="/user/profile_sidebar.jsp" />

    <!-- 右侧主内容区 -->
    <main class="flex-1 min-w-0">
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-lg font-bold text-gray-900 mb-5 flex items-center gap-2">
                <i class="fa fa-pencil-square-o text-blue-500"></i> 草稿箱
            </h2>

            <c:choose>
                <c:when test="${empty draftList}">
                    <div class="text-center py-12 text-gray-400">
                        <i class="fa fa-pencil-square-o text-4xl block mb-3 text-gray-300"></i>
                        <p class="text-sm">还没有草稿，去<a href="${pageContext.request.contextPath}/post/create" class="text-blue-500 no-underline">写一篇</a>吧！</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="space-y-3">
                        <c:forEach var="draft" items="${draftList}">
                            <div class="p-4 border border-gray-100 rounded-lg hover:bg-gray-50 transition">
                                <div class="flex items-start gap-3">
                                    <div class="flex-1 min-w-0">
                                        <div class="flex items-center gap-2 mb-1">
                                            <a href="${pageContext.request.contextPath}/post/edit?id=${draft.id}" class="text-sm font-medium text-gray-900 hover:text-blue-500 no-underline line-clamp-1">
                                                ${empty draft.title ? '无标题' : draft.title}
                                            </a>
                                            <span class="text-xs px-1.5 py-0.5 bg-yellow-100 text-yellow-600 rounded">草稿</span>
                                        </div>
                                        <p class="text-xs text-gray-400 mt-1 line-clamp-2">${draft.summary}</p>
                                        <div class="flex items-center gap-3 mt-2 text-xs text-gray-400">
                                            <span><i class="fa fa-folder-o"></i> ${draft.categoryName}</span>
                                            <span><i class="fa fa-clock-o"></i> 最后修改：${fn:substring(draft.updatedAt, 0, 16)}</span>
                                            <c:if test="${not empty draft.keywords}">
                                                <span><i class="fa fa-tags"></i> ${draft.keywords}</span>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="flex items-center gap-2 shrink-0">
                                        <a href="${pageContext.request.contextPath}/post/edit?id=${draft.id}" class="inline-flex items-center gap-1 px-3 py-1.5 text-xs text-blue-600 bg-blue-50 border border-blue-200 rounded hover:bg-blue-100 no-underline transition">
                                            <i class="fa fa-edit"></i> 继续编辑
                                        </a>
                                        <a href="${pageContext.request.contextPath}/post/delete?id=${draft.id}"
                                           onclick="if(!confirm('确定删除此草稿？')) return false;"
                                           class="inline-flex items-center gap-1 px-3 py-1.5 text-xs text-red-600 bg-red-50 border border-red-200 rounded hover:bg-red-100 no-underline transition">
                                            <i class="fa fa-trash"></i> 删除
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>
