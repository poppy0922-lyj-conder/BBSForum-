package com.bbs.util;

import com.bbs.util.DBUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * 全局数据加载过滤器
 * 为所有页面加载右侧面板所需的统计数据（用户数、帖子数、评论数、需求数、热门标签）
 */
@WebFilter(urlPatterns = {"/*"})
public class StatsFilter implements Filter {

    private static final Logger LOG = Logger.getLogger(StatsFilter.class.getName());
    private static final long CACHE_DURATION = 15_000; // 15秒缓存

    private static volatile long lastLoadTime = 0;
    private static volatile int cachedUserCount = 0;
    private static volatile int cachedPostCount = 0;
    private static volatile int cachedReplyCount = 0;
    private static volatile int cachedDemandCount = 0;
    private static volatile List<Map.Entry<String, Integer>> cachedHotKeywords = new ArrayList<>();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws java.io.IOException, ServletException {

        long now = System.currentTimeMillis();
        boolean isPost = "POST".equalsIgnoreCase(((HttpServletRequest) request).getMethod());

        // POST请求（数据可能已变更）或缓存过期时刷新
        if (isPost || now - lastLoadTime > CACHE_DURATION) {
            refreshCache();
            lastLoadTime = now;
        }

        request.setAttribute("statsUserCount", cachedUserCount);
        request.setAttribute("statsPostCount", cachedPostCount);
        request.setAttribute("statsReplyCount", cachedReplyCount);
        request.setAttribute("statsDemandCount", cachedDemandCount);
        request.setAttribute("statsHotKeywords", cachedHotKeywords);

        chain.doFilter(request, response);
    }

    private void refreshCache() {
        try (Connection conn = DBUtil.getConnection()) {
            cachedUserCount = count(conn, "SELECT COUNT(*) FROM users");
            cachedPostCount = count(conn, "SELECT COUNT(*) FROM posts");
            cachedReplyCount = count(conn, "SELECT COUNT(*) FROM replies");
            cachedDemandCount = count(conn, "SELECT COUNT(*) FROM demands");
            cachedHotKeywords = loadHotKeywords(conn);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "刷新统计数据失败", e);
        }
    }

    private int count(Connection conn, String sql) throws SQLException {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** 从 posts 表的 keywords 字段提取关键词，按出现频率排序 */
    private List<Map.Entry<String, Integer>> loadHotKeywords(Connection conn) {
        Map<String, Integer> freq = new HashMap<>();
        String sql = "SELECT keywords FROM posts WHERE keywords IS NOT NULL AND keywords != ''";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                String kw = rs.getString("keywords");
                if (kw != null) {
                    for (String k : kw.split("[,，]")) {
                        k = k.trim();
                        if (!k.isEmpty()) {
                            freq.merge(k, 1, Integer::sum);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "加载热门关键词失败", e);
        }

        List<Map.Entry<String, Integer>> list = new ArrayList<>(freq.entrySet());
        list.sort((a, b) -> b.getValue().compareTo(a.getValue()));
        return list.size() > 20 ? list.subList(0, 20) : list;
    }

    @Override
    public void init(FilterConfig filterConfig) {}
    @Override
    public void destroy() {}
}
