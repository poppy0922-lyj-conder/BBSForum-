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
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 管理员帖子管理控制器
 * 负责：帖子列表管理、置顶/加精操作（仅管理员可访问）
 *
 * URL映射：
 *   GET  /admin/post/manage  — 帖子管理列表（分页）
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

    /**
     * 帖子管理列表（分页）
     */
    private void handleManage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        int totalPosts = countAllPosts();
        int totalPages = (int) Math.ceil((double) totalPosts / PAGE_SIZE);
        if (page > totalPages && totalPages > 0) page = totalPages;

        List<Map<String, Object>> postList = loadAllPosts(page);

        request.setAttribute("postList", postList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("pageSize", PAGE_SIZE);

        request.getRequestDispatcher("/admin/post_manage.jsp").forward(request, response);
    }

    /**
     * 切换置顶状态：0 → 1（板块置顶）→ 2（全局置顶）→ 0 循环
     */
    private void handleToggleTop(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/post/manage");
            return;
        }

        // 读取当前 is_top 值
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

        // 循环切换：0→1→2→0
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

        LOG.info("置顶操作完成，重定向到管理页: postId=" + postId);
        response.sendRedirect(request.getContextPath() + "/admin/post/manage");
    }

    /**
     * 切换加精状态：0 ↔ 1
     */
    private void handleToggleElite(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/post/manage");
            return;
        }

        // 读取当前 is_elite 值
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

        // 切换：0→1, 1→0
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

        LOG.info("加精操作完成，重定向到管理页: postId=" + postId);
        response.sendRedirect(request.getContextPath() + "/admin/post/manage");
    }

    /** 统计所有帖子总数 */
    private int countAllPosts() {
        String sql = "SELECT COUNT(*) FROM posts";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "统计帖子总数失败", e);
        }
        return 0;
    }

    /** 加载所有帖子列表（分页） */
    private List<Map<String, Object>> loadAllPosts(int page) {
        List<Map<String, Object>> list = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;
        String sql = "SELECT p.id, p.title, p.image_url, p.content AS summary, p.ai_summary, " +
                     "p.is_top, p.is_elite, p.view_count, p.created_at, " +
                     "u.username AS author_name, c.name AS category_name " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "ORDER BY p.created_at DESC " +
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
            LOG.log(Level.SEVERE, "加载帖子管理列表失败", e);
        }
        return list;
    }
}
