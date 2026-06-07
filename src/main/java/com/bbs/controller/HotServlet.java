package com.bbs.controller;

import com.bbs.util.DBUtil;
import com.bbs.util.PostMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 热搜榜控制器
 * 按浏览量降序展示热门帖子
 */
@WebServlet(name = "hot", urlPatterns = {"/hot"})
public class HotServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(HotServlet.class.getName());
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        int totalPosts = countHotPosts();
        int totalPages = (int) Math.ceil((double) totalPosts / PAGE_SIZE);
        if (page > totalPages && totalPages > 0) page = totalPages;
        List<Map<String, Object>> postList = loadHotPosts(page);

        request.setAttribute("postList", postList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("pageSize", PAGE_SIZE);

        request.getRequestDispatcher("/WEB-INF/hot.jsp").forward(request, response);
    }

    private int countHotPosts() {
        String sql = "SELECT COUNT(*) FROM posts";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "统计热门帖子总数失败", e);
        }
        return 0;
    }

    private List<Map<String, Object>> loadHotPosts(int page) {
        List<Map<String, Object>> list = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;
        String sql = "SELECT p.id, p.title, p.image_url, " +
                     "p.content AS summary, p.ai_summary, " +
                     "p.is_top, p.is_elite, p.view_count, p.like_count, p.favorite_count, p.created_at, " +
                     "u.username AS author_name, c.name AS category_name " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "ORDER BY p.view_count DESC, p.created_at DESC " +
                     "LIMIT ? OFFSET ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, PAGE_SIZE);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(PostMapper.mapPostRow(rs));
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载热门帖子列表失败", e);
        }
        return list;
    }
}
