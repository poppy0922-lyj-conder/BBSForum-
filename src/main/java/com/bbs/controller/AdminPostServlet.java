package com.bbs.controller;

import com.bbs.util.DBUtil;
import com.bbs.util.PostMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 管理员帖子管理控制器
 *
 * URL映射：
 *   GET  /admin/post/manage  — 帖子管理列表（分页+搜索+排序）
 *   POST /admin/post/top     — 切换置顶状态（0→1→2→0 循环）
 *   POST /admin/post/elite   — 切换加精状态（0→1→0 切换）
 */
@WebServlet(name = "adminPost", urlPatterns = {"/admin/post/manage", "/admin/post/top", "/admin/post/elite"})
public class AdminPostServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(AdminPostServlet.class.getName());
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/admin/post/manage".equals(path)) {
            handleManage(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/admin/post/top".equals(path)) {
            handleToggleTop(request, response);
        } else if ("/admin/post/elite".equals(path)) {
            handleToggleElite(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin");
        }
    }

    /** 帖子管理列表（分页+搜索+排序） */
    private void handleManage(HttpServletRequest request, HttpServletResponse response)
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

        String keyword = request.getParameter("keyword");
        if (keyword != null) {
            keyword = keyword.trim();
            if (keyword.isEmpty()) keyword = null;
        }

        String author = request.getParameter("author");
        if (author != null) {
            author = author.trim();
            if (author.isEmpty()) author = null;
        }

        String categoryIdStr = request.getParameter("categoryId");
        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (NumberFormatException e) {
                categoryId = null;
            }
        }

        String sort = request.getParameter("sort");
        if (!"desc".equals(sort)) {
            sort = "asc";
        }

        int totalPosts = countPosts(keyword, author, categoryId);
        int totalPages = (int) Math.ceil((double) totalPosts / PAGE_SIZE);
        if (page > totalPages && totalPages > 0) page = totalPages;

        List<Map<String, Object>> postList = loadPosts(page, keyword, author, categoryId, sort);

        // 加载板块列表供筛选下拉框使用
        List<Map<String, Object>> categoryList = loadCategories();

        request.setAttribute("postList", postList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("keyword", keyword);
        request.setAttribute("author", author);
        request.setAttribute("categoryId", categoryId);
        request.setAttribute("sort", sort);
        request.setAttribute("categoryList", categoryList);

        request.getRequestDispatcher("/admin/post_manage.jsp").forward(request, response);
    }

    /** 切换置顶状态：0 → 1（板块置顶）→ 2（全局置顶）→ 0 循环 */
    private void handleToggleTop(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/post/manage");
            return;
        }

        int currentTop = 0;
        String selectSql = "SELECT is_top FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentTop = rs.getInt("is_top");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/post/manage");
                    return;
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询置顶状态失败, postId=" + postId, e);
            response.sendRedirect(request.getContextPath() + "/admin/post/manage");
            return;
        }

        int newTop = (currentTop + 1) % 3;
        String updateSql = "UPDATE posts SET is_top = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setInt(1, newTop);
            ps.setInt(2, postId);
            ps.executeUpdate();
            LOG.info("置顶状态已切换: postId=" + postId + ", " + currentTop + "→" + newTop);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "切换置顶状态失败, postId=" + postId, e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/post/manage");
    }

    /** 切换加精状态：0 ↔ 1 */
    private void handleToggleElite(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/post/manage");
            return;
        }

        int currentElite = 0;
        String selectSql = "SELECT is_elite FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentElite = rs.getInt("is_elite");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/post/manage");
                    return;
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询加精状态失败, postId=" + postId, e);
            response.sendRedirect(request.getContextPath() + "/admin/post/manage");
            return;
        }

        int newElite = (currentElite == 1) ? 0 : 1;
        String updateSql = "UPDATE posts SET is_elite = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setInt(1, newElite);
            ps.setInt(2, postId);
            ps.executeUpdate();
            LOG.info("加精状态已切换: postId=" + postId + ", " + currentElite + "→" + newElite);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "切换加精状态失败, postId=" + postId, e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/post/manage");
    }

    /** 统计帖子数（支持搜索） */
    private int countPosts(String keyword, String author, Integer categoryId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM posts p JOIN users u ON p.user_id = u.id JOIN categories c ON p.category_id = c.id WHERE 1=1");
        if (keyword != null) {
            sql.append(" AND (p.title LIKE ? OR p.content LIKE ?)");
        }
        if (author != null) {
            sql.append(" AND u.username LIKE ?");
        }
        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null) {
                ps.setString(idx++, "%" + keyword + "%");
                ps.setString(idx++, "%" + keyword + "%");
            }
            if (author != null) {
                ps.setString(idx++, "%" + author + "%");
            }
            if (categoryId != null) {
                ps.setInt(idx, categoryId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "统计帖子总数失败", e);
        }
        return 0;
    }

    /** 加载帖子列表（分页+搜索+排序） */
    private List<Map<String, Object>> loadPosts(int page, String keyword, String author, Integer categoryId, String sort) {
        List<Map<String, Object>> list = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;

        StringBuilder sql = new StringBuilder(
            "SELECT p.id, p.title, p.image_url, p.content AS summary, p.ai_summary, " +
            "p.is_top, p.is_elite, p.view_count, p.created_at, " +
            "u.username AS author_name, c.name AS category_name " +
            "FROM posts p " +
            "JOIN users u ON p.user_id = u.id " +
            "JOIN categories c ON p.category_id = c.id WHERE 1=1"
        );
        if (keyword != null) {
            sql.append(" AND (p.title LIKE ? OR p.content LIKE ?)");
        }
        if (author != null) {
            sql.append(" AND u.username LIKE ?");
        }
        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
        }
        sql.append(" ORDER BY p.id ").append("desc".equals(sort) ? "DESC" : "ASC");
        sql.append(" LIMIT ? OFFSET ?");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null) {
                ps.setString(idx++, "%" + keyword + "%");
                ps.setString(idx++, "%" + keyword + "%");
            }
            if (author != null) {
                ps.setString(idx++, "%" + author + "%");
            }
            if (categoryId != null) {
                ps.setInt(idx++, categoryId);
            }
            ps.setInt(idx++, PAGE_SIZE);
            ps.setInt(idx, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(PostMapper.mapPostRow(rs));
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载帖子管理列表失败", e);
        }
        return list;
    }

    /** 加载板块列表（供筛选使用） */
    private List<Map<String, Object>> loadCategories() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, name FROM categories ORDER BY sort_order";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> cat = new java.util.HashMap<>();
                cat.put("id", rs.getInt("id"));
                cat.put("name", rs.getString("name"));
                list.add(cat);
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载板块列表失败", e);
        }
        return list;
    }
}
