package com.bbs.controller;

import com.bbs.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 站内通知控制器
 * 负责：未读通知数、通知列表、标记已读
 */
@WebServlet(name = "notification", urlPatterns = {"/notification/unreadCount", "/notification/list", "/notification/markRead", "/notification/detail"})
public class NotificationServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationServlet.class.getName());
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/notification/unreadCount".equals(path)) {
            handleUnreadCount(request, response);
        } else if ("/notification/list".equals(path)) {
            handleList(request, response);
        } else if ("/notification/detail".equals(path)) {
            handleDetail(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/notification/markRead".equals(path)) {
            handleMarkRead(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    /** 获取未读通知数（JSON） */
    private void handleUnreadCount(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        Map<String, Object> sessionUser = (Map<String, Object>) request.getSession().getAttribute("user");
        if (sessionUser == null) {
            out.print("{\"count\":0}");
            return;
        }

        int userId = ((Number) sessionUser.get("id")).intValue();
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    out.print("{\"count\":" + rs.getInt(1) + "}");
                } else {
                    out.print("{\"count\":0}");
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "查询未读通知数失败", e);
            out.print("{\"count\":0}");
        }
    }

    /** 通知列表页面 */
    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, Object> sessionUser = (Map<String, Object>) request.getSession().getAttribute("user");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int userId = ((Number) sessionUser.get("id")).intValue();

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
            String countSql = "SELECT COUNT(*) FROM notifications WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getInt(1);
                }
            }

            // 统计未读数
            int unreadCount = 0;
            String unreadSql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
            try (PreparedStatement ps = conn.prepareStatement(unreadSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) unreadCount = rs.getInt(1);
                }
            }

            int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
            if (page > totalPages && totalPages > 0) page = totalPages;
            int offset = (page - 1) * PAGE_SIZE;

            // 查询通知列表
            List<Map<String, Object>> notificationList = new ArrayList<>();
            String listSql = "SELECT id, type, content, target_url, is_read, created_at FROM notifications " +
                             "WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
            try (PreparedStatement ps = conn.prepareStatement(listSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, PAGE_SIZE);
                ps.setInt(3, offset);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> notification = new HashMap<>();
                        notification.put("id", rs.getInt("id"));
                        notification.put("type", rs.getString("type"));
                        notification.put("content", rs.getString("content"));
                        notification.put("targetUrl", rs.getString("target_url"));
                        notification.put("isRead", rs.getInt("is_read") == 1);
                        notification.put("createdAt", rs.getTimestamp("created_at"));
                        notificationList.add(notification);
                    }
                }
            }

            request.setAttribute("notificationList", notificationList);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("unreadCount", unreadCount);

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询通知列表失败", e);
        }

        request.getRequestDispatcher("/notification/list.jsp").forward(request, response);
    }

    /** 标记已读 */
    private void handleMarkRead(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Map<String, Object> sessionUser = (Map<String, Object>) request.getSession().getAttribute("user");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int userId = ((Number) sessionUser.get("id")).intValue();
        String idStr = request.getParameter("id");

        try (Connection conn = DBUtil.getConnection()) {
            if (idStr != null && !idStr.isEmpty()) {
                // 标记单条已读
                int notifId = Integer.parseInt(idStr);
                String sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, notifId);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }
            } else {
                // 全部已读
                String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "标记通知已读失败", e);
        } catch (NumberFormatException e) {
            // ignore
        }

        response.sendRedirect(request.getContextPath() + "/notification/list");
    }

    /** 通知详情页 */
    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, Object> sessionUser = (Map<String, Object>) request.getSession().getAttribute("user");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int userId = ((Number) sessionUser.get("id")).intValue();
        int notifId;
        try {
            notifId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/notification/list");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 查询通知（验证属于当前用户）
            String notifSql = "SELECT id, type, content, target_url, is_read, created_at FROM notifications WHERE id = ? AND user_id = ?";
            Map<String, Object> notification = null;
            try (PreparedStatement ps = conn.prepareStatement(notifSql)) {
                ps.setInt(1, notifId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        notification = new HashMap<>();
                        notification.put("id", rs.getInt("id"));
                        notification.put("type", rs.getString("type"));
                        notification.put("content", rs.getString("content"));
                        notification.put("targetUrl", rs.getString("target_url"));
                        notification.put("isRead", rs.getInt("is_read") == 1);
                        notification.put("createdAt", rs.getTimestamp("created_at"));
                    }
                }
            }

            if (notification == null) {
                response.sendRedirect(request.getContextPath() + "/notification/list");
                return;
            }

            // 标记为已读
            String markSql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(markSql)) {
                ps.setInt(1, notifId);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            // 尝试查询关联的举报记录
            String content = (String) notification.get("content");
            Map<String, Object> reportDetail = null;
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\\(ID:(\\d+)\\)");
            java.util.regex.Matcher matcher = pattern.matcher(content);
            if (matcher.find()) {
                int targetId = Integer.parseInt(matcher.group(1));
                String targetType = null;
                if (content.contains("帖子")) targetType = "post";
                else if (content.contains("回复") && !content.contains("需求")) targetType = "reply";
                else if (content.contains("需求回复")) targetType = "demand_reply";
                else if (content.contains("需求")) targetType = "demand";

                if (targetType != null) {
                    String reportSql = "SELECT r.id, r.target_type, r.target_id, r.reason, r.status, r.handle_note, " +
                                       "r.created_at AS report_created, r.updated_at AS report_updated, " +
                                       "u.username AS reporter_username " +
                                       "FROM reports r JOIN users u ON r.reporter_id = u.id " +
                                       "WHERE r.target_type = ? AND r.target_id = ? " +
                                       "ORDER BY r.created_at DESC LIMIT 1";
                    try (PreparedStatement ps = conn.prepareStatement(reportSql)) {
                        ps.setString(1, targetType);
                        ps.setInt(2, targetId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                reportDetail = new HashMap<>();
                                reportDetail.put("reportId", rs.getInt("id"));
                                reportDetail.put("targetType", rs.getString("target_type"));
                                reportDetail.put("targetId", rs.getInt("target_id"));
                                reportDetail.put("reason", rs.getString("reason"));
                                reportDetail.put("status", rs.getString("status"));
                                reportDetail.put("handleNote", rs.getString("handle_note"));
                                reportDetail.put("reportCreatedAt", rs.getTimestamp("report_created"));
                                reportDetail.put("reportUpdatedAt", rs.getTimestamp("report_updated"));
                                reportDetail.put("reporterUsername", rs.getString("reporter_username"));
                            }
                        }
                    }
                }
            }

            request.setAttribute("notification", notification);
            request.setAttribute("reportDetail", reportDetail);

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询通知详情失败", e);
        }

        request.getRequestDispatcher("/notification/detail.jsp").forward(request, response);
    }
}
