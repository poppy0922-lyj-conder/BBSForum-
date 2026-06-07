package com.bbs.util;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

import com.bbs.util.ContentUtil;

/**
 * 帖子数据映射工具类
 * 统一 ResultSet → Map 的转换逻辑，消除各 Servlet 中的重复代码
 */
public class PostMapper {

    /** 映射帖子列表行（含作者名、板块名、摘要） */
    public static Map<String, Object> mapPostRow(ResultSet rs) throws SQLException {
        Map<String, Object> post = new HashMap<>();
        post.put("id", rs.getInt("id"));
        post.put("title", rs.getString("title"));
        String raw = rs.getString("summary");
        post.put("summary", raw == null ? "" : ContentUtil.summary(raw, 120));
        post.put("isTop", rs.getInt("is_top"));
        post.put("isElite", rs.getInt("is_elite"));
        post.put("viewCount", rs.getInt("view_count"));
        post.put("createdAt", rs.getTimestamp("created_at").toString());
        post.put("authorName", rs.getString("author_name"));
        post.put("categoryName", rs.getString("category_name"));
        post.put("imageUrl", rs.getString("image_url") == null ? "" : rs.getString("image_url"));
        String ai = rs.getString("ai_summary");
        post.put("aiSummary", ai == null ? "" : ai);
        return post;
    }

    /** 映射相关帖子行（简要信息） */
    public static Map<String, Object> mapRelatedRow(ResultSet rs) throws SQLException {
        Map<String, Object> post = new HashMap<>();
        post.put("id", rs.getInt("id"));
        post.put("title", rs.getString("title"));
        post.put("viewCount", rs.getInt("view_count"));
        post.put("createdAt", rs.getTimestamp("created_at").toString());
        post.put("authorName", rs.getString("author_name"));
        return post;
    }

    /** 映射板块行 */
    public static Map<String, Object> mapCategoryRow(ResultSet rs) throws SQLException {
        Map<String, Object> cat = new HashMap<>();
        cat.put("id", rs.getInt("id"));
        cat.put("name", rs.getString("name"));
        cat.put("description", rs.getString("description"));
        return cat;
    }

    /** 映射用户行（管理后台用户列表） */
    public static Map<String, Object> mapUserRow(ResultSet rs) throws SQLException {
        Map<String, Object> user = new HashMap<>();
        user.put("id", rs.getInt("id"));
        user.put("username", rs.getString("username"));
        user.put("phone", rs.getString("phone") == null ? "" : rs.getString("phone"));
        user.put("jobType", rs.getString("job_type") == null ? "" : rs.getString("job_type"));
        user.put("jobLocation", rs.getString("job_location") == null ? "" : rs.getString("job_location"));
        user.put("role", rs.getString("role"));
        user.put("score", rs.getInt("score"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        user.put("createdAt", createdAt == null ? "" : createdAt.toString());
        return user;
    }
}
