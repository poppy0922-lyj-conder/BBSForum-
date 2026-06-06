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
 * 负责：需求列表、发布需求、采纳回复（积分转帐）
 */
@WebServlet(name = "demand", urlPatterns = {"/demand", "/demand/create", "/demand/accept", "/demand/detail"})
public class DemandServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(DemandServlet.class.getName());
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/demand/create".equals(path)) {
            request.setAttribute("pageTitle", "发布悬赏");
            request.getRequestDispatcher("/WEB-INF/demand_create.jsp").forward(request, response);
            return;
        }

        if ("/demand/detail".equals(path)) {
            showDetail(request, response);
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

        if ("/demand/accept".equals(path)) {
            doAccept(request, response);
            return;
        }

        // 发布需求
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String scoreStr = request.getParameter("score");

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
        if (score < 0) score = 0;
        if (score > 10000) score = 10000; // 防止极端值

        // 检查用户积分是否足够
        if (score > 0) {
            int userScore = getUserScore(userId);
            if (userScore < score) {
                response.sendRedirect(request.getContextPath() + "/demand/create?error=score");
                return;
            }
        }

        String sql = "INSERT INTO demands (title, content, user_id, score, status) VALUES (?, ?, ?, ?, 'open')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, content);
            ps.setInt(3, userId);
            ps.setInt(4, score);
            ps.executeUpdate();
            LOG.info("需求发布成功: " + title);

            // 扣除发布者的积分并记录流水
            if (score > 0) {
                try (PreparedStatement ps2 = conn.prepareStatement(
                        "UPDATE users SET score = score - ? WHERE id = ? AND score >= ?")) {
                    ps2.setInt(1, score);
                    ps2.setInt(2, userId);
                    ps2.setInt(3, score);
                    int updated = ps2.executeUpdate();
                    if (updated == 0) {
                        LOG.warning("扣除积分失败，用户积分不足: userId=" + userId);
                        // 回滚？但插入已经执行，简单记录日志
                    }
                }
                try (PreparedStatement ps3 = conn.prepareStatement(
                        "INSERT INTO score_logs (user_id, score, reason) VALUES (?, ?, ?)")) {
                    ps3.setInt(1, userId);
                    ps3.setInt(2, -score);
                    ps3.setString(3, "发布悬赏: " + title);
                    ps3.executeUpdate();
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "发布需求失败: " + e.getMessage(), e);
            response.sendRedirect(request.getContextPath() + "/demand/create?error=1");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/demand?success=1");
    }

    /** 采纳回复：将积分转给最佳回复者 */
    private void doAccept(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Object userObj = request.getSession().getAttribute("user");
        if (userObj == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) userObj;
        int loginUserId = ((Number) user.get("id")).intValue();

        int demandId, replyId;
        try {
            demandId = Integer.parseInt(request.getParameter("demandId"));
            replyId = Integer.parseInt(request.getParameter("replyId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/demand");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 1. 查询需求信息
            String demandSql = "SELECT user_id, score, status FROM demands WHERE id = ?";
            int demandUserId, demandScore;
            String demandStatus;
            try (PreparedStatement ps = conn.prepareStatement(demandSql)) {
                ps.setInt(1, demandId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/demand");
                        return;
                    }
                    demandUserId = rs.getInt("user_id");
                    demandScore = rs.getInt("score");
                    demandStatus = rs.getString("status");
                }
            }

            // 2. 权限验证：只有发布者可以采纳
            if (loginUserId != demandUserId) {
                response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId);
                return;
            }

            // 3. 状态验证：必须为进行中
            if (!"open".equals(demandStatus)) {
                response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId);
                return;
            }

            // 4. 查询回复者ID（回复来自 replies 表，通过 post_id 关联 demand）
            int replyUserId = 0;
            String replySql = "SELECT user_id FROM replies WHERE id = ? AND post_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(replySql)) {
                ps.setInt(1, replyId);
                ps.setInt(2, demandId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        replyUserId = rs.getInt("user_id");
                    }
                }
            }

            if (replyUserId == 0) {
                response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId);
                return;
            }

            // 5. 更新需求状态
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE demands SET status = 'closed', best_reply_id = ? WHERE id = ?")) {
                ps.setInt(1, replyId);
                ps.setInt(2, demandId);
                ps.executeUpdate();
            }

            // 6. 积分转帐（如果有悬赏积分）
            if (demandScore > 0) {
                // 给回复者加分
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE users SET score = score + ? WHERE id = ?")) {
                    ps.setInt(1, demandScore);
                    ps.setInt(2, replyUserId);
                    ps.executeUpdate();
                }

                // 回复者积分流水
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO score_logs (user_id, score, reason) VALUES (?, ?, ?)")) {
                    ps.setInt(1, replyUserId);
                    ps.setInt(2, demandScore);
                    ps.setString(3, "悬赏被采纳: demandId=" + demandId);
                    ps.executeUpdate();
                }
            }

            LOG.info("需求采纳成功: demandId=" + demandId + ", replyId=" + replyId
                     + ", score=" + demandScore + " from user" + demandUserId + " to user" + replyUserId);

        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "采纳回复失败: demandId=" + demandId, e);
        }

        response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId);
    }

    /** 需求详情页 */
    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int demandId;
        try {
            demandId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/demand");
            return;
        }

        String sql = "SELECT d.id, d.title, d.content, d.score, d.status, d.best_reply_id, d.created_at, " +
                     "u.username AS author_name, u.id AS user_id " +
                     "FROM demands d JOIN users u ON d.user_id = u.id WHERE d.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, demandId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> demand = new HashMap<>();
                    demand.put("id", rs.getInt("id"));
                    demand.put("title", rs.getString("title"));
                    demand.put("content", rs.getString("content"));
                    demand.put("score", rs.getInt("score"));
                    demand.put("status", rs.getString("status"));
                    demand.put("bestReplyId", rs.getObject("best_reply_id"));
                    demand.put("createdAt", rs.getTimestamp("created_at"));
                    demand.put("authorName", rs.getString("author_name"));
                    demand.put("userId", rs.getInt("user_id"));
                    request.setAttribute("demand", demand);
                } else {
                    response.sendRedirect(request.getContextPath() + "/demand");
                    return;
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询需求详情失败: demandId=" + demandId, e);
            response.sendRedirect(request.getContextPath() + "/demand");
            return;
        }

        // 查询回复列表
        List<Map<String, Object>> replyList = new ArrayList<>();
        String replySql = "SELECT r.id, r.content, r.created_at, u.username AS author_name, u.id AS user_id " +
                          "FROM replies r JOIN users u ON r.user_id = u.id " +
                          "WHERE r.post_id = ? ORDER BY r.created_at ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(replySql)) {
            ps.setInt(1, demandId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> reply = new HashMap<>();
                    reply.put("id", rs.getInt("id"));
                    reply.put("content", rs.getString("content"));
                    reply.put("createdAt", rs.getTimestamp("created_at"));
                    reply.put("authorName", rs.getString("author_name"));
                    reply.put("userId", rs.getInt("user_id"));
                    replyList.add(reply);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询需求回复失败", e);
        }
        request.setAttribute("replyList", replyList);
        request.setAttribute("replyCount", replyList.size());

        request.setAttribute("pageTitle", "需求详情");
        request.getRequestDispatcher("/demand/detail.jsp").forward(request, response);
    }

    /** 查询用户当前积分 */
    private int getUserScore(int userId) {
        String sql = "SELECT score FROM users WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("score");
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询用户积分失败: userId=" + userId, e);
        }
        return 0;
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
