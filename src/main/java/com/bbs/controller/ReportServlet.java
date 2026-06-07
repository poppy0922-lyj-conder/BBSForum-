package com.bbs.controller;

import com.bbs.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 举报控制器
 * 负责：用户提交举报、管理员查看/处理举报
 */
@WebServlet(name = "report", urlPatterns = {"/report/submit", "/admin/report/list", "/admin/report/preview", "/admin/report/handle"})
public class ReportServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(ReportServlet.class.getName());
    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/admin/report/list".equals(path)) {
            handleReportList(request, response);
        } else if ("/admin/report/preview".equals(path)) {
            handleReportPreview(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/report/submit".equals(path)) {
            handleReportSubmit(request, response);
        } else if ("/admin/report/handle".equals(path)) {
            handleReportAction(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    /** 用户提交举报 */
    private void handleReportSubmit(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 登录检查
        Map<String, Object> user = (Map<String, Object>) request.getSession().getAttribute("user");
        if (user == null) {
            out.print("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }

        int reporterId = ((Number) user.get("id")).intValue();
        String targetType = request.getParameter("targetType");
        String targetIdStr = request.getParameter("targetId");
        String reason = request.getParameter("reason");

        // 参数校验
        if (targetType == null || targetIdStr == null || reason == null) {
            out.print("{\"success\":false,\"message\":\"参数错误\"}");
            return;
        }

        if (!targetType.matches("^(post|reply|demand|demand_reply)$")) {
            out.print("{\"success\":false,\"message\":\"举报类型无效\"}");
            return;
        }

        if (!reason.matches("^(spam|abuse|illegal|porn|other)$")) {
            out.print("{\"success\":false,\"message\":\"举报原因无效\"}");
            return;
        }

        int targetId;
        try {
            targetId = Integer.parseInt(targetIdStr);
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"参数错误\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 检查目标存在性和作者
            Integer authorId = getTargetAuthorId(conn, targetType, targetId);
            if (authorId == null) {
                out.print("{\"success\":false,\"message\":\"内容不存在或已删除\"}");
                return;
            }

            // 不能举报自己
            if (authorId == reporterId) {
                out.print("{\"success\":false,\"message\":\"不能举报自己\"}");
                return;
            }

            // 检查重复举报（仅pending状态限制）
            String checkSql = "SELECT id FROM reports WHERE reporter_id = ? AND target_type = ? AND target_id = ? AND status = 'pending'";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, reporterId);
                ps.setString(2, targetType);
                ps.setInt(3, targetId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        out.print("{\"success\":false,\"message\":\"您已举报过此内容，请等待处理\"}");
                        return;
                    }
                }
            }

            // 插入举报记录
            String insertSql = "INSERT INTO reports (reporter_id, target_type, target_id, reason, status) VALUES (?, ?, ?, ?, 'pending')";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, reporterId);
                ps.setString(2, targetType);
                ps.setInt(3, targetId);
                ps.setString(4, reason);
                ps.executeUpdate();
            }

            out.print("{\"success\":true,\"message\":\"举报已提交，感谢您的反馈\"}");
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "提交举报失败", e);
            out.print("{\"success\":false,\"message\":\"服务器错误\"}");
        }
    }

    /** 管理员举报列表 */
    private void handleReportList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 管理员权限检查
        Map<String, Object> user = (Map<String, Object>) request.getSession().getAttribute("user");
        if (user == null || !"admin".equals(user.get("role"))) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // 获取参数
        String statusParam = request.getParameter("status");
        if (statusParam == null || statusParam.isEmpty()) statusParam = "pending";
        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 统计总数
            int totalCount = 0;
            String countSql = "SELECT COUNT(*) FROM reports WHERE (? = 'all' OR status = ?)";
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setString(1, statusParam);
                ps.setString(2, statusParam);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getInt(1);
                }
            }

            int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
            if (page > totalPages && totalPages > 0) page = totalPages;
            int offset = (page - 1) * PAGE_SIZE;

            // 查询列表
            List<Map<String, Object>> reportList = new ArrayList<>();
            String listSql = "SELECT r.*, u.username AS reporter_username " +
                             "FROM reports r JOIN users u ON r.reporter_id = u.id " +
                             "WHERE (? = 'all' OR r.status = ?) " +
                             "ORDER BY r.created_at DESC LIMIT ? OFFSET ?";
            try (PreparedStatement ps = conn.prepareStatement(listSql)) {
                ps.setString(1, statusParam);
                ps.setString(2, statusParam);
                ps.setInt(3, PAGE_SIZE);
                ps.setInt(4, offset);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> report = new HashMap<>();
                        report.put("id", rs.getInt("id"));
                        report.put("reporterId", rs.getInt("reporter_id"));
                        report.put("reporterUsername", rs.getString("reporter_username"));
                        report.put("targetType", rs.getString("target_type"));
                        report.put("targetId", rs.getInt("target_id"));
                        report.put("reason", rs.getString("reason"));
                        report.put("status", rs.getString("status"));
                        report.put("handlerId", rs.getObject("handler_id"));
                        report.put("handleNote", rs.getString("handle_note"));
                        report.put("createdAt", rs.getTimestamp("created_at"));
                        report.put("updatedAt", rs.getTimestamp("updated_at"));
                        reportList.add(report);
                    }
                }
            }

            request.setAttribute("reportList", reportList);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("currentStatus", statusParam);

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询举报列表失败", e);
        }

        request.getRequestDispatcher("/admin/report_manage.jsp").forward(request, response);
    }

    /** 管理员预览被举报内容 */
    private void handleReportPreview(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 管理员权限检查
        Map<String, Object> user = (Map<String, Object>) request.getSession().getAttribute("user");
        if (user == null || !"admin".equals(user.get("role"))) {
            response.setStatus(403);
            out.print("无权访问");
            return;
        }

        int reportId;
        try {
            reportId = Integer.parseInt(request.getParameter("reportId"));
        } catch (NumberFormatException e) {
            response.setStatus(400);
            out.print("参数错误");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 查询举报记录
            String reportSql = "SELECT target_type, target_id FROM reports WHERE id = ?";
            String targetType = null;
            int targetId = 0;
            try (PreparedStatement ps = conn.prepareStatement(reportSql)) {
                ps.setInt(1, reportId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        targetType = rs.getString("target_type");
                        targetId = rs.getInt("target_id");
                    }
                }
            }

            if (targetType == null) {
                response.setStatus(404);
                out.print("举报记录不存在");
                return;
            }

            // 根据类型查询内容
            String html = buildPreviewHtml(conn, targetType, targetId);
            out.print(html);

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "预览举报内容失败, reportId=" + reportId, e);
            response.setStatus(500);
            out.print("服务器错误");
        }
    }

    /** 管理员处理举报 */
    private void handleReportAction(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        // 管理员权限检查
        Map<String, Object> user = (Map<String, Object>) request.getSession().getAttribute("user");
        if (user == null || !"admin".equals(user.get("role"))) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        int handlerId = ((Number) user.get("id")).intValue();
        int reportId;
        try {
            reportId = Integer.parseInt(request.getParameter("reportId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/report/list");
            return;
        }

        String action = request.getParameter("action");
        if (!"approve".equals(action) && !"reject".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/admin/report/list");
            return;
        }

        String handleNote = request.getParameter("handleNote");
        if (handleNote == null) handleNote = "";
        if (handleNote.length() > 200) handleNote = handleNote.substring(0, 200);

        String newStatus = "approve".equals(action) ? "approved" : "rejected";

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 查询举报记录（加锁）
            int targetId = 0;
            String targetType = null;
            String currentStatus = null;
            int reporterId = 0;
            String reason = null;
            String lockSql = "SELECT target_type, target_id, status, reporter_id, reason FROM reports WHERE id = ? FOR UPDATE";
            try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                ps.setInt(1, reportId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        targetType = rs.getString("target_type");
                        targetId = rs.getInt("target_id");
                        currentStatus = rs.getString("status");
                        reporterId = rs.getInt("reporter_id");
                        reason = rs.getString("reason");
                    }
                }
            }

            if (currentStatus == null || !"pending".equals(currentStatus)) {
                conn.rollback();
                response.sendRedirect(request.getContextPath() + "/admin/report/list?status=pending&error=already_handled");
                return;
            }

            // 如果是通过，执行软删除
            // 预先获取被举报内容作者ID（软删除前查询，否则 is_deleted=1 会导致查不到）
            Integer targetAuthorId = null;
            if ("approve".equals(action) && targetType != null) {
                targetAuthorId = getTargetAuthorId(conn, targetType, targetId);

                // 检查是否已删除
                boolean alreadyDeleted = checkIsDeleted(conn, targetType, targetId);
                if (!alreadyDeleted) {
                    softDelete(conn, targetType, targetId);
                } else {
                    handleNote = handleNote.isEmpty() ? "内容已删除" : handleNote + "；内容已删除";
                }
            }

            // 更新举报状态
            String updateSql = "UPDATE reports SET status = ?, handler_id = ?, handle_note = ?, updated_at = NOW() WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, handlerId);
                ps.setString(3, handleNote);
                ps.setInt(4, reportId);
                ps.executeUpdate();
            }

            // === 通知逻辑 ===
            String targetTypeName;
            switch (targetType != null ? targetType : "") {
                case "post": targetTypeName = "帖子"; break;
                case "reply": targetTypeName = "回复"; break;
                case "demand": targetTypeName = "需求"; break;
                case "demand_reply": targetTypeName = "需求回复"; break;
                default: targetTypeName = "内容";
            }

            // 通知举报人
            String reporterMsg = "您举报的" + targetTypeName + "(ID:" + targetId + ")已处理，结果为：" + ("approve".equals(action) ? "通过" : "驳回");
            insertNotification(conn, reporterId, "report_result", reporterMsg);

            // 通知被举报人（仅通过时）
            if ("approve".equals(action) && targetAuthorId != null && targetAuthorId != reporterId) {
                String reasonText = mapReasonToChinese(reason);
                String authorMsg = "您发布的" + targetTypeName + "因【" + reasonText + "】已被删除";
                insertNotification(conn, targetAuthorId, "content_deleted", authorMsg);
            }

            conn.commit();
            LOG.info("举报处理成功: reportId=" + reportId + ", action=" + newStatus);

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOG.log(Level.WARNING, "回滚失败", ex); }
            }
            LOG.log(Level.SEVERE, "处理举报失败: reportId=" + reportId, e);
            response.sendRedirect(request.getContextPath() + "/admin/report/list?status=pending&error=handle_failed");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { LOG.log(Level.WARNING, "关闭连接失败", e); }
            }
        }

        String successMsg = "approve".equals(action) ? "举报已通过，内容已删除" : "举报已驳回";
        response.sendRedirect(request.getContextPath() + "/admin/report/list?status=pending&successMsg=" + URLEncoder.encode(successMsg, "UTF-8"));
    }

    /** 查询目标内容作者ID，不存在或已删除返回null */
    private Integer getTargetAuthorId(Connection conn, String targetType, int targetId) throws SQLException {
        String table;
        switch (targetType) {
            case "post": table = "posts"; break;
            case "reply": table = "replies"; break;
            case "demand": table = "demands"; break;
            case "demand_reply": table = "demand_replies"; break;
            default: return null;
        }
        String sql = "SELECT user_id, is_deleted FROM " + table + " WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, targetId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    if (rs.getInt("is_deleted") == 1) return null;
                    return rs.getInt("user_id");
                }
            }
        }
        return null;
    }

    /** 检查目标内容是否已软删除 */
    private boolean checkIsDeleted(Connection conn, String targetType, int targetId) throws SQLException {
        String table;
        switch (targetType) {
            case "post": table = "posts"; break;
            case "reply": table = "replies"; break;
            case "demand": table = "demands"; break;
            case "demand_reply": table = "demand_replies"; break;
            default: return true;
        }
        String sql = "SELECT is_deleted FROM " + table + " WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, targetId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("is_deleted") == 1;
                }
            }
        }
        return true;
    }

    /** 执行软删除 */
    private void softDelete(Connection conn, String targetType, int targetId) throws SQLException {
        String table;
        switch (targetType) {
            case "post": table = "posts"; break;
            case "reply": table = "replies"; break;
            case "demand": table = "demands"; break;
            case "demand_reply": table = "demand_replies"; break;
            default: return;
        }
        String sql = "UPDATE " + table + " SET is_deleted = 1 WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, targetId);
            ps.executeUpdate();
        }
    }

    /** 构建预览HTML片段 */
    private String buildPreviewHtml(Connection conn, String targetType, int targetId) throws SQLException {
        StringBuilder html = new StringBuilder();
        switch (targetType) {
            case "post": {
                String sql = "SELECT p.title, p.content, p.is_deleted, u.username FROM posts p JOIN users u ON p.user_id = u.id WHERE p.id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, targetId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String status = rs.getInt("is_deleted") == 1 ? "已删除" : "正常";
                            html.append("<div class=\"mb-2\"><strong>类型：</strong>帖子</div>");
                            html.append("<div class=\"mb-2\"><strong>标题：</strong>").append(escapeHtml(rs.getString("title"))).append("</div>");
                            String content = rs.getString("content");
                            if (content != null && content.length() > 200) content = content.substring(0, 200) + "...";
                            html.append("<div class=\"mb-2\"><strong>内容：</strong>").append(escapeHtml(content)).append("</div>");
                            html.append("<div class=\"mb-2\"><strong>作者：</strong>").append(escapeHtml(rs.getString("username"))).append("</div>");
                            html.append("<div class=\"mb-2\"><strong>当前状态：</strong>").append(status).append("</div>");
                        }
                    }
                }
                break;
            }
            case "reply": {
                String sql = "SELECT r.content, r.is_deleted, u.username, p.title AS post_title FROM replies r JOIN users u ON r.user_id = u.id JOIN posts p ON r.post_id = p.id WHERE r.id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, targetId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String status = rs.getInt("is_deleted") == 1 ? "已删除" : "正常";
                            html.append("<div class=\"mb-2\"><strong>类型：</strong>回复（帖子：").append(escapeHtml(rs.getString("post_title"))).append("</div>");
                            String content = rs.getString("content");
                            if (content != null && content.length() > 200) content = content.substring(0, 200) + "...";
                            html.append("<div class=\"mb-2\"><strong>内容：</strong>").append(escapeHtml(content)).append("</div>");
                            html.append("<div class=\"mb-2\"><strong>作者：</strong>").append(escapeHtml(rs.getString("username"))).append("</div>");
                            html.append("<div class=\"mb-2\"><strong>当前状态：</strong>").append(status).append("</div>");
                        }
                    }
                }
                break;
            }
            case "demand": {
                String sql = "SELECT d.title, d.content, d.is_deleted, u.username FROM demands d JOIN users u ON d.user_id = u.id WHERE d.id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, targetId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String status = rs.getInt("is_deleted") == 1 ? "已删除" : "正常";
                            html.append("<div class=\"mb-2\"><strong>类型：</strong>需求</div>");
                            html.append("<div class=\"mb-2\"><strong>标题：</strong>").append(escapeHtml(rs.getString("title"))).append("</div>");
                            String content = rs.getString("content");
                            if (content != null && content.length() > 200) content = content.substring(0, 200) + "...";
                            html.append("<div class=\"mb-2\"><strong>内容：</strong>").append(escapeHtml(content)).append("</div>");
                            html.append("<div class=\"mb-2\"><strong>作者：</strong>").append(escapeHtml(rs.getString("username"))).append("</div>");
                            html.append("<div class=\"mb-2\"><strong>当前状态：</strong>").append(status).append("</div>");
                        }
                    }
                }
                break;
            }
            case "demand_reply": {
                String sql = "SELECT dr.content, dr.is_deleted, u.username, d.title AS demand_title FROM demand_replies dr JOIN users u ON dr.user_id = u.id JOIN demands d ON dr.demand_id = d.id WHERE dr.id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, targetId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String status = rs.getInt("is_deleted") == 1 ? "已删除" : "正常";
                            html.append("<div class=\"mb-2\"><strong>类型：</strong>需求回复（需求：").append(escapeHtml(rs.getString("demand_title"))).append("</div>");
                            String content = rs.getString("content");
                            if (content != null && content.length() > 200) content = content.substring(0, 200) + "...";
                            html.append("<div class=\"mb-2\"><strong>内容：</strong>").append(escapeHtml(content)).append("</div>");
                            html.append("<div class=\"mb-2\"><strong>作者：</strong>").append(escapeHtml(rs.getString("username"))).append("</div>");
                            html.append("<div class=\"mb-2\"><strong>当前状态：</strong>").append(status).append("</div>");
                        }
                    }
                }
                break;
            }
        }
        return html.toString();
    }

    /** HTML转义 */
    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    /** 插入通知（在事务内使用传入的 conn） */
    private void insertNotification(Connection conn, int userId, String type, String content) {
        String sql = "INSERT INTO notifications (user_id, type, content) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, type);
            ps.setString(3, content);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "插入通知失败: userId=" + userId + ", type=" + type, e);
        }
    }

    /** 举报原因代码转中文 */
    private String mapReasonToChinese(String reason) {
        if (reason == null) return "未知原因";
        switch (reason) {
            case "spam": return "垃圾广告";
            case "abuse": return "人身攻击";
            case "illegal": return "政治敏感";
            case "porn": return "色情低俗";
            case "other": return "其他";
            default: return reason;
        }
    }
}
