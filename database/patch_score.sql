-- ============================================
-- 积分系统数据库补丁
-- 为已有数据库添加 score 字段
-- 运行方式: mysql -u root -p bbs_forum < patch_score.sql
-- ============================================

-- 为 users 表添加积分字段（如已存在则跳过）
ALTER TABLE users ADD COLUMN IF NOT EXISTS score INT NOT NULL DEFAULT 0 COMMENT '积分';

-- 给现有用户初始化积分
UPDATE users SET score = 100 WHERE score = 0;
