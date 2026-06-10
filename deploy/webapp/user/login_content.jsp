<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="max-w-md mx-auto mt-16">
    <div class="bg-white rounded-lg shadow-sm p-10">
        <h2 class="text-2xl font-bold text-center mb-1">登录</h2>
        <p class="text-center text-gray-400 text-sm mb-7">欢迎回到BBS技术社区</p>

        <!-- 注册成功提示 -->
        <c:if test="${param.registered == '1'}">
            <div class="flex items-center gap-2 bg-green-50 text-green-700 border border-green-200 rounded px-4 py-2.5 text-sm mb-5">
                <i class="fa fa-check-circle"></i> 注册成功，请登录
            </div>
        </c:if>

        <!-- 操作成功提示 -->
        <c:if test="${param.success == '1'}">
            <div class="flex items-center gap-2 bg-green-50 text-green-700 border border-green-200 rounded px-4 py-2.5 text-sm mb-5">
                <i class="fa fa-check-circle"></i> 操作成功
            </div>
        </c:if>

        <!-- 错误提示 -->
        <c:if test="${not empty error}">
            <div class="flex items-center gap-2 bg-red-50 text-red-600 border border-red-200 rounded px-4 py-2.5 text-sm mb-5">
                <i class="fa fa-exclamation-circle"></i> ${error}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/user/login" method="post" onsubmit="return validateLogin()">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-1.5">用户名</label>
                <input type="text" name="username" id="loginUsername"
                       class="w-full px-3 py-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                       placeholder="请输入用户名" required autofocus minlength="3" maxlength="50">
            </div>
            <div class="mb-5">
                <label class="block text-sm font-medium text-gray-700 mb-1.5">密码</label>
                <input type="password" name="password" id="loginPassword"
                       class="w-full px-3 py-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200"
                       placeholder="请输入密码" required minlength="6">
            </div>
            <button type="submit" class="w-full py-2.5 bg-blue-500 text-white rounded text-sm font-medium hover:bg-blue-600 transition cursor-pointer border-none">
                登录
            </button>
        </form>
        <p class="text-center mt-5 text-sm text-gray-400">还没有账号？<a href="${pageContext.request.contextPath}/user/register" class="text-blue-500 no-underline">立即注册</a></p>
    </div>
</div>

<script>
function validateLogin() {
    var username = document.getElementById('loginUsername').value.trim();
    var password = document.getElementById('loginPassword').value.trim();

    if (username.length < 3) {
        alert('用户名长度至少 3 位');
        return false;
    }
    if (password.length < 6) {
        alert('密码长度至少 6 位');
        return false;
    }
    return true;
}
</script>
