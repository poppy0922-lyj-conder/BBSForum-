package com.bbs.util;

import java.io.*;
import java.sql.*;
import java.util.Properties;

/**
 * 数据库连接工具类
 * 配置信息从 src/main/resources/config.properties 读取
 */
public class DBUtil {

    private static final String DB_URL;
    private static final String DB_USER;
    private static final String DB_PASS;

    static {
        Properties config = new Properties();
        try (InputStream is = DBUtil.class.getResourceAsStream("/config.properties")) {
            if (is != null) {
                config.load(is);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        DB_URL = config.getProperty("db.url", "jdbc:mysql://localhost:3306/bbs_forum?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf8");
        DB_USER = config.getProperty("db.user", "root");
        DB_PASS = config.getProperty("db.password", "");

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
