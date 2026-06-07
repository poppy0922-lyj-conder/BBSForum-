-- ============================================
-- BBS论坛系统 数据库初始化脚本
-- 适配 MySQL 8.0+
-- 创建日期: 2026-06-06
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS bbs_forum
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE bbs_forum;

-- ============================================
-- 1. 用户表 (组员B负责)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
                                     id          INT AUTO_INCREMENT PRIMARY KEY,
                                     username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '用户名',
    password    VARCHAR(255) NOT NULL COMMENT '加密密码',
    phone       VARCHAR(20)  DEFAULT '' COMMENT '联系方式',
    job_type    VARCHAR(50)  DEFAULT '' COMMENT '工作性质',
    job_location VARCHAR(100) DEFAULT '' COMMENT '工作地点',
    role        ENUM('user','admin') NOT NULL DEFAULT 'user' COMMENT '角色',
    score       INT NOT NULL DEFAULT 0 COMMENT '积分',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 插入默认账号（演示账号）
-- 注意：此处密码为明文，配合后端“首次登录成功后自动升级为 BCrypt”的兼容策略
-- - admin / admin123（管理员）
-- - test  / test123（普通用户）
INSERT INTO users (username, password, role,score) VALUES
                                                       ('admin', 'admin123', 'admin',0),
                                                       ('test', 'test123', 'user',0);

