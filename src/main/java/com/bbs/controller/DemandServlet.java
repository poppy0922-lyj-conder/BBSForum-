package com.bbs.controller;

import com.bbs.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 需求悬赏控制器
 */
@WebServlet(name = "demand", urlPatterns = {"/demand", "/demand/create", "/demand/accept"})
public class DemandServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(DemandServlet.class.getName());
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/demand/create".equals(path)) {
            // 创建需求页面
            request.setAttribute("pageTitle", "发布悬赏");
            request.getRequestDispatcher("/WEB-INF/demand_create.jsp").forward(request, response);
            return;
        }

        // 需求列表
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

        int total = countDemands();
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        if (page > totalPages && totalPages > 0) page = totalPages;
        List<Map<String, Object>> list = loadDemands(page);

        request.setAttribute("postList", list);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalPosts", total);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("pageTitle", "需求悬赏");
        request.setAttribute("demandActive", true);

        request.getRequestDispatcher("/WEB-INF/demand.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/demand/create".equals(path)) {
            // 发布需求
            createDemand(request, response);
        } else if ("/demand/accept".equals(path)) {
            // 采纳回复
            acceptReply(request, response);
        } else {
            response.sendError(404);
        }
    }

    /**
     * 发布需求 - 扣除积分并记录流水
     */
    private void createDemand(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String scoreStr = request.getParameter("score");
        String categoryIdStr = request.getParameter("categoryId");

        Object userObj = request.getSession().getAttribute("user");
        if (userObj == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) userObj;
        int userId = ((Number) user.get("id")).intValue();
        int score = 0;
        if (scoreStr != null && !scoreStr.isEmpty()) {
            try { score = Integer.parseInt(scoreStr); } catch (NumberFormatException e) { score = 0; }
        }

        int categoryId = 1; // 默认板块
        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            try { categoryId = Integer.parseInt(categoryIdStr); } catch (NumberFormatException e) { categoryId = 1; }
        }

        // 如果悬赏积分大于0，检查用户积分是否足够
        if (score > 0) {
            int currentScore = 0;
            String checkSql = "SELECT score FROM users WHERE id = ?";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentScore = rs.getInt("score");
                    }
                }
            } catch (SQLException e) {
                LOG.log(Level.SEVERE, "查询用户积分失败", e);
            }

            if (currentScore < score) {
                response.sendRedirect(request.getContextPath() + "/demand/create?error=jifenbuzu");
                return;
            }
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 插入需求（添加 category_id 字段）
            String insertSql = "INSERT INTO demands (title, content, user_id, category_id, score, status) VALUES (?, ?, ?, ?, ?, 'open')";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, title);
                ps.setString(2, content);
                ps.setInt(3, userId);
                ps.setInt(4, categoryId);
                ps.setInt(5, score);
                ps.executeUpdate();
            }

            // 2. 如果悬赏积分大于0，扣除积分并记录流水
            if (score > 0) {
                String deductSql = "UPDATE users SET score = score - ? WHERE id = ? AND score >= ?";
                try (PreparedStatement ps = conn.prepareStatement(deductSql)) {
                    ps.setInt(1, score);
                    ps.setInt(2, userId);
                    ps.setInt(3, score);
                    int affected = ps.executeUpdate();
                    if (affected == 0) {
                        throw new SQLException("积分扣除失败");
                    }
                }

                String logSql = "INSERT INTO score_logs (user_id, score, reason) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, -score);
                    ps.setString(3, "发布悬赏需求，支出 " + score + " 积分");
                    ps.executeUpdate();
                }
            }

            conn.commit();
            LOG.info("需求发布成功: " + title + "，支出积分: " + score);

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            LOG.log(Level.SEVERE, "发布需求失败: " + e.getMessage(), e);
            response.sendRedirect(request.getContextPath() + "/demand/create?error=发布失败");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }

        response.sendRedirect(request.getContextPath() + "/demand?success=1");
    }

    /**
     * 采纳回复 - 给回复者增加积分并记录流水
     */
    private void acceptReply(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Object userObj = request.getSession().getAttribute("user");
        if (userObj == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) userObj;
        int currentUserId = ((Number) user.get("id")).intValue();

        String demandIdStr = request.getParameter("demandId");
        String replyIdStr = request.getParameter("replyId");

        if (demandIdStr == null || replyIdStr == null) {
            response.sendError(400, "参数错误");
            return;
        }

        int demandId = Integer.parseInt(demandIdStr);
        int replyId = Integer.parseInt(replyIdStr);

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 查询需求信息（加锁）
            int demandUserId = 0;
            int demandScore = 0;
            String demandStatus = "";
            String checkSql = "SELECT user_id, score, status FROM demands WHERE id = ? FOR UPDATE";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, demandId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        demandUserId = rs.getInt("user_id");
                        demandScore = rs.getInt("score");
                        demandStatus = rs.getString("status");
                    } else {
                        throw new SQLException("需求不存在");
                    }
                }
            }

            // 验证权限：只有发布者可以采纳
            if (currentUserId != demandUserId) {
                throw new SQLException("只有需求发布者可以采纳");
            }

            // 验证状态：只有进行中的需求可以采纳
            if (!"open".equals(demandStatus)) {
                throw new SQLException("需求已结束");
            }

            // 2. 查询回复作者
            int replyUserId = 0;
            String replySql = "SELECT user_id FROM replies WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(replySql)) {
                ps.setInt(1, replyId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        replyUserId = rs.getInt("user_id");
                    } else {
                        throw new SQLException("回复不存在");
                    }
                }
            }

            // 不能采纳自己的回复
            if (replyUserId == currentUserId) {
                throw new SQLException("不能采纳自己的回复");
            }

            // 3. 给回复者增加积分
            if (demandScore > 0) {
                String addSql = "UPDATE users SET score = score + ? WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(addSql)) {
                    ps.setInt(1, demandScore);
                    ps.setInt(2, replyUserId);
                    ps.executeUpdate();
                }

                // 记录积分流水（正数表示获得）
                String logSql = "INSERT INTO score_logs (user_id, score, reason) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                    ps.setInt(1, replyUserId);
                    ps.setInt(2, demandScore);
                    ps.setString(3, "回复被采纳，获得悬赏 " + demandScore + " 积分");
                    ps.executeUpdate();
                }
            }

            // 4. 更新需求状态为已关闭
            String updateSql = "UPDATE demands SET status = 'closed', best_reply_id = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, replyId);
                ps.setInt(2, demandId);
                ps.executeUpdate();
            }

            conn.commit();
            LOG.info("采纳回复成功: demandId=" + demandId + ", replyId=" + replyId + ", 增加积分=" + demandScore);

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            LOG.log(Level.SEVERE, "采纳回复失败: " + e.getMessage(), e);
            response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId + "&error=" + e.getMessage());
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }

        response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId + "&accepted=1");
    }

    private int countDemands() {
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM demands")) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "统计需求数失败", e);
            return 0;
        }
    }

    private List<Map<String, Object>> loadDemands(int page) {
        List<Map<String, Object>> list = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;
        String sql = "SELECT d.id, d.title, d.content, d.score, d.status, d.created_at, " +
                "u.username AS author_name " +
                "FROM demands d JOIN users u ON d.user_id = u.id " +
                "ORDER BY d.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, PAGE_SIZE);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("title", rs.getString("title"));
                    m.put("content", rs.getString("content"));
                    m.put("score", rs.getInt("score"));
                    m.put("status", rs.getString("status"));
                    m.put("createdAt", rs.getObject("created_at"));
                    m.put("authorName", rs.getString("author_name"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载需求列表失败", e);
        }
        return list;
    }
}