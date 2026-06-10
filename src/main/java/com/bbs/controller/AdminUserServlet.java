package com.bbs.controller;

import com.bbs.util.DBUtil;
import com.bbs.util.PostMapper;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 管理员用户管理控制器
 *
 * URL映射：
 *   GET  /admin/users           — 用户列表（分页+搜索）
 *   GET  /admin/users/edit      — 显示编辑表单
 *   POST /admin/users/edit      — 保存用户编辑
 *   POST /admin/users/toggleRole — 切换用户角色（user↔admin）
 *   POST /admin/users/delete    — 删除用户
 */
@WebServlet(name = "adminUser", urlPatterns = {
        "/admin/users",
        "/admin/users/edit",
        "/admin/users/toggleRole",
        "/admin/users/delete"
})
public class AdminUserServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(AdminUserServlet.class.getName());
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/admin/users".equals(path)) {
            handleList(request, response);
        } else if ("/admin/users/edit".equals(path)) {
            handleEditForm(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/admin/users/edit".equals(path)) {
            handleEditSave(request, response);
        } else if ("/admin/users/toggleRole".equals(path)) {
            handleToggleRole(request, response);
        } else if ("/admin/users/delete".equals(path)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    /** 用户列表（分页+搜索） */
    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 禁止浏览器缓存，确保删除后数字更新
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

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

        String keyword = request.getParameter("keyword");
        if (keyword != null) {
            keyword = keyword.trim();
            if (keyword.isEmpty()) keyword = null;
        }

        int totalUsers = countUsers(keyword);
        int totalPages = (int) Math.ceil((double) totalUsers / PAGE_SIZE);
        if (page > totalPages && totalPages > 0) page = totalPages;

        List<Map<String, Object>> userList = loadUsers(page, keyword);

        request.setAttribute("userList", userList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    /** 显示编辑表单 */
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        Map<String, Object> editUser = loadUser(id);
        if (editUser == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users?error=notFound");
            return;
        }

        request.setAttribute("editUser", editUser);
        request.getRequestDispatcher("/admin/user_edit.jsp").forward(request, response);
    }

    /** 保存用户编辑 */
    private void handleEditSave(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        String phone = request.getParameter("phone");
        String jobType = request.getParameter("jobType");
        String jobLocation = request.getParameter("jobLocation");
        String role = request.getParameter("role");
        String scoreStr = request.getParameter("score");

        // 角色校验
        if (!"user".equals(role) && !"admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/admin/users/edit?id=" + id + "&error=invalidRole");
            return;
        }

        // 积分校验
        int score = 0;
        try {
            score = Integer.parseInt(scoreStr);
            if (score < 0) score = 0;
        } catch (NumberFormatException e) {
            score = 0;
        }

        // 不允许管理员通过编辑表单降级自己
        HttpSession session = request.getSession(false);
        if (session != null) {
            @SuppressWarnings("unchecked")
            Map<String, Object> currentUser = (Map<String, Object>) session.getAttribute("user");
            if (currentUser != null && (int) currentUser.get("id") == id && !"admin".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/users/edit?id=" + id + "&error=self");
                return;
            }
        }

        String sql = "UPDATE users SET phone = ?, job_type = ?, job_location = ?, role = ?, score = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone == null ? "" : phone);
            ps.setString(2, jobType == null ? "" : jobType);
            ps.setString(3, jobLocation == null ? "" : jobLocation);
            ps.setString(4, role);
            ps.setInt(5, score);
            ps.setInt(6, id);
            ps.executeUpdate();
            LOG.info("用户信息已更新: id=" + id);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "更新用户信息失败, id=" + id, e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    /** 构建带参数的用户管理重定向 URL */
    private String buildUserRedirect(HttpServletRequest request) {
        String ctx = request.getContextPath();
        StringBuilder url = new StringBuilder(ctx + "/admin/users");
        String page = request.getParameter("refPage");
        String keyword = request.getParameter("refKeyword");
        boolean has = false;
        if (page != null && !page.isEmpty()) {
            url.append("?page=").append(page); has = true;
        }
        if (keyword != null && !keyword.isEmpty()) {
            url.append(has ? "&" : "?").append("keyword=").append(keyword);
        }
        return url.toString();
    }

    /** 切换用户角色 */
    private void handleToggleRole(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        // 不允许切换自己的角色
        HttpSession session = request.getSession(false);
        if (session != null) {
            @SuppressWarnings("unchecked")
            Map<String, Object> currentUser = (Map<String, Object>) session.getAttribute("user");
            if (currentUser != null && (int) currentUser.get("id") == id) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=self");
                return;
            }
        }

        // 读取当前角色
        String currentRole = null;
        String selectSql = "SELECT role FROM users WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentRole = rs.getString("role");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/users");
                    return;
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询用户角色失败, id=" + id, e);
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        // 切换角色
        String newRole = "user".equals(currentRole) ? "admin" : "user";
        String updateSql = "UPDATE users SET role = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setString(1, newRole);
            ps.setInt(2, id);
            ps.executeUpdate();
            LOG.info("用户角色已切换: id=" + id + ", " + currentRole + "→" + newRole);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "切换用户角色失败, id=" + id, e);
        }

        response.sendRedirect(buildUserRedirect(request));
    }

    /** 删除用户（事务性级联删除） */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        // 不允许删除自己
        HttpSession session = request.getSession(false);
        if (session != null) {
            @SuppressWarnings("unchecked")
            Map<String, Object> currentUser = (Map<String, Object>) session.getAttribute("user");
            if (currentUser != null && (int) currentUser.get("id") == id) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=self");
                return;
            }
        }

        // 事务性级联删除：从"叶子"表到"根"表，满足外键约束
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 活动/关联表（不被其他表引用）
            execUpdate(conn, "DELETE FROM post_likes WHERE user_id = ?", id);
            execUpdate(conn, "DELETE FROM post_favorites WHERE user_id = ?", id);
            execUpdate(conn, "DELETE FROM user_follows WHERE user_id = ? OR followed_user_id = ?", id, id);
            execUpdate(conn, "DELETE FROM notifications WHERE user_id = ?", id);
            execUpdate(conn, "DELETE FROM score_logs WHERE user_id = ?", id);
            execUpdate(conn, "DELETE FROM daily_checkins WHERE user_id = ?", id);
            execUpdate(conn, "DELETE FROM reports WHERE reporter_id = ? OR handler_id = ?", id, id);

            // 2. 需求相关
            execUpdate(conn, "DELETE FROM demand_replies WHERE user_id = ?", id);
            execUpdate(conn, "UPDATE demands SET is_deleted = 1 WHERE user_id = ?", id);
            // 需求软删除后移除 user_id 引用以满足 FK（设为已注销用户 id=1）
            execUpdate(conn, "UPDATE demands SET user_id = 1 WHERE user_id = ?", id);

            // 3. 回复：软删除并解除 user_id FK 引用
            execUpdate(conn, "UPDATE replies SET is_deleted = 1 WHERE user_id = ?", id);
            execUpdate(conn, "UPDATE replies SET user_id = 1 WHERE user_id = ?", id);

            // 4. 帖子：软删除并解除 user_id FK 引用
            execUpdate(conn, "UPDATE posts SET is_deleted = 1 WHERE user_id = ?", id);
            execUpdate(conn, "UPDATE posts SET user_id = 1 WHERE user_id = ?", id);

            // 5. 删除用户
            execUpdate(conn, "DELETE FROM users WHERE id = ?", id);

            conn.commit();
            LOG.info("用户已级联删除: id=" + id);
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOG.log(Level.WARNING, "回滚失败", ex); }
            }
            LOG.log(Level.SEVERE, "删除用户失败, id=" + id, e);
            response.sendRedirect(request.getContextPath() + "/admin/users?error=deleteFailed");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { /* ignore */ }
                try { conn.close(); } catch (SQLException e) { /* ignore */ }
            }
        }

        response.sendRedirect(buildUserRedirect(request));
    }

    /** 通用 SQL 更新辅助方法 */
    private void execUpdate(Connection conn, String sql, Object... params) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                if (params[i] instanceof Integer) {
                    ps.setInt(i + 1, (Integer) params[i]);
                } else {
                    ps.setString(i + 1, (String) params[i]);
                }
            }
            ps.executeUpdate();
        }
    }

    /** 统计用户数 */
    private int countUsers(String keyword) {
        String sql = (keyword != null)
                ? "SELECT COUNT(*) FROM users WHERE username LIKE ?"
                : "SELECT COUNT(*) FROM users";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (keyword != null) {
                ps.setString(1, "%" + keyword + "%");
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "统计用户数失败", e);
        }
        return 0;
    }

    /** 加载用户列表（分页） */
    private List<Map<String, Object>> loadUsers(int page, String keyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;

        String sql = "SELECT id, username, phone, job_type, job_location, role, score, created_at FROM users";
        if (keyword != null) {
            sql += " WHERE username LIKE ?";
        }
        sql += " ORDER BY created_at DESC, id DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (keyword != null) {
                ps.setString(idx++, "%" + keyword + "%");
            }
            ps.setInt(idx++, PAGE_SIZE);
            ps.setInt(idx, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(PostMapper.mapUserRow(rs));
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载用户列表失败", e);
        }
        return list;
    }

    /** 加载单个用户 */
    private Map<String, Object> loadUser(int id) {
        String sql = "SELECT id, username, phone, job_type, job_location, role, score, created_at FROM users WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return PostMapper.mapUserRow(rs);
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载用户失败, id=" + id, e);
        }
        return null;
    }
}
