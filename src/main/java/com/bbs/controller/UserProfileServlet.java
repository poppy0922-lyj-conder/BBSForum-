package com.bbs.controller;

import com.bbs.util.DBUtil;
import com.bbs.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 用户个人中心（组员B）
 * - /user/profile       个人信息展示
 * - /user/profile/edit  资料编辑（可选改密）
 * - /user/score-log     积分记录查询（分页）
 */
@WebServlet(name = "userProfile", urlPatterns = {"/user/profile", "/user/profile/edit", "/user/profile/follows", "/user/score-log"})
public class UserProfileServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(UserProfileServlet.class.getName());
    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        HttpSession session = request.getSession(false);
        Map<String, Object> sessionUser = session == null ? null : (Map<String, Object>) session.getAttribute("user");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int userId = (int) sessionUser.get("id");
        Map<String, Object> user = loadUserById(userId);
        if (user == null) {
            if (session != null) session.invalidate();
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        request.setAttribute("user", user);

        if ("/user/profile".equals(path)) {
            if ("1".equals(request.getParameter("updated"))) {
                request.setAttribute("successMessage", "资料已更新");
            }
            // 加载最近积分记录（最近5条用于边栏展示）
            List<Map<String, Object>> scoreLogs = loadScoreLogs(userId, 5);
            request.setAttribute("scoreLogs", scoreLogs);
            request.setAttribute("pageTitle", "个人中心");
            request.getRequestDispatcher("/user/profile.jsp").forward(request, response);
        } else if ("/user/profile/edit".equals(path)) {
            request.setAttribute("pageTitle", "编辑资料");
            request.getRequestDispatcher("/user/profile_edit.jsp").forward(request, response);
        } else if ("/user/profile/follows".equals(path)) {
            List<Map<String, Object>> followList = loadFollows(userId);
            request.setAttribute("followList", followList);
            request.setAttribute("pageTitle", "我的关注");
            request.getRequestDispatcher("/user/follows.jsp").forward(request, response);
        } else if ("/user/score-log".equals(path)) {
            handleScoreLog(request, response, userId);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if (!"/user/profile/edit".equals(path)) {
            response.sendRedirect(request.getContextPath() + "/user/profile");
            return;
        }

        HttpSession session = request.getSession(false);
        Map<String, Object> sessionUser = session == null ? null : (Map<String, Object>) session.getAttribute("user");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int userId = (int) sessionUser.get("id");

        String phone = request.getParameter("phone");
        String jobType = request.getParameter("jobType");
        String jobLocation = request.getParameter("jobLocation");
        String password = request.getParameter("password");
        String password2 = request.getParameter("password2");

        // XSS 转义处理用户输入
        phone = escapeHtml(phone);
        jobType = escapeHtml(jobType);
        jobLocation = escapeHtml(jobLocation);

        // 校验：新密码非空则要求两次一致
        if (password != null && !password.trim().isEmpty()) {
            if (password.trim().length() < 6) {
                request.setAttribute("error", "新密码长度至少 6 位");
                Map<String, Object> user = loadUserById(userId);
                request.setAttribute("user", user);
                request.getRequestDispatcher("/user/profile_edit.jsp").forward(request, response);
                return;
            }
            if (password2 == null || !password.trim().equals(password2.trim())) {
                request.setAttribute("error", "两次输入的新密码不一致");
                Map<String, Object> user = loadUserById(userId);
                request.setAttribute("user", user);
                request.getRequestDispatcher("/user/profile_edit.jsp").forward(request, response);
                return;
            }
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE users SET phone = ?, job_type = ?, job_location = ? WHERE id = ?")) {
                ps.setString(1, phone == null ? "" : phone.trim());
                ps.setString(2, jobType == null ? "" : jobType.trim());
                ps.setString(3, jobLocation == null ? "" : jobLocation.trim());
                ps.setInt(4, userId);
                ps.executeUpdate();
            }

            if (password != null && !password.trim().isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?")) {
                    ps.setString(1, PasswordUtil.hash(password.trim()));
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.setAttribute("error", "保存失败，请重试");
            Map<String, Object> user = loadUserById(userId);
            request.setAttribute("user", user);
            request.getRequestDispatcher("/user/profile_edit.jsp").forward(request, response);
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ex) { ex.printStackTrace(); }
                DBUtil.close(conn, null, null);
            }
        }

        // 刷新 session user（避免导航栏/回显信息滞后）
        Map<String, Object> fresh = loadUserById(userId);
        if (fresh != null) {
            session.setAttribute("user", fresh);
        }

        response.sendRedirect(request.getContextPath() + "/user/profile?updated=1");
    }

    /** 积分记录页面处理 */
    private void handleScoreLog(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        // 获取当前页码
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) page = 1;
        } catch (NumberFormatException ignored) {}

        // 获取总记录数
        int totalCount = 0;
        String countSql = "SELECT COUNT(*) FROM score_logs WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(countSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCount = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "查询积分记录总数失败: userId=" + userId, e);
        }

        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * PAGE_SIZE;

        // 获取当前总积分
        int totalScore = 0;
        String scoreSql = "SELECT score FROM users WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(scoreSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalScore = rs.getInt("score");
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "查询用户积分失败: userId=" + userId, e);
        }

        // 分页查询积分流水
        List<Map<String, Object>> scoreLogs = new ArrayList<>();
        String logSql = "SELECT score, reason, created_at FROM score_logs WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(logSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, PAGE_SIZE);
            ps.setInt(3, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> log = new HashMap<>();
                    log.put("score", rs.getInt("score"));
                    log.put("reason", rs.getString("reason"));
                    log.put("createdAt", rs.getTimestamp("created_at"));
                    scoreLogs.add(log);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "查询积分流水失败: userId=" + userId, e);
        }

        // 生成分页HTML
        String pagination = buildPagination(request.getContextPath() + "/user/score-log", page, totalPages, totalCount);

        request.setAttribute("totalScore", totalScore);
        request.setAttribute("scoreLogs", scoreLogs);
        request.setAttribute("pagination", pagination);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageTitle", "积分记录");
        request.getRequestDispatcher("/user/score_log.jsp").forward(request, response);
    }

    /** 构建分页HTML */
    private String buildPagination(String baseUrl, int currentPage, int totalPages, int totalCount) {
        if (totalPages <= 1) return "";

        StringBuilder sb = new StringBuilder();
        sb.append("<div class=\"flex items-center justify-between mt-4\">");
        sb.append("<span class=\"text-xs text-gray-400\">共 ").append(totalCount).append(" 条记录</span>");
        sb.append("<div class=\"flex items-center gap-1\">");

        // 上一页
        if (currentPage > 1) {
            sb.append("<a href=\"").append(baseUrl).append("?page=").append(currentPage - 1)
              .append("\" class=\"px-3 py-1 text-xs border border-gray-200 rounded text-gray-600 hover:bg-blue-50 hover:text-blue-500 no-underline\">上一页</a>");
        } else {
            sb.append("<span class=\"px-3 py-1 text-xs border border-gray-100 rounded text-gray-300 cursor-not-allowed\">上一页</span>");
        }

        // 页码
        int startPage = Math.max(1, currentPage - 2);
        int endPage = Math.min(totalPages, startPage + 4);
        if (endPage - startPage < 4) {
            startPage = Math.max(1, endPage - 4);
        }

        for (int i = startPage; i <= endPage; i++) {
            if (i == currentPage) {
                sb.append("<span class=\"px-3 py-1 text-xs bg-blue-500 text-white rounded\">").append(i).append("</span>");
            } else {
                sb.append("<a href=\"").append(baseUrl).append("?page=").append(i)
                  .append("\" class=\"px-3 py-1 text-xs border border-gray-200 rounded text-gray-600 hover:bg-blue-50 hover:text-blue-500 no-underline\">").append(i).append("</a>");
            }
        }

        // 下一页
        if (currentPage < totalPages) {
            sb.append("<a href=\"").append(baseUrl).append("?page=").append(currentPage + 1)
              .append("\" class=\"px-3 py-1 text-xs border border-gray-200 rounded text-gray-600 hover:bg-blue-50 hover:text-blue-500 no-underline\">下一页</a>");
        } else {
            sb.append("<span class=\"px-3 py-1 text-xs border border-gray-100 rounded text-gray-300 cursor-not-allowed\">下一页</span>");
        }

        sb.append("</div></div>");
        return sb.toString();
    }

    /** 从数据库加载用户信息（用于个人中心展示/回显） */
    private Map<String, Object> loadUserById(int userId) {
        String sql = "SELECT id, username, role, phone, job_type, job_location, score, created_at FROM users WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> user = new HashMap<>();
                    user.put("id", rs.getInt("id"));
                    user.put("username", rs.getString("username"));
                    user.put("role", rs.getString("role"));
                    user.put("phone", rs.getString("phone") == null ? "" : rs.getString("phone"));
                    user.put("jobType", rs.getString("job_type") == null ? "" : rs.getString("job_type"));
                    user.put("jobLocation", rs.getString("job_location") == null ? "" : rs.getString("job_location"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    user.put("createdAt", createdAt == null ? "" : createdAt.toString());
                    user.put("score", rs.getInt("score"));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /** 查询当前用户关注的用户列表 */
    private List<Map<String, Object>> loadFollows(int userId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.phone, u.job_type, u.job_location " +
                     "FROM user_follows f JOIN users u ON f.followed_user_id = u.id " +
                     "WHERE f.user_id = ? ORDER BY f.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> user = new HashMap<>();
                    user.put("id", rs.getInt("id"));
                    user.put("username", rs.getString("username"));
                    user.put("phone", rs.getString("phone") == null ? "" : rs.getString("phone"));
                    user.put("jobType", rs.getString("job_type") == null ? "" : rs.getString("job_type"));
                    user.put("jobLocation", rs.getString("job_location") == null ? "" : rs.getString("job_location"));
                    list.add(user);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** 加载用户最近积分记录 */
    private List<Map<String, Object>> loadScoreLogs(int userId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT score, reason, created_at FROM score_logs WHERE user_id = ? ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> log = new HashMap<>();
                    log.put("score", rs.getInt("score"));
                    log.put("reason", rs.getString("reason") == null ? "" : rs.getString("reason"));
                    log.put("createdAt", rs.getTimestamp("created_at"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "加载积分记录失败: userId=" + userId, e);
        }
        return list;
    }

    /** HTML 转义防止 XSS */
    private String escapeHtml(String input) {
        if (input == null) return null;
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
}
