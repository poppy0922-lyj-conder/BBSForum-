package com.bbs.controller;

import com.bbs.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 用户交互控制器 - 关注/点赞/收藏
 * 所有操作均需登录
 */
@WebServlet(name = "interact", urlPatterns = {"/interact/follow", "/interact/like", "/interact/favorite"})
public class InteractionServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(InteractionServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=utf-8");

        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) request.getSession().getAttribute("user");
        if (user == null) {
            response.getWriter().write("{\"ok\":false,\"msg\":\"请先登录\"}");
            return;
        }
        int userId = ((Number) user.get("id")).intValue();
        String path = request.getServletPath();

        try {
            switch (path) {
                case "/interact/follow":  doFollow(request, response, userId);  break;
                case "/interact/like":    doLike(request, response, userId);    break;
                case "/interact/favorite":doFavorite(request, response, userId);break;
            }
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "交互操作失败", e);
            response.getWriter().write("{\"ok\":false,\"msg\":\"操作失败\"}");
        }
    }

    /** 关注/取消关注 */
    private void doFollow(HttpServletRequest request, HttpServletResponse response, int userId)
            throws Exception {
        int followedId = Integer.parseInt(request.getParameter("userId"));
        if (userId == followedId) {
            response.getWriter().write("{\"ok\":false,\"msg\":\"不能关注自己\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 检查是否已关注
            boolean followed = exists(conn, "SELECT id FROM user_follows WHERE user_id=? AND followed_user_id=?",
                    userId, followedId);
            if (followed) {
                // 取消关注
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM user_follows WHERE user_id=? AND followed_user_id=?")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, followedId);
                    ps.executeUpdate();
                }
                response.getWriter().write("{\"ok\":true,\"action\":\"unfollow\"}");
            } else {
                // 关注
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO user_follows (user_id, followed_user_id) VALUES (?, ?)")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, followedId);
                    ps.executeUpdate();
                }
                response.getWriter().write("{\"ok\":true,\"action\":\"follow\"}");
            }
        }
    }

    /** 点赞/取消点赞 */
    private void doLike(HttpServletRequest request, HttpServletResponse response, int userId)
            throws Exception {
        int postId = Integer.parseInt(request.getParameter("postId"));
        try (Connection conn = DBUtil.getConnection()) {
            boolean liked = exists(conn, "SELECT id FROM post_likes WHERE user_id=? AND post_id=?",
                    userId, postId);
            if (liked) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM post_likes WHERE user_id=? AND post_id=?")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, postId);
                    ps.executeUpdate();
                }
                updateCount(conn, "UPDATE posts SET like_count = like_count - 1 WHERE id=? AND like_count>0", postId);
                int count = getCount(conn, "SELECT like_count FROM posts WHERE id=?", postId);
                response.getWriter().write("{\"ok\":true,\"action\":\"unlike\",\"count\":" + count + "}");
            } else {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO post_likes (user_id, post_id) VALUES (?, ?)")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, postId);
                    ps.executeUpdate();
                }
                updateCount(conn, "UPDATE posts SET like_count = like_count + 1 WHERE id=?", postId);
                int count = getCount(conn, "SELECT like_count FROM posts WHERE id=?", postId);
                response.getWriter().write("{\"ok\":true,\"action\":\"like\",\"count\":" + count + "}");
            }
        }
    }

    /** 收藏/取消收藏 */
    private void doFavorite(HttpServletRequest request, HttpServletResponse response, int userId)
            throws Exception {
        int postId = Integer.parseInt(request.getParameter("postId"));
        try (Connection conn = DBUtil.getConnection()) {
            boolean favorited = exists(conn, "SELECT id FROM post_favorites WHERE user_id=? AND post_id=?",
                    userId, postId);
            if (favorited) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM post_favorites WHERE user_id=? AND post_id=?")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, postId);
                    ps.executeUpdate();
                }
                updateCount(conn, "UPDATE posts SET favorite_count = favorite_count - 1 WHERE id=? AND favorite_count>0", postId);
                int count = getCount(conn, "SELECT favorite_count FROM posts WHERE id=?", postId);
                response.getWriter().write("{\"ok\":true,\"action\":\"unfavorite\",\"count\":" + count + "}");
            } else {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO post_favorites (user_id, post_id) VALUES (?, ?)")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, postId);
                    ps.executeUpdate();
                }
                updateCount(conn, "UPDATE posts SET favorite_count = favorite_count + 1 WHERE id=?", postId);
                int count = getCount(conn, "SELECT favorite_count FROM posts WHERE id=?", postId);
                response.getWriter().write("{\"ok\":true,\"action\":\"favorite\",\"count\":" + count + "}");
            }
        }
    }

    private boolean exists(Connection conn, String sql, int p1, int p2) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p1);
            ps.setInt(2, p2);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void updateCount(Connection conn, String sql, int postId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ps.executeUpdate();
        }
    }

    private int getCount(Connection conn, String sql, int postId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
