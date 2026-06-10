<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Crect width='32' height='32' rx='6' fill='%232563EB'/%3E%3Cpath d='M8 6h16v20H8z' fill='%23fff'/%3E%3Cpath d='M8 6h2v20H8z' fill='%231d4ed8'/%3E%3Cpath d='M12 11h8M12 15h8M12 19h5' stroke='%2393c5fd' stroke-width='1.2' stroke-linecap='round' fill='none'/%3E%3C/svg%3E">
    <title>500 - 服务器错误 | BBS论坛</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css">
</head>
<body>
<div style="text-align:center;padding:100px 20px;">
    <i class="fa fa-exclamation-triangle" style="font-size:80px;color:#ef4444;"></i>
    <h1 style="font-size:48px;color:#dc2626;margin:20px 0;">500</h1>
    <p style="color:#94a3b8;margin-bottom:24px;">服务器内部错误，请稍后再试</p>
    <a href="${pageContext.request.contextPath}/" class="btn btn-primary btn-lg">
        <i class="fa fa-home"></i> 返回首页
    </a>
</div>
</body>
</html>
