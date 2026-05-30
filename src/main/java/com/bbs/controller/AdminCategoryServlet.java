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
 * 管理员板块管理控制器
 * 负责：板块的CRUD操作（添加、编辑、删除）
 */
@WebServlet(name = "adminCategory", urlPatterns = {"/admin/categories", "/admin/categories/add", "/admin/categories/edit", "/admin/categories/delete"})
public class AdminCategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();

        if (action.equals("/admin/categories")) {
            // 显示板块列表
            List<Map<String, Object>> categories = loadAllCategories();
            request.setAttribute("categoryList", categories);
            request.getRequestDispatcher("/WEB-INF/admin/categories_content.jsp").forward(request, response);
        } else if (action.equals("/admin/categories/edit")) {
            // 显示编辑表单
            int id = Integer.parseInt(request.getParameter("id"));
            Map<String, Object> category = loadCategory(id);
            request.setAttribute("category", category);
            request.getRequestDispatcher("/WEB-INF/admin/category_edit.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();
        request.setCharacterEncoding("UTF-8");

        if (action.equals("/admin/categories/add")) {
            // 添加新板块
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            addCategory(name, description);
            response.sendRedirect(request.getContextPath() + "/admin/categories");
        } else if (action.equals("/admin/categories/edit")) {
            // 更新板块
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            updateCategory(id, name, description);
            response.sendRedirect(request.getContextPath() + "/admin/categories");
        } else if (action.equals("/admin/categories/delete")) {
            // 删除板块
            int id = Integer.parseInt(request.getParameter("id"));
            deleteCategory(id);
            response.sendRedirect(request.getContextPath() + "/admin/categories");
        }
    }

    /** 加载所有板块列表 */
    private List<Map<String, Object>> loadAllCategories() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, name, description, sort_order FROM categories ORDER BY sort_order";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> category = new HashMap<>();
                category.put("id", rs.getInt("id"));
                category.put("name", rs.getString("name"));
                category.put("description", rs.getString("description"));
                category.put("sortOrder", rs.getInt("sort_order"));
                list.add(category);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** 加载单个板块信息 */
    private Map<String, Object> loadCategory(int id) {
        String sql = "SELECT id, name, description FROM categories WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
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

    /** 添加新板块 */
    private void addCategory(String name, String description) {
        String sql = "INSERT INTO categories (name, description, sort_order) VALUES (?, ?, 0)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, name);
            pstmt.setString(2, description);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /** 更新板块信息 */
    private void updateCategory(int id, String name, String description) {
        String sql = "UPDATE categories SET name = ?, description = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, name);
            pstmt.setString(2, description);
            pstmt.setInt(3, id);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /** 删除板块 */
    private void deleteCategory(int id) {
        String sql = "DELETE FROM categories WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}