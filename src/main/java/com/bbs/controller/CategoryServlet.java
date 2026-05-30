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

/**
 * 板块展示控制器
 * 负责：按板块过滤帖子列表，展示特定板块的帖子
 */
@WebServlet(name = "category", urlPatterns = "/category")
public class CategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 获取板块ID参数
        String categoryIdStr = request.getParameter("id");
        if (categoryIdStr == null || categoryIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        int categoryId = Integer.parseInt(categoryIdStr);

        // 加载板块信息
        Map<String, Object> category = loadCategory(categoryId);
        if (category == null) {
            request.setAttribute("errorMessage", "板块不存在");
            request.getRequestDispatcher("/error/404.jsp").forward(request, response);
            return;
        }

        // 加载该板块的帖子列表
        List<Map<String, Object>> posts = loadPostsByCategory(categoryId);

        // 设置请求属性
        request.setAttribute("currentCategory", category);
        request.setAttribute("postList", posts);

        // 转发到首页模板（使用相同的home.jsp，但传入category过滤）
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
                    Map<String, Object> category = new HashMap<>();
                    category.put("id", rs.getInt("id"));
                    category.put("name", rs.getString("name"));
                    category.put("description", rs.getString("description"));
                    return category;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /** 加载指定板块的帖子列表 */
    private List<Map<String, Object>> loadPostsByCategory(int categoryId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.id, p.title, p.image_url, SUBSTRING(p.content, 1, 120) AS summary, " +
                     "p.is_top, p.is_elite, p.view_count, p.created_at, " +
                     "u.username AS author_name, c.name AS category_name " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "WHERE p.category_id = ? " +
                     "ORDER BY p.is_top DESC, p.is_elite DESC, p.created_at DESC " +
                     "LIMIT 20";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, categoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    post.put("summary", rs.getString("summary") == null ? "" : rs.getString("summary"));
                    post.put("isTop", rs.getInt("is_top"));
                    post.put("isElite", rs.getInt("is_elite"));
                    post.put("viewCount", rs.getInt("view_count"));
                    post.put("createdAt", rs.getTimestamp("created_at").toString());
                    post.put("authorName", rs.getString("author_name"));
                    post.put("categoryName", rs.getString("category_name"));
                    post.put("imageUrl", rs.getString("image_url") == null ? "" : rs.getString("image_url"));
                    list.add(post);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}