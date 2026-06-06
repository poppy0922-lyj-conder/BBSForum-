package com.bbs.controller;

import com.bbs.util.AiUtil;
import com.bbs.util.ContentUtil;
import com.bbs.util.DBUtil;
import com.bbs.util.PostMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 帖子控制器
 * 负责：查看帖子详情、发布帖子、回复帖子（支持本地上传封面图）
 */
@WebServlet(name = "post", urlPatterns = {"/post/create", "/post/detail", "/post/reply", "/post/edit", "/post/delete", "/post/uploadImage", "/post/aiSummary", "/post/search"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, location = "")
public class PostServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(PostServlet.class.getName());
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/post/create".equals(path)) {
            handleCreateForm(request, response);
        } else if ("/post/detail".equals(path)) {
            handleDetail(request, response);
        } else if ("/post/edit".equals(path)) {
            handleEditForm(request, response);
        } else if ("/post/delete".equals(path)) {
            handleDelete(request, response);
        } else if ("/post/search".equals(path)) {
            handleSearch(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/post/create".equals(path)) {
            handleCreatePost(request, response);
        } else if ("/post/reply".equals(path)) {
            handleReply(request, response);
        } else if ("/post/edit".equals(path)) {
            handleEditPost(request, response);
        } else if ("/post/uploadImage".equals(path)) {
            handleInlineImageUpload(request, response);
        } else if ("/post/aiSummary".equals(path)) {
            handleAiSummary(request, response);
        }
    }

    /** 显示发帖表单（需登录） */
    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        request.getRequestDispatcher("/post/create.jsp").forward(request, response);
    }

    /** 查看帖子详情（任何人可看） */
    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        int postId;
        try {
            postId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // 1. 浏览量+1
        String updateSql = "UPDATE posts SET view_count = view_count + 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setInt(1, postId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "更新浏览量失败, postId=" + postId, e);
        }

        // 2. 查询帖子
        String postSql = "SELECT p.id, p.title, p.content, p.image_url, p.ai_summary, p.is_top, p.is_elite, " +
                         "p.keywords, p.view_count, p.like_count, p.favorite_count, p.user_id, p.category_id, p.created_at, p.updated_at, " +
                         "u.username AS author_name, c.name AS category_name " +
                         "FROM posts p " +
                         "JOIN users u ON p.user_id = u.id " +
                         "JOIN categories c ON p.category_id = c.id " +
                         "WHERE p.id = ?";
        Map<String, Object> post = null;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(postSql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    post.put("content", rs.getString("content"));
                    post.put("imageUrl", rs.getString("image_url") == null ? "" : rs.getString("image_url"));
                    post.put("aiSummary", rs.getString("ai_summary") == null ? "" : rs.getString("ai_summary"));
                    post.put("keywords", rs.getString("keywords") == null ? "" : rs.getString("keywords"));
                    post.put("isTop", rs.getInt("is_top"));
                    post.put("isElite", rs.getInt("is_elite"));
                    post.put("viewCount", rs.getInt("view_count"));
                    post.put("likeCount", rs.getInt("like_count"));
                    post.put("favoriteCount", rs.getInt("favorite_count"));
                    post.put("userId", rs.getInt("user_id"));
                    post.put("categoryId", rs.getInt("category_id"));
                    post.put("createdAt", rs.getTimestamp("created_at").toString());
                    post.put("authorName", rs.getString("author_name"));
                    post.put("categoryName", rs.getString("category_name"));
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询帖子详情失败, postId=" + postId, e);
        }

        if (post == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        post.put("contentRendered", ContentUtil.render((String) post.get("content")));
        request.setAttribute("post", post);

        // 查询当前登录用户的交互状态（点赞、收藏、关注）
        Map<String, Object> sessionUser = (Map<String, Object>) request.getSession().getAttribute("user");
        if (sessionUser != null) {
            int loginUserId = ((Number) sessionUser.get("id")).intValue();
            int authorId = (int) post.get("userId");
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT (SELECT COUNT(*) FROM post_likes WHERE user_id=? AND post_id=?) AS liked, " +
                     "(SELECT COUNT(*) FROM post_favorites WHERE user_id=? AND post_id=?) AS favorited, " +
                     "(SELECT COUNT(*) FROM user_follows WHERE user_id=? AND followed_user_id=?) AS followed")) {
                ps.setInt(1, loginUserId); ps.setInt(2, postId);
                ps.setInt(3, loginUserId); ps.setInt(4, postId);
                ps.setInt(5, loginUserId); ps.setInt(6, authorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("userLiked", rs.getInt("liked") > 0);
                        request.setAttribute("userFavorited", rs.getInt("favorited") > 0);
                        request.setAttribute("userFollowed", rs.getInt("followed") > 0);
                    }
                }
            } catch (SQLException e) {
                LOG.log(Level.WARNING, "查询交互状态失败", e);
            }
        }

        // 3. 查询回复列表
        List<Map<String, Object>> replyList = new ArrayList<>();
        String replySql = "SELECT r.id, r.content, r.created_at, u.username AS author_name, u.id AS user_id " +
                          "FROM replies r JOIN users u ON r.user_id = u.id " +
                          "WHERE r.post_id = ? ORDER BY r.created_at ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(replySql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                int floor = 1;
                while (rs.next()) {
                    Map<String, Object> reply = new HashMap<>();
                    reply.put("id", rs.getInt("id"));
                    reply.put("content", rs.getString("content"));
                    reply.put("createdAt", rs.getTimestamp("created_at").toString());
                    reply.put("authorName", rs.getString("author_name"));
                    reply.put("userId", rs.getInt("user_id"));
                    reply.put("floor", floor++);
                    replyList.add(reply);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询回复列表失败, postId=" + postId, e);
        }
        request.setAttribute("replyList", replyList);
        request.setAttribute("replyCount", replyList.size());

        // 4. 查询相关帖子
        loadRelatedPosts(request, postId, (int) post.get("categoryId"), (String) post.get("keywords"));

        request.getRequestDispatcher("/post/detail.jsp").forward(request, response);
    }

    /** 查询相关帖子 */
    private void loadRelatedPosts(HttpServletRequest request, int postId, int categoryId, String keywords) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.id, p.title, p.view_count, p.created_at, u.username AS author_name " +
            "FROM posts p JOIN users u ON p.user_id = u.id WHERE p.id != ? AND (");

        if (keywords != null && !keywords.trim().isEmpty()) {
            String[] kws = keywords.split("[,，]");
            for (int i = 0; i < kws.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("p.keywords LIKE ?");
            }
            sql.append(" OR ");
        }

        sql.append("p.category_id = ?) ORDER BY p.view_count DESC LIMIT 5");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, postId);

            if (keywords != null && !keywords.trim().isEmpty()) {
                String[] kws = keywords.split("[,，]");
                for (String kw : kws) {
                    ps.setString(idx++, "%" + kw.trim() + "%");
                }
            }

            ps.setInt(idx, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(PostMapper.mapRelatedRow(rs));
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.WARNING, "查询相关帖子失败, postId=" + postId, e);
        }

        request.setAttribute("relatedPosts", list);
    }

    /** 处理发帖（需登录，支持本地上传封面图） */
    private void handleCreatePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String categoryIdStr = request.getParameter("categoryId");
        String keywords = request.getParameter("keywords");

        if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
            request.setAttribute("error", "标题和内容不能为空");
            request.getRequestDispatcher("/post/create.jsp").forward(request, response);
            return;
        }

        String imageUrl = saveUploadedImage(request);
        if (imageUrl.isEmpty()) {
            String urlParam = request.getParameter("imageUrl");
            imageUrl = (urlParam != null) ? urlParam.trim() : "";
        }

        int userId = (int) user.get("id");
        int categoryId;
        try {
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            categoryId = 1;
        }

        String sql = "INSERT INTO posts (title, content, image_url, keywords, user_id, category_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, title.trim());
            ps.setString(2, content.trim());
            ps.setString(3, imageUrl);
            ps.setString(4, keywords == null ? "" : keywords.trim());
            ps.setInt(5, userId);
            ps.setInt(6, categoryId);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int newId = rs.getInt(1);
                    LOG.info("新帖发布成功, postId=" + newId + ", 作者=" + user.get("username"));

                    // 发帖 +10 积分
                    addScore(userId, 10, "发布帖子");

                    response.sendRedirect(request.getContextPath() + "/post/detail?id=" + newId);
                    return;
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "发布帖子失败", e);
            request.setAttribute("error", "发布失败，请重试");
            request.getRequestDispatcher("/post/create.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/");
    }

    /** 处理回复（需登录） */
    private void handleReply(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        String content = request.getParameter("content");
        String postIdStr = request.getParameter("postId");

        if (content == null || content.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postIdStr);
            return;
        }

        int userId = (int) user.get("id");
        int postId;
        try {
            postId = Integer.parseInt(postIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String sql = "INSERT INTO replies (content, user_id, post_id) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, content.trim());
            ps.setInt(2, userId);
            ps.setInt(3, postId);
            ps.executeUpdate();
            LOG.info("新回复成功, postId=" + postId + ", 用户=" + user.get("username"));

            // 回复 +2 积分
            addScore(userId, 2, "回复帖子");
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "发表回复失败, postId=" + postId, e);
        }

        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
    }

    /** 显示编辑表单（需登录且是作者或管理员） */
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String sql = "SELECT p.id, p.title, p.content, p.image_url, p.user_id, p.category_id FROM posts p WHERE p.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int authorId = rs.getInt("user_id");
                    if (!"admin".equals(user.get("role")) && (int) user.get("id") != authorId) {
                        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
                        return;
                    }

                    Map<String, Object> post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    post.put("content", rs.getString("content"));
                    post.put("imageUrl", rs.getString("image_url") == null ? "" : rs.getString("image_url"));
                    post.put("userId", rs.getInt("user_id"));
                    post.put("categoryId", rs.getInt("category_id"));
                    request.setAttribute("post", post);
                } else {
                    response.sendRedirect(request.getContextPath() + "/");
                    return;
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询编辑帖子失败, postId=" + postId, e);
        }

        request.getRequestDispatcher("/post/edit.jsp").forward(request, response);
    }

    /** 处理编辑（需登录且是作者或管理员） */
    private void handleEditPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String categoryIdStr = request.getParameter("categoryId");
        String keywords = request.getParameter("keywords");

        if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
            request.setAttribute("error", "标题和内容不能为空");
            handleEditForm(request, response);
            return;
        }

        String imageUrl = saveUploadedImage(request);
        if (imageUrl.isEmpty()) {
            String urlParam = request.getParameter("imageUrl");
            imageUrl = (urlParam != null) ? urlParam.trim() : "";
        }

        int categoryId;
        try {
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            categoryId = 1;
        }

        // 先检查权限
        String checkSql = "SELECT user_id FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int authorId = rs.getInt("user_id");
                    if (!"admin".equals(user.get("role")) && (int) user.get("id") != authorId) {
                        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
                        return;
                    }
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "检查编辑权限失败, postId=" + postId, e);
        }

        String sql = "UPDATE posts SET title=?, content=?, image_url=?, keywords=?, category_id=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title.trim());
            ps.setString(2, content.trim());
            ps.setString(3, imageUrl);
            ps.setString(4, keywords == null ? "" : keywords.trim());
            ps.setInt(5, categoryId);
            ps.setInt(6, postId);
            ps.executeUpdate();
            LOG.info("帖子编辑成功, postId=" + postId + ", 操作者=" + user.get("username"));
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "编辑帖子失败, postId=" + postId, e);
        }

        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
    }

    /** 删除帖子（需登录且是作者或管理员） */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // 检查权限
        String checkSql = "SELECT user_id FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int authorId = rs.getInt("user_id");
                    if (!"admin".equals(user.get("role")) && (int) user.get("id") != authorId) {
                        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
                        return;
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + "/");
                    return;
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "检查删除权限失败, postId=" + postId, e);
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM posts WHERE id = ?")) {
            ps.setInt(1, postId);
            ps.executeUpdate();
            LOG.info("帖子删除成功, postId=" + postId + ", 操作者=" + user.get("username"));
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "删除帖子失败, postId=" + postId, e);
        }

        response.sendRedirect(request.getContextPath() + "/");
    }

    /**
     * 帖子搜索（GET /post/search?keyword=xxx）
     * LIKE 搜索标题和内容，分页展示，复用首页帖子列表模板
     */
    private void handleSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        keyword = keyword.trim();

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

        int totalPosts = countSearchPosts(keyword);
        int totalPages = (int) Math.ceil((double) totalPosts / PAGE_SIZE);
        if (page > totalPages && totalPages > 0) page = totalPages;

        List<Map<String, Object>> postList = searchPosts(keyword, page);

        request.setAttribute("postList", postList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("searchKeyword", keyword);

        request.getRequestDispatcher("/WEB-INF/home.jsp").forward(request, response);
    }

    /** 统计搜索匹配的帖子总数 */
    private int countSearchPosts(String keyword) {
        String sql = "SELECT COUNT(*) FROM posts WHERE title LIKE ? OR content LIKE ?";
        String like = "%" + keyword + "%";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, like);
            ps.setString(2, like);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "统计搜索结果失败, keyword=" + keyword, e);
        }
        return 0;
    }

    /** 执行搜索，返回分页结果 */
    private List<Map<String, Object>> searchPosts(String keyword, int page) {
        List<Map<String, Object>> list = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;
        String like = "%" + keyword + "%";
        String sql = "SELECT p.id, p.title, p.image_url, p.content AS summary, p.ai_summary, " +
                     "p.is_top, p.is_elite, p.view_count, p.created_at, " +
                     "u.username AS author_name, c.name AS category_name " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "WHERE p.title LIKE ? OR p.content LIKE ? " +
                     "ORDER BY p.is_top DESC, p.is_elite DESC, p.created_at DESC " +
                     "LIMIT ? OFFSET ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setInt(3, PAGE_SIZE);
            ps.setInt(4, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(PostMapper.mapPostRow(rs));
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "搜索帖子失败, keyword=" + keyword, e);
        }
        return list;
    }

    /** 生成AI总结（需登录），返回JSON */
    private void handleAiSummary(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"请先登录\"}");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"参数错误\"}");
            return;
        }

        // 使用同一个连接完成查询 + 更新，避免重复连接
        String sql = "SELECT title, content FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String title = rs.getString("title");
                    String content = rs.getString("content");

                    String summary = AiUtil.generateSummary(title, content);

                    if (summary != null) {
                        // 复用同一个连接保存总结，并记录生成者
                        String updateSql = "UPDATE posts SET ai_summary = ?, ai_user_id = ? WHERE id = ?";
                        try (PreparedStatement ps2 = conn.prepareStatement(updateSql)) {
                            ps2.setString(1, summary);
                            ps2.setInt(2, (int) ((Map<String, Object>) session.getAttribute("user")).get("id"));
                            ps2.setInt(3, postId);
                            ps2.executeUpdate();
                        }
                        LOG.info("AI总结生成成功, postId=" + postId);

                        response.setContentType("application/json;charset=UTF-8");
                        response.getWriter().write("{\"summary\":\"" + escapeJson(summary) + "\"}");
                    } else {
                        response.setContentType("application/json;charset=UTF-8");
                        response.getWriter().write("{\"error\":\"AI接口调用失败，请重试\"}");
                    }
                } else {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"error\":\"帖子不存在\"}");
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "AI总结生成失败, postId=" + postId, e);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"服务器错误\"}");
        }
    }

    /** 处理内联图片上传，返回 Markdown 图片语法文本 */
    private void handleInlineImageUpload(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.setStatus(403);
            response.getWriter().write("{\"error\":\"请先登录\"}");
            return;
        }

        String url = saveUploadedImage(request);
        if (url.isEmpty()) {
            response.setStatus(400);
            response.getWriter().write("{\"error\":\"上传失败，仅支持 jpg/png/gif/webp\"}");
            return;
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"markdown\":\"![图片](" + url + ")\",\"url\":\"" + url + "\"}");
    }

    /** JSON字符串转义 */
    private String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }

    /**
     * 保存上传的封面图片到 webapp/uploads/ 目录
     * @return 图片的访问URL，没有上传时返回空字符串
     */
    private String saveUploadedImage(HttpServletRequest request) throws IOException, ServletException {
        Part filePart;
        try {
            filePart = request.getPart("coverImage");
        } catch (ServletException e) {
            return "";
        }

        if (filePart == null || filePart.getSize() == 0) {
            return "";
        }

        String fileName = filePart.getSubmittedFileName();
        if (fileName == null || fileName.isEmpty()) {
            return "";
        }

        String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
        if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif") && !ext.equals(".webp")) {
            return "";
        }

        String newFileName = UUID.randomUUID().toString() + ext;

        String projectRoot = System.getProperty("user.dir");
        File uploadDir = new File(projectRoot, "src/main/webapp/uploads");
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        File targetFile = new File(uploadDir, newFileName);
        Files.copy(filePart.getInputStream(), targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

        return request.getContextPath() + "/uploads/" + newFileName;
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
}
