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
<c:set var="pageTitle" value="管理员后台" scope="request" />
<c:set var="adminLayout" value="true" scope="request" />
<c:set var="adminActiveMenu" value="dashboard" scope="request" />
<c:set var="contentPage" value="/admin/index_content.jsp" scope="request" />
<jsp:include page="/layouts/main.jsp" />
