package com.bbs.controller;

import com.bbs.util.DBUtil;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 积分控制器（组员D）
 * 负责：积分记录、积分排行榜
 */
@WebServlet(name = "score", urlPatterns = {"/score", "/score/record", "/score/rank"})
public class ScoreServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(ScoreServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/score/record".equals(path)) {
            // 积分记录页面
            showRecord(request, response);
            return;
        }

        if ("/score/rank".equals(path)) {
            // 积分排行榜页面
            showRank(request, response);
            return;
        }

        // 默认重定向到排行榜
        response.sendRedirect(request.getContextPath() + "/score/rank");
    }

    /**
     * 显示当前用户的积分记录
     */
    private void showRecord(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        int userId = ((Number) user.get("id")).intValue();

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
            LOG.log(Level.SEVERE, "查询用户积分失败", e);
        }

        // 获取积分流水记录
        List<Map<String, Object>> scoreLogs = new ArrayList<>();
        String logSql = "SELECT score, reason, created_at FROM score_logs WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(logSql)) {
            ps.setInt(1, userId);
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
            LOG.log(Level.SEVERE, "查询积分流水失败", e);
        }

        request.setAttribute("totalScore", totalScore);
        request.setAttribute("scoreLogs", scoreLogs);
        request.setAttribute("pageTitle", "积分记录");
        request.getRequestDispatcher("/score/record.jsp").forward(request, response);
    }

    /**
     * 显示积分排行榜
     */
    private void showRank(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String, Object>> rankList = new ArrayList<>();

        String sql = "SELECT username, score FROM users ORDER BY score DESC LIMIT 100";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("username", rs.getString("username"));
                row.put("score", rs.getInt("score"));
                rankList.add(row);
            }

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载排行榜失败", e);
        }

        request.setAttribute("rankList", rankList);
        request.setAttribute("pageTitle", "积分排行");
        request.getRequestDispatcher("/score/rank.jsp").forward(request, response);
    }
}