-- ============================================
-- 2. 板块表 (组员C负责)
-- ============================================
CREATE TABLE IF NOT EXISTS categories (
                                          id          INT AUTO_INCREMENT PRIMARY KEY,
                                          name        VARCHAR(50)  NOT NULL COMMENT '板块名称',
    description VARCHAR(200) DEFAULT '' COMMENT '板块描述',
    sort_order  INT DEFAULT 0 COMMENT '排序权重',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='板块表';

-- 插入默认板块
INSERT INTO categories (name, description, sort_order) VALUES
                                                           ('技术交流', '编程技术、开发经验分享', 1),
                                                           ('生活杂谈', '日常生活、兴趣爱好交流', 2),
                                                           ('求职招聘', '工作机会、求职经验分享', 3),
                                                           ('需求悬赏', '发布需求、悬赏求助', 4);

-- ============================================
-- 3. 帖子表 (组长+组员A负责)
-- ============================================
CREATE TABLE IF NOT EXISTS posts (
                                     id          INT AUTO_INCREMENT PRIMARY KEY,
                                     title       VARCHAR(100) NOT NULL COMMENT '标题',
    content     TEXT NOT NULL COMMENT '内容',
    image_url   VARCHAR(500) DEFAULT '' COMMENT '封面图片URL',
    user_id     INT NOT NULL COMMENT '作者ID',
    category_id INT NOT NULL COMMENT '所属板块ID',
    is_top      TINYINT DEFAULT 0 COMMENT '是否置顶 0=否 1=板块置顶 2=全局置顶',
    is_elite    TINYINT DEFAULT 0 COMMENT '是否加精 0=否 1=是',
    ai_summary  TEXT DEFAULT NULL COMMENT 'AI生成的内容总结',
    ai_user_id  INT DEFAULT NULL COMMENT 'AI总结生成者ID',
    keywords    VARCHAR(200) DEFAULT '' COMMENT '关键词，逗号分隔',
    view_count  INT DEFAULT 0 COMMENT '浏览次数',
    like_count     INT DEFAULT 0 COMMENT '点赞数',
    favorite_count INT DEFAULT 0 COMMENT '收藏数',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子表';

-- 插入测试帖子
INSERT INTO posts (title, content, image_url, user_id, category_id, is_top, is_elite, view_count) VALUES
                                                                                                      ('Java 21 虚拟线程实战指南', '虚拟线程是Java 21中最重磅的特性，它让高并发编程变得前所未有的简单。本文将带你从入门到实战，全面掌握虚拟线程的使用技巧和最佳实践。', 'https://picsum.photos/seed/java/400/260', 1, 1, 2, 1, 1560),
                                                                                                      ('Spring Boot 3.2 新特性一览', 'Spring Boot 3.2带来了很多令人兴奋的新特性，包括对虚拟线程的自动配置支持、改进的AOT编译等，让我们一起来看看。', 'https://picsum.photos/seed/spring/400/260', 2, 1, 1, 1, 892),
                                                                                                      ('Python 数据分析入门路线', '数据分析和AI时代，Python是必备技能。本文分享一条从零到实战的数据分析学习路线，帮助新手快速入门。', 'https://picsum.photos/seed/python/400/260', 1, 1, 0, 1, 2340),
                                                                                                      ('搬砖人的周末放松方式', '周末是程序员的充电时间，分享几个低成本高回报的放松方式，让你周一满血复活。', 'https://picsum.photos/seed/relax/400/260', 2, 2, 0, 0, 678),
                                                                                                      ('新手如何挑选机械键盘', '从轴体到手感，从布局到预算，帮你选到最适合编程的机械键盘。', 'https://picsum.photos/seed/keyboard/400/260', 1, 2, 0, 0, 423),
                                                                                                      ('2026年应届生求职经验分享', '刚拿到字节offer，分享一下我的面试准备过程、简历撰写技巧和薪资谈判心得。', 'https://picsum.photos/seed/job/400/260', 2, 3, 0, 1, 3200),
                                                                                                      ('前端React开发兼职机会', '远程办公，时薪优厚，需要熟悉React和TypeScript，欢迎有意向的朋友联系。', 'https://picsum.photos/seed/react/400/260', 1, 3, 0, 0, 1567),
                                                                                                      ('高价悬赏：小程序UI设计', '需要一个电商小程序的全套UI设计稿，要求有现代感、简洁大气，预算3000积分。', 'https://picsum.photos/seed/ui/400/260', 2, 4, 0, 0, 534);

-- ============================================
-- 4. 回复表 (组长负责)
-- ============================================
CREATE TABLE IF NOT EXISTS replies (
                                       id          INT AUTO_INCREMENT PRIMARY KEY,
                                       content     TEXT NOT NULL COMMENT '回复内容',
                                       user_id     INT NOT NULL COMMENT '回复者ID',
                                       post_id     INT NOT NULL COMMENT '所属帖子ID',
                                       created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
                                       FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='回复表';

-- ============================================
-- 5. 需求表 (组员D负责)
-- ============================================
CREATE TABLE IF NOT EXISTS demands (
                                       id            INT AUTO_INCREMENT PRIMARY KEY,
                                       title         VARCHAR(100) NOT NULL COMMENT '需求标题',
    content       TEXT NOT NULL COMMENT '需求描述',
    user_id       INT NOT NULL COMMENT '发布者ID',
    score         INT NOT NULL DEFAULT 0 COMMENT '悬赏积分',
    status        ENUM('open','closed') NOT NULL DEFAULT 'open' COMMENT '状态',
    best_reply_id INT DEFAULT NULL COMMENT '最佳回复ID',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    FOREIGN KEY (user_id) REFERENCES users(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='需求表';

-- 需求回复表
CREATE TABLE IF NOT EXISTS demand_replies (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    content     TEXT NOT NULL COMMENT '回复内容',
    user_id     INT NOT NULL COMMENT '回复者ID',
    demand_id   INT NOT NULL COMMENT '所属需求ID',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (demand_id) REFERENCES demands(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='需求回复表';

-- ============================================
-- 6. 积分流水表 (组员D负责)
-- ============================================
CREATE TABLE IF NOT EXISTS score_logs (
                                          id          INT AUTO_INCREMENT PRIMARY KEY,
                                          user_id     INT NOT NULL COMMENT '用户ID',
                                          score       INT NOT NULL COMMENT '积分变动 正数=获得 负数=扣除',
                                          reason      VARCHAR(100) DEFAULT '' COMMENT '变动原因',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '时间',
    FOREIGN KEY (user_id) REFERENCES users(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分流水表';

-- ============================================
-- 7. 签到表 (组员D负责)
-- ============================================
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

-- ============================================
-- 8. 帖子点赞表
-- ============================================
CREATE TABLE IF NOT EXISTS post_likes (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL COMMENT '用户ID',
    post_id    INT NOT NULL COMMENT '帖子ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_post (user_id, post_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子点赞表';

-- ============================================
-- 9. 帖子收藏表
-- ============================================
CREATE TABLE IF NOT EXISTS post_favorites (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL COMMENT '用户ID',
    post_id    INT NOT NULL COMMENT '帖子ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_post (user_id, post_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子收藏表';
-- 8. 点赞表
-- ============================================
CREATE TABLE IF NOT EXISTS post_likes (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL COMMENT '点赞用户ID',
    post_id     INT NOT NULL COMMENT '被点赞帖子ID',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE KEY uk_like (user_id, post_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='点赞表';

-- ============================================
-- 9. 收藏表
-- ============================================
CREATE TABLE IF NOT EXISTS post_favorites (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL COMMENT '收藏用户ID',
    post_id     INT NOT NULL COMMENT '被收藏帖子ID',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE KEY uk_fav (user_id, post_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- ============================================
-- 10. 用户关注表
-- ============================================
CREATE TABLE IF NOT EXISTS user_follows (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    user_id           INT NOT NULL COMMENT '关注者ID',
    followed_user_id  INT NOT NULL COMMENT '被关注者ID',
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (followed_user_id) REFERENCES users(id),
    UNIQUE KEY uk_user_followed (user_id, followed_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户关注表';

-- ============================================
-- 已有数据库迁移补丁（已存在则跳过）
-- 新部署可忽略以下内容
-- ============================================
SET @dbname = DATABASE();
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = @dbname
                   AND TABLE_NAME = 'users'
                   AND COLUMN_NAME = 'score');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE users ADD COLUMN score INT NOT NULL DEFAULT 0 COMMENT ''积分'' AFTER role',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
    UNIQUE KEY uk_follow (user_id, followed_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户关注表';

