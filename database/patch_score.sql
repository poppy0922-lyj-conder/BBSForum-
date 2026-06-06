-- ============================================
-- 积分系统数据库补丁
-- 为已有数据库添加 score 字段和签到表
-- 运行方式: mysql -u root -p bbs_forum < patch_score.sql
-- ============================================

-- 为 users 表添加积分字段（如已存在则跳过）
SET @dbname = DATABASE();
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = @dbname
                   AND TABLE_NAME = 'users'
                   AND COLUMN_NAME = 'score');

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE users ADD COLUMN score INT NOT NULL DEFAULT 0 COMMENT ''积分'' AFTER role',
    'SELECT ''score column already exists'' AS status');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 创建签到表（如不存在）
CREATE TABLE IF NOT EXISTS daily_checkins (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    user_id           INT NOT NULL COMMENT '用户ID',
    checkin_date      DATE NOT NULL COMMENT '签到日期',
    consecutive_days  INT NOT NULL DEFAULT 1 COMMENT '连续签到天数',
    score_earned      INT NOT NULL DEFAULT 5 COMMENT '本次获得积分',
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '签到时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uk_user_date (user_id, checkin_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日签到表';

-- 创建需求回复表（如不存在）
CREATE TABLE IF NOT EXISTS demand_replies (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    content     TEXT NOT NULL COMMENT '回复内容',
    user_id     INT NOT NULL COMMENT '回复者ID',
    demand_id   INT NOT NULL COMMENT '所属需求ID',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (demand_id) REFERENCES demands(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='需求回复表';
