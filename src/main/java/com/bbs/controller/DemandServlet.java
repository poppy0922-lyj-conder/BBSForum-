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
@WebServlet(name = "demand", urlPatterns = {"/demand", "/demand/create", "/demand/accept", "/demand/detail", "/demand/update", "/demand/reply"})
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

        if ("/demand/update".equals(path)) {
            showEditForm(request, response);
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

        if ("/demand/create".equals(path)) {
            createDemand(request, response);
        } else if ("/demand/accept".equals(path)) {
            acceptReply(request, response);
        } else if ("/demand/reply".equals(path)) {
            handleDemandReply(request, response);
        } else if ("/demand/update".equals(path)) {
            updateDemand(request, response);
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
        if (score <= 0) {
            response.sendRedirect(request.getContextPath() + "/demand/create?error=scorezero");
            return;
        }
        if (score > 10000) score = 10000;

        // 检查用户积分是否足够
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

            // 1. 插入需求
            String insertSql = "INSERT INTO demands (title, content, user_id, score, status) VALUES (?, ?, ?, ?, 'open')";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, title);
                ps.setString(2, content);
                ps.setInt(3, userId);
                ps.setInt(4, score);
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
            response.sendRedirect(request.getContextPath() + "/demand/create?error=publish_failed");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }

        response.sendRedirect(request.getContextPath() + "/demand?success=1");
    }

    /**
     * 需求回复 - 保存回复到 demand_replies 表
     */
    private void handleDemandReply(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object userObj = request.getSession().getAttribute("user");
        if (userObj == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) userObj;
        int userId = ((Number) user.get("id")).intValue();

        String content = request.getParameter("content");
        String demandIdStr = request.getParameter("demandId");

        if (content == null || content.trim().isEmpty() || demandIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/demand");
            return;
        }

        int demandId = Integer.parseInt(demandIdStr);

        String sql = "INSERT INTO demand_replies (content, user_id, demand_id) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, content.trim());
            ps.setInt(2, userId);
            ps.setInt(3, demandId);
            ps.executeUpdate();
            LOG.info("需求回复成功: demandId=" + demandId + ", 用户=" + user.get("username"));

            // 回复 +2 积分
            addScore(userId, 2, "回复需求");
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "需求回复失败, demandId=" + demandId, e);
        }

        response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId);
    }

    /** 采纳回复 - 给回复者增加积分并记录流水 */
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
            String replySql = "SELECT user_id FROM demand_replies WHERE id = ?";
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
            response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId + "&error=accept_failed");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }

        response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId + "&accepted=1");
    }

    /** 编辑表单：加载需求数据 */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int demandId;
        try {
            demandId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/demand");
            return;
        }

        // 验证登录
        Object userObj = request.getSession().getAttribute("user");
        if (userObj == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) userObj;
        int userId = ((Number) user.get("id")).intValue();

        String sql = "SELECT id, title, content, score, status, user_id FROM demands WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, demandId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // 验证：只有发布者可以编辑
                    if (rs.getInt("user_id") != userId) {
                        response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId);
                        return;
                    }
                    // 验证：只有进行中可编辑
                    if (!"open".equals(rs.getString("status"))) {
                        response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId);
                        return;
                    }
                    Map<String, Object> demand = new HashMap<>();
                    demand.put("id", rs.getInt("id"));
                    demand.put("title", rs.getString("title"));
                    demand.put("content", rs.getString("content"));
                    demand.put("score", rs.getInt("score"));
                    request.setAttribute("demand", demand);
                } else {
                    response.sendRedirect(request.getContextPath() + "/demand");
                    return;
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询需求编辑信息失败", e);
            response.sendRedirect(request.getContextPath() + "/demand");
            return;
        }

        request.setAttribute("pageTitle", "编辑需求");
        request.getRequestDispatcher("/WEB-INF/demand_edit.jsp").forward(request, response);
    }

    /** 保存编辑 */
    private void updateDemand(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int demandId;
        try {
            demandId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/demand");
            return;
        }

        Object userObj = request.getSession().getAttribute("user");
        if (userObj == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) userObj;
        int userId = ((Number) user.get("id")).intValue();

        String title = request.getParameter("title");
        String content = request.getParameter("content");

        String sql = "UPDATE demands SET title = ?, content = ? WHERE id = ? AND user_id = ? AND status = 'open'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, content);
            ps.setInt(3, demandId);
            ps.setInt(4, userId);
            int affected = ps.executeUpdate();
            if (affected == 0) {
                response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId + "&error=edit_failed");
                return;
            }
            LOG.info("需求编辑成功: demandId=" + demandId);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "编辑需求失败", e);
            response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId + "&error=edit_failed");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/demand/detail?id=" + demandId + "&updated=1");
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
                          "FROM demand_replies r JOIN users u ON r.user_id = u.id " +
                          "WHERE r.demand_id = ? ORDER BY r.created_at ASC";
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

    /** 给用户增加积分并写入流水（失败不影响主流程） */
    private void addScore(int userId, int score, String reason) {
        String sql1 = "UPDATE users SET score = score + ? WHERE id = ?";
        String sql2 = "INSERT INTO score_logs (user_id, score, reason) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sql1)) {
                ps.setInt(1, score);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql2)) {
                ps.setInt(1, userId);
                ps.setInt(2, score);
                ps.setString(3, reason);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "加分失败: userId=" + userId + ", score=" + score, e);
        }
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
        String sql = "SELECT d.id, d.title, d.content, d.score, d.status, d.created_at, d.user_id, " +
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
                    m.put("userId", rs.getInt("user_id"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载需求列表失败", e);
        }
        return list;
    }
}
