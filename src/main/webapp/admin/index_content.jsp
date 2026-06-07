<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bbs.util.DBUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
try (java.sql.Connection conn = DBUtil.getConnection();
     java.sql.Statement stmt = conn.createStatement()) {
    try (java.sql.ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM posts")) {
        if (rs.next()) request.setAttribute("postCount", rs.getInt(1));
    }
    try (java.sql.ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM users")) {
        if (rs.next()) request.setAttribute("userCount", rs.getInt(1));
    }
    try (java.sql.ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM categories")) {
        if (rs.next()) request.setAttribute("categoryCount", rs.getInt(1));
    }
} catch (Exception e) { e.printStackTrace(); }
%>

<div class="mb-6">
    <h2 class="text-xl font-bold text-gray-800 flex items-center gap-2">
        <i class="fa fa-dashboard text-blue-500"></i> 管理员后台
    </h2>
</div>

<!-- 统计卡片 -->
<div class="grid grid-cols-3 gap-4 mb-6">
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
        <div class="text-3xl font-bold text-blue-500">${postCount}</div>
        <div class="text-sm text-gray-400 mt-1">帖子总数</div>
    </div>
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
        <div class="text-3xl font-bold text-green-500">${userCount}</div>
        <div class="text-sm text-gray-400 mt-1">用户总数</div>
    </div>
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
        <div class="text-3xl font-bold text-amber-500">${categoryCount}</div>
        <div class="text-sm text-gray-400 mt-1">板块数量</div>
    </div>
</div>

<!-- 图表区域 -->
<div class="grid grid-cols-2 gap-4 mb-6">
    <!-- 各板块帖子统计 -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
        <h3 class="text-sm font-semibold text-gray-700 mb-3"><i class="fa fa-bar-chart text-blue-500 mr-1"></i> 各板块帖子统计</h3>
        <div style="position:relative; height:260px;">
            <canvas id="chartCategory"></canvas>
        </div>
    </div>
    <!-- 每日发帖量 -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
        <h3 class="text-sm font-semibold text-gray-700 mb-3"><i class="fa fa-line-chart text-green-500 mr-1"></i> 近30天每日发帖量</h3>
        <div style="position:relative; height:260px;">
            <canvas id="chartDailyPosts"></canvas>
        </div>
    </div>
</div>
<div class="mb-6">
    <!-- 用户增长 -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
        <h3 class="text-sm font-semibold text-gray-700 mb-3"><i class="fa fa-users text-purple-500 mr-1"></i> 近7天用户注册量</h3>
        <div style="position:relative; height:240px;">
            <canvas id="chartUserGrowth"></canvas>
        </div>
    </div>
</div>

<!-- 快捷入口 -->
<div class="grid grid-cols-3 gap-4">
    <a href="${pageContext.request.contextPath}/admin/categories"
       class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center no-underline hover:shadow-md transition block">
        <i class="fa fa-th-list text-2xl text-blue-500"></i>
        <p class="text-gray-700 mt-2 text-sm">板块管理</p>
    </a>
    <a href="${pageContext.request.contextPath}/admin/post/manage"
       class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center no-underline hover:shadow-md transition block">
        <i class="fa fa-file-text text-2xl text-green-500"></i>
        <p class="text-gray-700 mt-2 text-sm">帖子管理</p>
    </a>
    <a href="${pageContext.request.contextPath}/admin/users"
       class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center no-underline hover:shadow-md transition block">
        <i class="fa fa-users text-2xl text-purple-500"></i>
        <p class="text-gray-700 mt-2 text-sm">用户管理</p>
    </a>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script>
(function() {
    var ctx = '${pageContext.request.contextPath}';

    // 各板块帖子统计 - 环形图
    fetch(ctx + '/admin/chart/postsByCategory')
        .then(function(r) { return r.json(); })
        .then(function(d) {
            var colors = ['#3b82f6','#10b981','#f59e0b','#ef4444','#8b5cf6','#ec4899','#06b6d4','#84cc16'];
            new Chart(document.getElementById('chartCategory'), {
                type: 'doughnut',
                data: {
                    labels: d.labels,
                    datasets: [{
                        data: d.data,
                        backgroundColor: d.labels.map(function(_, i) { return colors[i % colors.length]; }),
                        borderWidth: 2,
                        borderColor: '#fff',
                        hoverOffset: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '55%',
                    plugins: {
                        legend: { position: 'right', labels: { boxWidth: 12, padding: 12, font: { size: 12 } } },
                        datalabels: undefined
                    }
                },
                plugins: [{
                    afterDraw: function(chart) {
                        var ctx2 = chart.ctx;
                        chart.data.datasets.forEach(function(dataset, i) {
                            var meta = chart.getDatasetMeta(i);
                            var total = dataset.data.reduce(function(a, b) { return a + b; }, 0);
                            meta.data.forEach(function(element, index) {
                                var value = dataset.data[index];
                                if (value === 0) return;
                                var pct = total > 0 ? Math.round(value / total * 100) : 0;
                                ctx2.save();
                                ctx2.fillStyle = '#fff';
                                ctx2.font = 'bold 12px sans-serif';
                                ctx2.textAlign = 'center';
                                ctx2.textBaseline = 'middle';
                                var pos = element.tooltipPosition();
                                ctx2.fillText(value + ' (' + pct + '%)', pos.x, pos.y);
                                ctx2.restore();
                            });
                        });
                    }
                }]
            });
        });

    // 每日发帖量 - 折线图
    fetch(ctx + '/admin/chart/dailyPosts')
        .then(function(r) { return r.json(); })
        .then(function(d) {
            new Chart(document.getElementById('chartDailyPosts'), {
                type: 'line',
                data: {
                    labels: d.labels,
                    datasets: [{
                        label: '发帖数',
                        data: d.data,
                        borderColor: '#10b981',
                        backgroundColor: 'rgba(16,185,129,0.1)',
                        fill: true,
                        tension: 0.3,
                        pointRadius: 3,
                        pointHoverRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
                }
            });
        });

    // 用户增长 - 折线图
    fetch(ctx + '/admin/chart/userGrowth')
        .then(function(r) { return r.json(); })
        .then(function(d) {
            new Chart(document.getElementById('chartUserGrowth'), {
                type: 'line',
                data: {
                    labels: d.labels,
                    datasets: [{
                        label: '注册人数',
                        data: d.data,
                        borderColor: '#8b5cf6',
                        backgroundColor: 'rgba(139,92,246,0.1)',
                        fill: true,
                        tension: 0.3,
                        pointRadius: 3,
                        pointHoverRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
                }
            });
        });
})();
</script>
