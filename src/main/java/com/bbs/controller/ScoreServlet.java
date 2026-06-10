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
     * 显示当前用户的积分记录（带分页）
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

        // 获取当前页码
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) page = 1;
        } catch (NumberFormatException ignored) {}

        int pageSize = 15;

        // 获取总记录数
        int totalCount = 0;
        String countSql = "SELECT COUNT(*) FROM score_logs WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(countSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalCount = rs.getInt(1);
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "查询积分总数失败", e);
        }

        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * pageSize;

        // 获取当前总积分
        int totalScore = 0;
        String scoreSql = "SELECT score FROM users WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(scoreSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalScore = rs.getInt("score");
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询用户积分失败", e);
        }

        // 分页查询积分流水记录
        List<Map<String, Object>> scoreLogs = new ArrayList<>();
        String logSql = "SELECT score, reason, created_at FROM score_logs WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(logSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, pageSize);
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
            LOG.log(Level.SEVERE, "查询积分流水失败", e);
        }

        // 构建分页 HTML
        String pagination = buildPagination(request.getContextPath() + "/score/record", page, totalPages, totalCount);

        request.setAttribute("totalScore", totalScore);
        request.setAttribute("scoreLogs", scoreLogs);
        request.setAttribute("pagination", pagination);
        request.setAttribute("pageTitle", "积分记录");
        request.getRequestDispatcher("/score/record.jsp").forward(request, response);
    }

    /** 构建分页 HTML */
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

    /**
     * 显示积分排行榜
     */
    private void showRank(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String, Object>> rankList = new ArrayList<>();

        String sql = "SELECT username, avatar, score FROM users ORDER BY score DESC LIMIT 100";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("username", rs.getString("username"));
                row.put("avatar", rs.getString("avatar"));
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