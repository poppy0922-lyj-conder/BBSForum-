<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 个人中心专用布局：左右分栏 -->
<div class="flex gap-5">
    <!-- 左侧边栏 -->
    <c:set var="activeMenu" value="profile" scope="request" />
    <jsp:include page="/user/profile_sidebar.jsp" />

    <!-- 右侧主内容区 -->
    <main class="flex-1 min-w-0 space-y-4">
        <!-- 成功提示 -->
        <c:if test="${not empty successMessage}">
            <div class="flex items-center gap-2 px-4 py-3 bg-green-50 border border-green-200 rounded-lg text-sm text-green-700">
                <i class="fa fa-check-circle"></i>
                <span>${successMessage}</span>
                <button onclick="this.parentElement.remove()" class="ml-auto text-green-500 hover:text-green-700 cursor-pointer">&times;</button>
            </div>
        </c:if>

        <!-- 基本信息卡片 -->
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h3 class="text-base font-semibold text-gray-800 mb-4 flex items-center gap-2">
                <i class="fa fa-id-card-o text-blue-500"></i> 基本信息
            </h3>
            <div class="space-y-3 text-sm">
                <div class="flex border-b border-gray-100 pb-3">
                    <span class="w-24 text-gray-500 shrink-0">用户名</span>
                    <span class="text-gray-800 font-medium">${user.username}</span>
                </div>
                <div class="flex border-b border-gray-100 pb-3">
                    <span class="w-24 text-gray-500 shrink-0">联系方式</span>
                    <span class="text-gray-800">${empty user.phone ? '未填写' : user.phone}</span>
                </div>
                <div class="flex border-b border-gray-100 pb-3">
                    <span class="w-24 text-gray-500 shrink-0">工作性质</span>
                    <span class="text-gray-800">${empty user.jobType ? '未填写' : user.jobType}</span>
                </div>
                <div class="flex border-b border-gray-100 pb-3">
                    <span class="w-24 text-gray-500 shrink-0">工作地点</span>
                    <span class="text-gray-800">${empty user.jobLocation ? '未填写' : user.jobLocation}</span>
                </div>
                <div class="flex">
                    <span class="w-24 text-gray-500 shrink-0">注册时间</span>
                    <span class="text-gray-800">${user.createdAt}</span>
                </div>
            </div>
        </div>

        <!-- 当前积分模块 -->
        <div class="bg-white rounded-lg shadow-sm p-6 text-center">
            <div class="text-4xl font-bold text-blue-500 mb-1">
                <i class="fa fa-diamond"></i> ${user.score}
            </div>
            <div class="text-sm text-gray-500">当前积分</div>
            <!-- 签到按钮 -->
            <button id="checkinBtn" onclick="doCheckin()" class="mt-4 px-6 py-2 bg-blue-500 text-white text-sm rounded hover:bg-blue-600 transition cursor-pointer border-none">
                <i class="fa fa-calendar-check-o"></i> 每日签到
            </button>
        </div>

        <!-- 退出登录按钮 -->
        <div class="bg-white rounded-lg shadow-sm p-4 text-center">
            <a href="${pageContext.request.contextPath}/logout" class="inline-flex items-center gap-2 px-5 py-2 text-sm border border-red-200 rounded text-red-500 hover:bg-red-50 hover:text-red-600 transition no-underline">
                <i class="fa fa-sign-out"></i> 退出登录
            </a>
        </div>
    </main>
</div>

<script>
async function doCheckin() {
    var btn = document.getElementById('checkinBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> 签到中...';

    try {
        var response = await fetch('${pageContext.request.contextPath}/user/checkin');
        var data = await response.json();

        if (data.ok) {
            await alert('签到成功！获得 +' + data.score + ' 积分，连续签到 ' + data.consecutive + ' 天');
            // 刷新页面更新积分显示
            window.location.reload();
        } else {
            await alert(data.msg || '签到失败');
            btn.disabled = false;
            btn.innerHTML = '<i class="fa fa-calendar-check-o"></i> 每日签到';
        }
    } catch (e) {
        await alert('网络错误，请重试');
        btn.disabled = false;
        btn.innerHTML = '<i class="fa fa-calendar-check-o"></i> 每日签到';
    }
}
</script>
