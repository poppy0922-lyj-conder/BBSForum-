-- ============================================================
-- 修复人机号（user_id 35-54）所有积分记录时间戳对齐
-- 保证 score_logs.created_at 与对应活动记录时间一致
-- ============================================================

-- 1. 注册奖励 → 对齐为用户注册时间
UPDATE score_logs sl
JOIN users u ON sl.user_id = u.id
SET sl.created_at = u.created_at
WHERE sl.user_id BETWEEN 35 AND 54
  AND sl.reason = '注册奖励';

-- 2. 被收到回复 (3pts) → 对齐为回复的创建时间
-- 匹配逻辑：score_logs.user_id = post owner, replies on that post
WITH score_ranked AS (
    SELECT id, user_id,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY id) AS rn
    FROM score_logs
    WHERE user_id BETWEEN 35 AND 54 AND reason = '被收到回复'
),
activity_ranked AS (
    SELECT r.created_at, p.user_id AS post_owner_id,
           ROW_NUMBER() OVER (PARTITION BY p.user_id ORDER BY r.created_at, r.id) AS rn
    FROM replies r
    JOIN posts p ON r.post_id = p.id
    WHERE p.user_id BETWEEN 35 AND 54 AND r.is_deleted = 0
)
UPDATE score_logs sl
JOIN score_ranked sr ON sl.id = sr.id
JOIN activity_ranked ar ON sr.user_id = ar.post_owner_id AND sr.rn = ar.rn
SET sl.created_at = ar.created_at;

-- 3. 被点赞 (5pts) → 对齐为点赞的创建时间
WITH score_ranked AS (
    SELECT id, user_id,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY id) AS rn
    FROM score_logs
    WHERE user_id BETWEEN 35 AND 54 AND reason = '被点赞'
),
activity_ranked AS (
    SELECT pl.created_at, p.user_id AS post_owner_id,
           ROW_NUMBER() OVER (PARTITION BY p.user_id ORDER BY pl.created_at, pl.id) AS rn
    FROM post_likes pl
    JOIN posts p ON pl.post_id = p.id
    WHERE p.user_id BETWEEN 35 AND 54
)
UPDATE score_logs sl
JOIN score_ranked sr ON sl.id = sr.id
JOIN activity_ranked ar ON sr.user_id = ar.post_owner_id AND sr.rn = ar.rn
SET sl.created_at = ar.created_at;

-- 4. 需求回复 (2pts) → 对齐为需求回复的创建时间
-- 匹配逻辑：score_logs.user_id = demand_replies.user_id (回复者就是获得积分者)
WITH score_ranked AS (
    SELECT id, user_id,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY id) AS rn
    FROM score_logs
    WHERE user_id BETWEEN 35 AND 54 AND reason = '需求回复'
),
activity_ranked AS (
    SELECT created_at, user_id,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at, id) AS rn
    FROM demand_replies
    WHERE user_id BETWEEN 35 AND 54 AND is_deleted = 0
)
UPDATE score_logs sl
JOIN score_ranked sr ON sl.id = sr.id
JOIN activity_ranked ar ON sr.user_id = ar.user_id AND sr.rn = ar.rn
SET sl.created_at = ar.created_at;

-- 5. 需求采纳 (variable) → 对齐为需求关闭时的最佳回复时间
-- 匹配逻辑：score_logs.user_id = demand_replies.user_id
-- demand.best_reply_id = demand_replies.id
WITH score_ranked AS (
    SELECT id, user_id,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY id) AS rn
    FROM score_logs
    WHERE user_id BETWEEN 35 AND 54 AND reason = '需求采纳'
),
activity_ranked AS (
    SELECT dr.created_at, dr.user_id,
           ROW_NUMBER() OVER (PARTITION BY dr.user_id ORDER BY dr.created_at, dr.id) AS rn
    FROM demand_replies dr
    JOIN demands d ON d.best_reply_id = dr.id
    WHERE dr.user_id BETWEEN 35 AND 54
)
UPDATE score_logs sl
JOIN score_ranked sr ON sl.id = sr.id
JOIN activity_ranked ar ON sr.user_id = ar.user_id AND sr.rn = ar.rn
SET sl.created_at = ar.created_at;

-- 6. 签到 → 对齐为签到记录时间
UPDATE score_logs sl
JOIN daily_checkins dc ON sl.user_id = dc.user_id
   AND DATE(sl.created_at) = DATE(dc.created_at)
SET sl.created_at = dc.created_at
WHERE sl.user_id BETWEEN 35 AND 54
  AND sl.reason = '签到';

-- 对于可能还有未匹配的签到记录，按天配对
WITH score_unmatched AS (
    SELECT sl.id, sl.user_id, DATE(sl.created_at) AS d,
           ROW_NUMBER() OVER (PARTITION BY sl.user_id, DATE(sl.created_at) ORDER BY sl.id) AS rn
    FROM score_logs sl
    WHERE sl.user_id BETWEEN 35 AND 54
      AND sl.reason = '签到'
      AND sl.id NOT IN (
          SELECT sl2.id FROM score_logs sl2
          JOIN daily_checkins dc ON sl2.user_id = dc.user_id
              AND DATE(sl2.created_at) = DATE(dc.created_at)
          WHERE sl2.user_id BETWEEN 35 AND 54 AND sl2.reason = '签到'
      )
),
checkin_matched AS (
    SELECT dc.created_at, dc.user_id,
           ROW_NUMBER() OVER (PARTITION BY dc.user_id, DATE(dc.created_at) ORDER BY dc.created_at) AS rn
    FROM daily_checkins dc
    WHERE dc.user_id BETWEEN 35 AND 54
)
UPDATE score_logs sl
JOIN score_unmatched su ON sl.id = su.id
JOIN checkin_matched cm ON su.user_id = cm.user_id AND su.d = DATE(cm.created_at) AND su.rn = cm.rn
SET sl.created_at = cm.created_at;

-- 7. 每日首次登录 → 保持当前时间（没有对应的活动表）
-- 可以将其设为当天较早的时间
UPDATE score_logs
SET created_at = DATE_FORMAT(created_at, '%Y-%m-%d 08:00:00')
WHERE user_id BETWEEN 35 AND 54
  AND reason = '每日首次登录';

-- ============================================================
-- 验证：检查修正后的时间戳是否合理
-- ============================================================
SELECT '=== 积分记录时间分布 ===' AS '';
SELECT user_id, reason, COUNT(*) AS cnt,
       MIN(DATE(created_at)) AS earliest,
       MAX(DATE(created_at)) AS latest
FROM score_logs
WHERE user_id BETWEEN 35 AND 54
GROUP BY user_id, reason
ORDER BY user_id, reason;

SELECT '=== 样本检查: allen214 (id=36) 积分记录 ===' AS '';
SELECT id, reason, score, created_at
FROM score_logs
WHERE user_id = 36
ORDER BY created_at
LIMIT 30;
