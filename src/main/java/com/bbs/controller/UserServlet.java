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
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

/**
 * 用户控制器（组员B：用户系统）
 * 负责：登录、注册、退出
 *
 * 说明：
 * - 新注册/改密使用 BCrypt 加密存储
 * - 兼容历史明文密码：首次明文登录成功后自动升级为 BCrypt
 */
@WebServlet(name = "user", urlPatterns = {"/user/login", "/user/register", "/logout"})
public class UserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/logout".equals(path)) {
            request.getSession().invalidate();
            response.sendRedirect(request.getContextPath() + "/");
        } else if ("/user/login".equals(path)) {
            request.getRequestDispatcher("/user/login.jsp").forward(request, response);
        } else if ("/user/register".equals(path)) {
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if ("/user/login".equals(path)) {
            handleLogin(request, response);
        } else if ("/user/register".equals(path)) {
            handleRegister(request, response);
        }
    }

    /** 登录 */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "用户名和密码不能为空");
            request.getRequestDispatcher("/user/login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT id, username, password, role, phone, job_type, job_location, created_at " +
                "FROM users WHERE username = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    String storedPwd = rs.getString("password");

                    // BCrypt 校验 + 旧明文兼容（并自动升级为 BCrypt）
                    boolean ok = PasswordUtil.verifyAndUpgradeIfLegacy(conn, userId, password.trim(), storedPwd);
                    if (!ok) {
                        request.setAttribute("error", "用户名或密码错误");
                        request.getRequestDispatcher("/user/login.jsp").forward(request, response);
                        return;
                    }

                    Map<String, Object> user = new HashMap<>();
                    user.put("id", userId);
                    user.put("username", rs.getString("username"));
                    user.put("role", rs.getString("role"));
                    user.put("phone", rs.getString("phone") == null ? "" : rs.getString("phone"));
                    user.put("jobType", rs.getString("job_type") == null ? "" : rs.getString("job_type"));
                    user.put("jobLocation", rs.getString("job_location") == null ? "" : rs.getString("job_location"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    user.put("createdAt", createdAt == null ? "" : createdAt.toString());

                    HttpSession session = request.getSession();
                    // 防止 Session Fixation：登录成功后更换 SessionId
                    request.changeSessionId();
                    session.setAttribute("user", user);

                    response.sendRedirect(request.getContextPath() + "/");
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("error", "用户名或密码错误");
        request.getRequestDispatcher("/user/login.jsp").forward(request, response);
    }

    /** 注册 */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String password2 = request.getParameter("password2");
        String phone = request.getParameter("phone");
        String jobType = request.getParameter("jobType");
        String jobLocation = request.getParameter("jobLocation");

        // 校验
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "用户名和密码不能为空");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }
        if (!password.equals(password2)) {
            request.setAttribute("error", "两次输入的密码不一致");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        String sql = "INSERT INTO users (username, password, phone, job_type, job_location) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            // BCrypt hash 存储
            ps.setString(2, PasswordUtil.hash(password.trim()));
            ps.setString(3, phone == null ? "" : phone.trim());
            ps.setString(4, jobType == null ? "" : jobType.trim());
            ps.setString(5, jobLocation == null ? "" : jobLocation.trim());
            ps.executeUpdate();

            response.sendRedirect(request.getContextPath() + "/user/login?registered=1");
            return;
        } catch (SQLException e) {
            if (e.getSQLState().equals("23000")) {
                request.setAttribute("error", "用户名已存在");
            } else {
                request.setAttribute("error", "注册失败，请重试");
                e.printStackTrace();
            }
        }

        request.getRequestDispatcher("/user/register.jsp").forward(request, response);
    }
}
