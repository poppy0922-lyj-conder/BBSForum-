package com.bbs.controller;

import com.bbs.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 管理员仪表盘图表数据接口
 * 返回 JSON 格式数据供前端 Chart.js 使用
 */
@WebServlet(name = "adminChartData", urlPatterns = {"/admin/chart/postsByCategory", "/admin/chart/dailyPosts", "/admin/chart/userGrowth"})
public class AdminDashboardServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(AdminDashboardServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        response.setContentType("application/json;charset=UTF-8");

        String json;
        if ("/admin/chart/postsByCategory".equals(path)) {
            json = getPostsByCategory();
        } else if ("/admin/chart/dailyPosts".equals(path)) {
            json = getDailyPosts();
        } else if ("/admin/chart/userGrowth".equals(path)) {
            json = getUserGrowth();
        } else {
            json = "{}";
        }

        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }

    /** 各板块帖子统计 */
    private String getPostsByCategory() {
        StringBuilder sb = new StringBuilder("{\"labels\":[");
        StringBuilder data = new StringBuilder("\"data\":[");
        String sql = "SELECT c.name, COUNT(p.id) AS cnt FROM categories c " +
                     "LEFT JOIN posts p ON c.id = p.category_id " +
                     "GROUP BY c.id, c.name ORDER BY cnt DESC";

        boolean first = true;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                if (!first) { sb.append(","); data.append(","); }
                sb.append("\"").append(escapeJson(rs.getString("name"))).append("\"");
                data.append(rs.getInt("cnt"));
                first = false;
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询板块帖子统计失败", e);
        }
        sb.append("],").append(data).append("]}");
        return sb.toString();
    }

    /** 近30天每日发帖量 */
    private String getDailyPosts() {
        StringBuilder sb = new StringBuilder("{\"labels\":[");
        StringBuilder data = new StringBuilder("\"data\":[");
        String sql = "SELECT DATE(created_at) AS d, COUNT(*) AS cnt FROM posts " +
                     "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
                     "GROUP BY DATE(created_at) ORDER BY d";

        boolean first = true;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                if (!first) { sb.append(","); data.append(","); }
                sb.append("\"").append(rs.getString("d")).append("\"");
                data.append(rs.getInt("cnt"));
                first = false;
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询每日发帖统计失败", e);
        }
        sb.append("],").append(data).append("]}");
        return sb.toString();
    }

    /** 近7天用户注册量 */
    private String getUserGrowth() {
        StringBuilder sb = new StringBuilder("{\"labels\":[");
        StringBuilder data = new StringBuilder("\"data\":[");
        String sql = "SELECT DATE(created_at) AS d, COUNT(*) AS cnt FROM users " +
                     "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
                     "GROUP BY DATE(created_at) ORDER BY d";

        boolean first = true;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                if (!first) { sb.append(","); data.append(","); }
                sb.append("\"").append(rs.getString("d")).append("\"");
                data.append(rs.getInt("cnt"));
                first = false;
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "查询用户增长统计失败", e);
        }
        sb.append("],").append(data).append("]}");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
