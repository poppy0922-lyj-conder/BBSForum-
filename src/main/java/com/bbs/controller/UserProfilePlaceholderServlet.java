package com.bbs.controller;

import com.bbs.util.DBUtil;
import com.bbs.util.PostMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 个人中心功能控制器（组员B）
 * 处理个人中心边栏菜单项：
 * - /user/profile/posts     发布帖子（查询当前用户发布的所有帖子）
 * - /user/profile/demands   我的悬赏（查询当前用户发布的所有悬赏）
 * - /user/profile/likes     我的点赞（查询当前用户点赞过的所有帖子）
 * - /user/profile/favorites 我的收藏（查询当前用户收藏过的所有帖子）
 */
@WebServlet(name = "userProfilePlaceholder", urlPatterns = {
    "/user/profile/posts",
    "/user/profile/demands",
    "/user/profile/likes",
    "/user/profile/favorites"
})
public class UserProfilePlaceholderServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(UserProfilePlaceholderServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Map<String, Object> sessionUser = session == null ? null : (Map<String, Object>) session.getAttribute("user");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int userId = (int) sessionUser.get("id");
        String path = request.getServletPath();

        // 加载最近积分记录（供边栏显示）
        List<Map<String, Object>> scoreLogs = loadScoreLogs(userId, 5);
        request.setAttribute("scoreLogs", scoreLogs);

        if ("/user/profile/posts".equals(path)) {
            List<Map<String, Object>> postList = loadMyPosts(userId);
            request.setAttribute("postList", postList);
            request.setAttribute("activeMenu", "posts");
            request.setAttribute("pageTitle", "发布帖子");
            request.getRequestDispatcher("/user/my_posts.jsp").forward(request, response);
        } else if ("/user/profile/demands".equals(path)) {
            List<Map<String, Object>> demandList = loadMyDemands(userId);
            request.setAttribute("demandList", demandList);
            request.setAttribute("activeMenu", "demands");
            request.setAttribute("pageTitle", "我的悬赏");
            request.getRequestDispatcher("/user/my_demands.jsp").forward(request, response);
        } else if ("/user/profile/likes".equals(path)) {
            List<Map<String, Object>> likeList = loadMyLikes(userId);
            request.setAttribute("likeList", likeList);
            request.setAttribute("activeMenu", "likes");
            request.setAttribute("pageTitle", "我的点赞");
            request.getRequestDispatcher("/user/my_likes.jsp").forward(request, response);
        } else if ("/user/profile/favorites".equals(path)) {
            List<Map<String, Object>> favoriteList = loadMyFavorites(userId);
            request.setAttribute("favoriteList", favoriteList);
            request.setAttribute("activeMenu", "favorites");
            request.setAttribute("pageTitle", "我的收藏");
            request.getRequestDispatcher("/user/my_favorites.jsp").forward(request, response);
        }
    }

    /** 查询当前用户发布的所有帖子 */
    private List<Map<String, Object>> loadMyPosts(int userId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.id, p.title, p.content AS summary, p.view_count, p.like_count, " +
                     "p.favorite_count, p.is_top, p.is_elite, p.created_at, " +
                     "c.name AS category_name, u.username AS author_name " +
                     "FROM posts p " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "JOIN users u ON p.user_id = u.id " +
                     "WHERE p.user_id = ? " +
                     "ORDER BY p.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    String raw = rs.getString("summary");
                    post.put("summary", raw == null ? "" : raw.substring(0, Math.min(raw.length(), 120)));
                    post.put("viewCount", rs.getInt("view_count"));
                    post.put("likeCount", rs.getInt("like_count"));
                    post.put("favoriteCount", rs.getInt("favorite_count"));
                    post.put("isTop", rs.getInt("is_top"));
                    post.put("isElite", rs.getInt("is_elite"));
                    post.put("createdAt", rs.getTimestamp("created_at").toString());
                    post.put("categoryName", rs.getString("category_name"));
                    post.put("authorName", rs.getString("author_name"));
                    list.add(post);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载我的帖子失败: userId=" + userId, e);
        }
        return list;
    }

    /** 查询当前用户发布的所有悬赏 */
    private List<Map<String, Object>> loadMyDemands(int userId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT d.id, d.title, d.content, d.score, d.status, d.created_at, " +
                     "(SELECT COUNT(*) FROM demand_replies dr WHERE dr.demand_id = d.id) AS reply_count " +
                     "FROM demands d WHERE d.user_id = ? ORDER BY d.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> demand = new HashMap<>();
                    demand.put("id", rs.getInt("id"));
                    demand.put("title", rs.getString("title"));
                    String raw = rs.getString("content");
                    demand.put("content", raw == null ? "" : raw.substring(0, Math.min(raw.length(), 120)));
                    demand.put("score", rs.getInt("score"));
                    demand.put("status", rs.getString("status"));
                    demand.put("replyCount", rs.getInt("reply_count"));
                    demand.put("createdAt", rs.getTimestamp("created_at").toString());
                    list.add(demand);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载我的悬赏失败: userId=" + userId, e);
        }
        return list;
    }

    /** 查询当前用户点赞过的所有帖子 */
    private List<Map<String, Object>> loadMyLikes(int userId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.id, p.title, p.content AS summary, p.view_count, " +
                     "p.like_count, p.favorite_count, p.created_at, " +
                     "c.name AS category_name, u.username AS author_name, l.created_at AS like_time " +
                     "FROM post_likes l " +
                     "JOIN posts p ON l.post_id = p.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "JOIN users u ON p.user_id = u.id " +
                     "WHERE l.user_id = ? " +
                     "ORDER BY l.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    String raw = rs.getString("summary");
                    post.put("summary", raw == null ? "" : raw.substring(0, Math.min(raw.length(), 120)));
                    post.put("viewCount", rs.getInt("view_count"));
                    post.put("likeCount", rs.getInt("like_count"));
                    post.put("favoriteCount", rs.getInt("favorite_count"));
                    post.put("createdAt", rs.getTimestamp("created_at").toString());
                    post.put("likeTime", rs.getTimestamp("like_time").toString());
                    post.put("categoryName", rs.getString("category_name"));
                    post.put("authorName", rs.getString("author_name"));
                    list.add(post);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载我的点赞失败: userId=" + userId, e);
        }
        return list;
    }

    /** 查询当前用户收藏过的所有帖子 */
    private List<Map<String, Object>> loadMyFavorites(int userId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.id, p.title, p.content AS summary, p.view_count, " +
                     "p.like_count, p.favorite_count, p.created_at, " +
                     "c.name AS category_name, u.username AS author_name, f.created_at AS fav_time " +
                     "FROM post_favorites f " +
                     "JOIN posts p ON f.post_id = p.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "JOIN users u ON p.user_id = u.id " +
                     "WHERE f.user_id = ? " +
                     "ORDER BY f.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    String raw = rs.getString("summary");
                    post.put("summary", raw == null ? "" : raw.substring(0, Math.min(raw.length(), 120)));
                    post.put("viewCount", rs.getInt("view_count"));
                    post.put("likeCount", rs.getInt("like_count"));
                    post.put("favoriteCount", rs.getInt("favorite_count"));
                    post.put("createdAt", rs.getTimestamp("created_at").toString());
                    post.put("favTime", rs.getTimestamp("fav_time").toString());
                    post.put("categoryName", rs.getString("category_name"));
                    post.put("authorName", rs.getString("author_name"));
                    list.add(post);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载我的收藏失败: userId=" + userId, e);
        }
        return list;
    }

    /** 加载用户最近积分记录 */
    private List<Map<String, Object>> loadScoreLogs(int userId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT score, reason, created_at FROM score_logs WHERE user_id = ? ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> log = new HashMap<>();
                    log.put("score", rs.getInt("score"));
                    log.put("reason", rs.getString("reason") == null ? "" : rs.getString("reason"));
                    log.put("createdAt", rs.getTimestamp("created_at"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "加载积分记录失败: userId=" + userId, e);
        }
        return list;
    }
}
