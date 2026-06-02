package com.bbs.util;

import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * 密码工具类
 * - 新密码：BCrypt 加密存储
 * - 旧数据：兼容明文，并可在首次成功登录后自动升级为 BCrypt
 */
public class PasswordUtil {

    private PasswordUtil() {}

    /**
     * 判断字符串是否为 BCrypt hash
     * jBCrypt hash 通常以 $2a$ / $2b$ / $2y$ 开头
     */
    public static boolean isBcrypt(String stored) {
        if (stored == null) return false;
        return stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$");
    }

    /** BCrypt hash（默认 10 轮） */
    public static String hash(String plain) {
        return BCrypt.hashpw(plain, BCrypt.gensalt(10));
    }

    /**
     * 验证密码（兼容旧明文）
     * @return true 表示密码正确
     */
    public static boolean verify(String plain, String stored) {
        if (plain == null || stored == null) return false;
        if (isBcrypt(stored)) {
            return BCrypt.checkpw(plain, stored);
        }
        // 旧明文兼容
        return plain.equals(stored);
    }

    /**
     * 兼容旧明文并自动升级为 BCrypt
     * - 若 stored 是 bcrypt：只做校验
     * - 若 stored 是旧明文：校验成功后自动更新为 bcrypt
     */
    public static boolean verifyAndUpgradeIfLegacy(Connection conn, int userId, String plain, String stored) throws SQLException {
        if (!verify(plain, stored)) return false;

        if (!isBcrypt(stored)) {
            String newHash = hash(plain);
            try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?")) {
                ps.setString(1, newHash);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }
        }
        return true;
    }
}

