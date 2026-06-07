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
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

/**
 * 用户控制器（组员B：用户系统）
 * 负责：注册、登录、登出、每日签到、登录积分逻辑
 *
 * 说明：
 * - 新注册/改密使用 BCrypt 加密存储
 * - 兼容历史明文密码：首次明文登录成功后自动升级为 BCrypt
 * - 每日首次登录奖励 +2 积分
 * - 每日签到：连续签到 5~15 分逐步递增，断签重置为 5 分
 */
@WebServlet(name = "user", urlPatterns = {"/user/login", "/user/register", "/logout", "/user/checkin"})
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
        } else if ("/user/checkin".equals(path)) {
            handleCheckin(request, response);
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

        String sql = "SELECT id, username, password, role, phone, job_type, job_location, score, created_at " +
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
                    user.put("score", rs.getInt("score"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    user.put("createdAt", createdAt == null ? "" : createdAt.toString());

                    HttpSession session = request.getSession();
                    // 防止 Session Fixation：登录成功后更换 SessionId
                    request.changeSessionId();
                    session.setAttribute("user", user);

                    // 每日首次登录积分奖励
                    awardDailyLoginScore(conn, userId);

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
        if (username.trim().length() < 3 || username.trim().length() > 50) {
            request.setAttribute("error", "用户名长度需在 3-50 个字符之间");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }
        if (password.trim().length() < 6) {
            request.setAttribute("error", "密码长度至少 6 位");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }
        if (!password.equals(password2)) {
            request.setAttribute("error", "两次输入的密码不一致");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String sql = "INSERT INTO users (username, password, phone, job_type, job_location) VALUES (?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, username.trim());
            // BCrypt hash 存储
            ps.setString(2, PasswordUtil.hash(password.trim()));
            ps.setString(3, phone == null ? "" : phone.trim());
            ps.setString(4, jobType == null ? "" : jobType.trim());
            ps.setString(5, jobLocation == null ? "" : jobLocation.trim());
            ps.executeUpdate();

            // 获取新用户ID并写入注册积分流水
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int newUserId = rs.getInt(1);
                    insertScoreLog(conn, newUserId, 0, "新用户注册");
                }
            }

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/user/login?registered=1");
            return;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            if (e.getSQLState().equals("23000")) {
                request.setAttribute("error", "用户名已存在");
            } else {
                request.setAttribute("error", "注册失败，请重试");
                e.printStackTrace();
            }
        } finally {
            DBUtil.close(conn, ps, null);
        }

        request.getRequestDispatcher("/user/register.jsp").forward(request, response);
    }

    /** 每日首次登录积分奖励 */
    private void awardDailyLoginScore(Connection conn, int userId) throws SQLException {
        LocalDate today = LocalDate.now();
        // 检查今日是否已有登录奖励记录
        String checkSql = "SELECT id FROM score_logs WHERE user_id = ? AND reason = '每日首次登录奖励' AND DATE(created_at) = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(today));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return; // 今日已奖励
                }
            }
        }

        // 今日首次登录，奖励 +2 积分
        conn.setAutoCommit(false);
        try {
            // 更新用户积分
            try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET score = score + 2 WHERE id = ?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            // 写入积分流水
            insertScoreLog(conn, userId, 2, "每日首次登录奖励");
            conn.commit();
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }

    /** 每日签到处理 */
    private void handleCheckin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        Map<String, Object> user = session == null ? null : (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            out.print("{\"ok\":false,\"msg\":\"请先登录\"}");
            return;
        }

        int userId = (int) user.get("id");
        LocalDate today = LocalDate.now();

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 检查今日是否已签到
            String checkSql = "SELECT id FROM daily_checkins WHERE user_id = ? AND checkin_date = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setDate(2, Date.valueOf(today));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        out.print("{\"ok\":false,\"msg\":\"今日已签到\"}");
                        return;
                    }
                }
            }

            // 查询上次签到信息
            int consecutiveDays = 1;
            String lastSql = "SELECT checkin_date, consecutive_days FROM daily_checkins WHERE user_id = ? ORDER BY checkin_date DESC LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(lastSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Date lastDate = rs.getDate("checkin_date");
                        int lastConsecutive = rs.getInt("consecutive_days");
                        // 判断是否是连续签到（昨天）
                        if (lastDate != null && lastDate.toLocalDate().plusDays(1).equals(today)) {
                            consecutiveDays = lastConsecutive + 1;
                        }
                    }
                }
            }

            // 计算本次签到积分：5~15分逐步递增，封顶15分
            int scoreEarned = Math.min(5 + (consecutiveDays - 1), 15);

            // 插入签到记录
            String insertCheckinSql = "INSERT INTO daily_checkins (user_id, checkin_date, consecutive_days, score_earned) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertCheckinSql)) {
                ps.setInt(1, userId);
                ps.setDate(2, Date.valueOf(today));
                ps.setInt(3, consecutiveDays);
                ps.setInt(4, scoreEarned);
                ps.executeUpdate();
            }

            // 更新用户积分
            try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET score = score + ? WHERE id = ?")) {
                ps.setInt(1, scoreEarned);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            // 写入积分流水
            insertScoreLog(conn, userId, scoreEarned, "每日签到奖励");

            conn.commit();

            // 更新 session 中的积分
            int currentScore = (int) user.get("score");
            user.put("score", currentScore + scoreEarned);
            session.setAttribute("user", user);

            out.print("{\"ok\":true,\"score\":" + scoreEarned + ",\"consecutive\":" + consecutiveDays + "}");
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            out.print("{\"ok\":false,\"msg\":\"签到失败，请重试\"}");
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ex) { ex.printStackTrace(); }
                DBUtil.close(conn, null, null);
            }
        }
    }

    /** 写入积分流水 */
    private void insertScoreLog(Connection conn, int userId, int score, String reason) throws SQLException {
        String sql = "INSERT INTO score_logs (user_id, score, reason) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, score);
            ps.setString(3, reason);
            ps.executeUpdate();
        }
    }
}
