<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="max-w-lg mx-auto mt-10">
    <div class="bg-white rounded-lg shadow-sm p-10">
        <h2 class="text-2xl font-bold text-center mb-1">注册</h2>
        <p class="text-center text-gray-400 text-sm mb-7">加入BBS技术社区</p>

        <!-- 错误提示 -->
        <c:if test="${not empty error}">
            <div class="flex items-center gap-2 bg-red-50 text-red-600 border border-red-200 rounded px-4 py-2.5 text-sm mb-5">
                <i class="fa fa-exclamation-circle"></i> ${error}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/user/register" method="post" onsubmit="return validateRegister()">
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 mb-1">用户名 *</label>
                <input type="text" name="username" id="regUsername"
                       class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                       placeholder="用户名" maxlength="50" required minlength="3">
            </div>
            <div class="grid grid-cols-2 gap-3 mb-3">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">密码 *</label>
                    <input type="password" name="password" id="regPassword"
                           class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                           placeholder="密码" required minlength="6">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">确认密码 *</label>
                    <input type="password" name="password2" id="regPassword2"
                           class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                           placeholder="再次输入" required>
                </div>
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 mb-1">联系方式</label>
                <input type="text" name="phone"
                       class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                       placeholder="手机号" maxlength="20">
            </div>
            <div class="grid grid-cols-2 gap-3 mb-5">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">工作性质</label>
                    <input type="text" name="jobType"
                           class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                           placeholder="如：学生、程序员" maxlength="50">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">工作地点</label>
                    <input type="text" name="jobLocation"
                           class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                           placeholder="如：北京" maxlength="100">
                </div>
            </div>
            <button type="submit" class="w-full py-2.5 bg-blue-500 text-white rounded text-sm font-medium hover:bg-blue-600 transition cursor-pointer border-none">
                注册
            </button>
        </form>
        <p class="text-center mt-5 text-sm text-gray-400">已有账号？<a href="${pageContext.request.contextPath}/user/login" class="text-blue-500 no-underline">立即登录</a></p>
    </div>
</div>

<script>
function validateRegister() {
    var username = document.getElementById('regUsername').value.trim();
    var password = document.getElementById('regPassword').value.trim();
    var password2 = document.getElementById('regPassword2').value.trim();

    if (username.length < 3) {
        alert('用户名长度至少 3 位');
        return false;
    }
    if (password.length < 6) {
        alert('密码长度至少 6 位');
        return false;
    }
    if (password !== password2) {
        alert('两次输入的密码不一致');
        return false;
    }
    return true;
}
</script>
