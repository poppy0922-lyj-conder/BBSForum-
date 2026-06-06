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

/**
 * 用户个人中心
 * - /user/profile      个人信息展示
 * - /user/profile/edit 资料编辑（可选改密）
 */
@WebServlet(name = "userProfile", urlPatterns = {"/user/profile", "/user/profile/edit", "/user/profile/follows"})
public class UserProfileServlet extends HttpServlet {

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
            // 用户不存在：清 session，跳登录
            if (session != null) session.invalidate();
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        request.setAttribute("user", user);

        if ("/user/profile".equals(path)) {
            if ("1".equals(request.getParameter("updated"))) {
                request.setAttribute("message", "资料已更新");
            }
            request.getRequestDispatcher("/user/profile.jsp").forward(request, response);
        } else if ("/user/profile/edit".equals(path)) {
            request.getRequestDispatcher("/user/profile_edit.jsp").forward(request, response);
        } else if ("/user/profile/follows".equals(path)) {
            List<Map<String, Object>> followList = loadFollows(userId);
            request.setAttribute("followList", followList);
            request.getRequestDispatcher("/user/follows.jsp").forward(request, response);
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

        // 校验：新密码非空则要求两次一致
        if (password != null && !password.trim().isEmpty()) {
            if (password2 == null || !password.trim().equals(password2.trim())) {
                request.setAttribute("error", "两次输入的新密码不一致");
                Map<String, Object> user = loadUserById(userId);
                request.setAttribute("user", user);
                request.getRequestDispatcher("/user/profile_edit.jsp").forward(request, response);
                return;
            }
        }

        try (Connection conn = DBUtil.getConnection()) {
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
            e.printStackTrace();
            request.setAttribute("error", "保存失败，请重试");
            Map<String, Object> user = loadUserById(userId);
            request.setAttribute("user", user);
            request.getRequestDispatcher("/user/profile_edit.jsp").forward(request, response);
            return;
        }

        // 刷新 session user（避免导航栏/回显信息滞后）
        Map<String, Object> fresh = loadUserById(userId);
        if (fresh != null) {
            session.setAttribute("user", fresh);
        }

        response.sendRedirect(request.getContextPath() + "/user/profile?updated=1");
    }

    /** 从数据库加载用户信息（用于个人中心展示/回显） */
    private Map<String, Object> loadUserById(int userId) {
        String sql = "SELECT id, username, role, phone, job_type, job_location, created_at FROM users WHERE id = ?";
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
}

