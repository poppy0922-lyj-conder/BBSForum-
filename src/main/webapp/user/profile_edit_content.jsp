<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 个人中心专用布局：左右分栏 -->
<div class="flex gap-5">
    <!-- 左侧边栏 -->
    <c:set var="activeMenu" value="edit" scope="request" />
    <jsp:include page="/user/profile_sidebar.jsp" />

    <!-- 右侧主内容区 -->
    <main class="flex-1 min-w-0">
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-lg font-bold text-gray-900 mb-5 flex items-center gap-2">
                <i class="fa fa-edit text-blue-500"></i> 编辑个人资料
            </h2>

            <!-- 错误提示 -->
            <c:if test="${not empty error}">
                <div class="flex items-center gap-2 px-4 py-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700 mb-5">
                    <i class="fa fa-exclamation-circle"></i>
                    <span>${error}</span>
                    <button onclick="this.parentElement.remove()" class="ml-auto text-red-500 hover:text-red-700 cursor-pointer">&times;</button>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/user/profile/edit" method="post" onsubmit="return validateForm()">
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">联系方式</label>
                    <input type="text" name="phone" id="phone" value="${user.phone}"
                           class="w-full px-3 py-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                           placeholder="请输入手机号" maxlength="20">
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">工作性质</label>
                    <input type="text" name="jobType" id="jobType" value="${user.jobType}"
                           class="w-full px-3 py-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                           placeholder="如：学生、程序员、设计师等" maxlength="50">
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">工作地点</label>
                    <input type="text" name="jobLocation" id="jobLocation" value="${user.jobLocation}"
                           class="w-full px-3 py-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                           placeholder="如：北京、上海等" maxlength="100">
                </div>

                <div class="border-t border-gray-100 pt-4 mb-4">
                    <p class="text-xs text-gray-400 mb-3">修改密码（不修改请留空）</p>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">新密码</label>
                        <input type="password" name="password" id="password"
                               class="w-full px-3 py-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                               placeholder="请输入新密码" minlength="6">
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">确认新密码</label>
                        <input type="password" name="password2" id="password2"
                               class="w-full px-3 py-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                               placeholder="再次输入新密码">
                    </div>
                </div>

                <div class="flex gap-3">
                    <button type="submit" class="px-5 py-2.5 bg-blue-500 text-white text-sm rounded hover:bg-blue-600 transition cursor-pointer border-none">
                        <i class="fa fa-save"></i> 保存
                    </button>
                    <a href="${pageContext.request.contextPath}/user/profile"
                       class="px-5 py-2.5 bg-gray-100 text-gray-600 text-sm rounded hover:bg-gray-200 transition no-underline">
                        取消
                    </a>
                </div>
            </form>
        </div>
    </main>
</div>

<script>
function validateForm() {
    var password = document.getElementById('password').value.trim();
    var password2 = document.getElementById('password2').value.trim();

    if (password !== '') {
        if (password.length < 6) {
            alert('新密码长度至少 6 位');
            return false;
        }
        if (password !== password2) {
            alert('两次输入的新密码不一致');
            return false;
        }
    }
    return true;
}
</script>
