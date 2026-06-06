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
@WebServlet(name = "demand", urlPatterns = {"/demand", "/demand/create"})
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

        String sql = "INSERT INTO demands (title, content, user_id, score, status) VALUES (?, ?, ?, ?, 'open')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, content);
            ps.setInt(3, userId);
            ps.setInt(4, score);
            ps.executeUpdate();
            LOG.info("需求发布成功: " + title);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "发布需求失败: " + e.getMessage(), e);
            response.sendRedirect(request.getContextPath() + "/demand/create?error=1");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/demand?success=1");
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
