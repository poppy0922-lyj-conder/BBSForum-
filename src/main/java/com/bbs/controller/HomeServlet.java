package com.bbs.controller;

import com.bbs.util.ContentUtil;
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
 * 首页入口控制器
 * 负责：加载板块列表（存入 ServletContext 全局共享）、加载帖子列表（分页），转发到 index.jsp
 */
@WebServlet(name = "home", urlPatterns = {"/index", "/home"})
public class HomeServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(HomeServlet.class.getName());
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 加载板块列表到 ServletContext（全局共享，支持刷新）
        loadCategoriesIfNeeded(request);

        // 2. 获取当前页码
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

        // 3. 加载帖子列表（分页）
        int totalPosts = countPosts();
        int totalPages = (int) Math.ceil((double) totalPosts / PAGE_SIZE);
        if (page > totalPages && totalPages > 0) page = totalPages;
        List<Map<String, Object>> postList = loadPosts(page);

        request.setAttribute("postList", postList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("pageSize", PAGE_SIZE);

        // 4. 转发到首页模板
        request.getRequestDispatcher("/WEB-INF/home.jsp").forward(request, response);
    }

    /** 统计帖子总数 */
    private int countPosts() {
        String sql = "SELECT COUNT(*) FROM posts";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "统计帖子总数失败", e);
        }
        return 0;
    }

    /** 加载板块列表（存入 ServletContext，支持通过 ?refresh=1 强制刷新） */
    private void loadCategoriesIfNeeded(HttpServletRequest request) {
        String refresh = request.getParameter("refresh");
        boolean forceRefresh = "1".equals(refresh);

        if (!forceRefresh && getServletContext().getAttribute("categoryList") != null) {
            return;
        }

        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, name, description FROM categories ORDER BY sort_order";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(PostMapper.mapCategoryRow(rs));
            }
            LOG.info("板块列表已加载，共 " + list.size() + " 个板块");
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载板块列表失败", e);
        }
        getServletContext().setAttribute("categoryList", list);
    }

    /** 加载帖子列表（分页） */
    private List<Map<String, Object>> loadPosts(int page) {
        List<Map<String, Object>> list = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;
        String sql = "SELECT p.id, p.title, p.image_url, " +
                     "p.content AS summary, p.ai_summary, " +
                     "p.is_top, p.is_elite, p.view_count, p.like_count, p.favorite_count, p.created_at, " +
                     "u.username AS author_name, c.name AS category_name " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "ORDER BY p.is_top DESC, p.is_elite DESC, p.created_at DESC " +
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
            LOG.log(Level.SEVERE, "加载帖子列表失败", e);
        }
        return list;
    }
}
