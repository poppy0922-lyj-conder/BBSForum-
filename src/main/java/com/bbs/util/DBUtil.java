package com.bbs.util;

import java.sql.*;

/**
 * 数据库连接工具类
 * 使用前请修改 DB_URL、DB_USER、DB_PASS 为实际值
 */
public class DBUtil {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/bbs_forum?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "121510@Lkd";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /** 获取数据库连接 */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    /** 关闭资源 */
    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (stmt != null) stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
}
