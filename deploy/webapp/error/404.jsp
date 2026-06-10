<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - 页面未找到 | BBS论坛</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css">
</head>
<body>
<div style="text-align:center;padding:100px 20px;">
    <i class="fa fa-frown-o" style="font-size:80px;color:#94a3b8;"></i>
    <h1 style="font-size:48px;color:#64748b;margin:20px 0;">404</h1>
    <p style="color:#94a3b8;margin-bottom:24px;">抱歉，你访问的页面不存在</p>
    <a href="${pageContext.request.contextPath}/" class="btn btn-primary btn-lg">
        <i class="fa fa-home"></i> 返回首页
    </a>
</div>
</body>
</html>
