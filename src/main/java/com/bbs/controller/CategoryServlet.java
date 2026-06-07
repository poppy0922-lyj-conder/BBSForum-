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
 * 板块展示控制器
 * 负责：按板块过滤帖子列表（分页），展示特定板块的帖子
 */
@WebServlet(name = "category", urlPatterns = "/category")
public class CategoryServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(CategoryServlet.class.getName());
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 获取板块ID参数（增加 NumberFormatException 校验）
        String categoryIdStr = request.getParameter("id");
        int categoryId;
        try {
            if (categoryIdStr == null || categoryIdStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/");
                return;
            }
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            LOG.warning("无效的板块ID参数: " + categoryIdStr);
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // 加载板块信息
        Map<String, Object> category = loadCategory(categoryId);
        if (category == null) {
            request.setAttribute("errorMessage", "板块不存在");
            request.getRequestDispatcher("/error/404.jsp").forward(request, response);
            return;
        }

        // 获取当前页码
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

        // 加载该板块的帖子列表（分页）
        int totalPosts = countPostsByCategory(categoryId);
        int totalPages = (int) Math.ceil((double) totalPosts / PAGE_SIZE);
        if (page > totalPages && totalPages > 0) page = totalPages;
        List<Map<String, Object>> posts = loadPostsByCategory(categoryId, page);

        // 设置请求属性
        request.setAttribute("currentCategory", category);
        request.setAttribute("postList", posts);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("pageSize", PAGE_SIZE);

        // 转发到首页模板
        request.getRequestDispatcher("/WEB-INF/home.jsp").forward(request, response);
    }

    /** 加载单个板块信息 */
    private Map<String, Object> loadCategory(int categoryId) {
        String sql = "SELECT id, name, description FROM categories WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, categoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return PostMapper.mapCategoryRow(rs);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载板块信息失败, categoryId=" + categoryId, e);
        }
        return null;
    }

    /** 统计指定板块帖子总数 */
    private int countPostsByCategory(int categoryId) {
        String sql = "SELECT COUNT(*) FROM posts WHERE category_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "统计板块帖子数失败, categoryId=" + categoryId, e);
        }
        return 0;
    }

    /** 加载指定板块的帖子列表（分页） */
    private List<Map<String, Object>> loadPostsByCategory(int categoryId, int page) {
        List<Map<String, Object>> list = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;
        String sql = "SELECT p.id, p.title, p.image_url, p.content AS summary, p.ai_summary, " +
                     "p.is_top, p.is_elite, p.view_count, p.like_count, p.favorite_count, p.created_at, " +
                     "u.username AS author_name, c.name AS category_name " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "WHERE p.category_id = ? " +
                     "ORDER BY p.is_top DESC, p.is_elite DESC, p.created_at DESC " +
                     "LIMIT ? OFFSET ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, categoryId);
            pstmt.setInt(2, PAGE_SIZE);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(PostMapper.mapPostRow(rs));
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载板块帖子列表失败, categoryId=" + categoryId, e);
        }
        return list;
    }
}
