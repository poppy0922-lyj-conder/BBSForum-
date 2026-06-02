<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/">首页</a>
    <span>/</span> 发布需求悬赏
</div>

<h2 style="margin-bottom:20px;"><i class="fa fa-gift"></i> 发布需求悬赏</h2>

<form action="${pageContext.request.contextPath}/demand/create" method="post">
    <div class="form-group">
        <label for="categoryId">选择板块 *</label>
        <select name="categoryId" id="categoryId" class="form-select" required>
            <option value="">-- 请选择板块 --</option>
            <c:forEach var="cat" items="${applicationScope.categoryList}">
                <option value="${cat.id}">${cat.name}</option>
            </c:forEach>
        </select>
    </div>

    <div class="form-group">
        <label for="title">需求标题 *</label>
        <input type="text" name="title" id="title" class="form-input"
               placeholder="请输入需求标题" maxlength="100" required>
    </div>

    <div class="form-group">
        <label for="content">需求描述 *</label>
        <textarea name="content" id="content" class="form-input"
                  placeholder="请详细描述你的需求..." rows="8" required></textarea>
    </div>

    <div class="form-group">
        <label for="score">悬赏积分 *</label>
        <input type="number" name="score" id="score" class="form-input"
               placeholder="设置悬赏积分（从你的积分余额中扣除）" min="1" required>
        <p style="color:#94a3b8;font-size:12px;margin-top:4px;">
            <i class="fa fa-info-circle"></i> 当前积分余额：${userScore}。采纳后积分将转给最佳回复者。
        </p>
    </div>

    <div style="display:flex;gap:12px;">
        <button type="submit" class="btn btn-warning btn-lg">
            <i class="fa fa-gift"></i> 发布悬赏
        </button>
        <a href="${pageContext.request.contextPath}/demand" class="btn btn-lg" style="background:#e5e7eb;color:#475569;">
            取消
        </a>
    </div>
</form>
