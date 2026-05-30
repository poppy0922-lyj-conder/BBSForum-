package com.bbs.controller;

import com.bbs.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

/**
 * 帖子编辑控制器
 * 负责：帖子编辑和删除功能
 */
@WebServlet(name = "postEdit", urlPatterns = {"/post/edit", "/post/delete"})
public class PostEditServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getServletPath().equals("/post/edit")) {
            // 显示编辑表单
            int postId = Integer.parseInt(request.getParameter("id"));
            Map<String, Object> post = loadPost(postId);
            request.setAttribute("post", post);
            request.getRequestDispatcher("/WEB-INF/post/edit_content.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getServletPath();

        if (action.equals("/post/edit")) {
            // 保存编辑
            int postId = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));

            updatePost(postId, title, content, categoryId);
            response.sendRedirect(request.getContextPath() + "/post/" + postId);
        } else if (action.equals("/post/delete")) {
            // 删除帖子
            int postId = Integer.parseInt(request.getParameter("id"));
            deletePost(postId);
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    /** 加载帖子信息 */
    private Map<String, Object> loadPost(int postId) {
        String sql = "SELECT p.id, p.title, p.content, p.category_id, p.user_id, " +
                     "u.username AS author_name, c.name AS category_name " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "WHERE p.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    post.put("content", rs.getString("content"));
                    post.put("categoryId", rs.getInt("category_id"));
                    post.put("userId", rs.getInt("user_id"));
                    post.put("authorName", rs.getString("author_name"));
                    post.put("categoryName", rs.getString("category_name"));
                    return post;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /** 更新帖子内容 */
    private void updatePost(int postId, String title, String content, int categoryId) {
        String sql = "UPDATE posts SET title = ?, content = ?, category_id = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setInt(3, categoryId);
            pstmt.setInt(4, postId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /** 删除帖子 */
    private void deletePost(int postId) {
        String sql = "DELETE FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}