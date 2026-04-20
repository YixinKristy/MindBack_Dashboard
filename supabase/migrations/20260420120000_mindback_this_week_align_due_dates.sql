-- 自然周维护：把「本周跟进」相关项的截止日期对齐到当前自然周（周一～周日）
-- 与前端 startOfWeekMonday 一致：PostgreSQL dow 周日=0，周一=1
--
-- 1) tasks.this_week = true 的未完项 → due_date = 本周一~本周日
-- 2) bugs.is_focus = true 的未完项 → due_date = 本周一~本周日
-- 3) ops_actions.is_focus = true 的未完项 → target_date = 本周一~本周日
-- 4) 任意未完项：若 due_date/target_date 恰好等于「上一整周」的 YYYY-MM-DD~YYYY-MM-DD，则滚到本周同一格式
--
-- 说明：不改动已归档、已完成/已发布类终态；重复执行会把本周范围再写一遍（幂等）。

WITH mon AS (
  SELECT (
    current_date - ((extract(dow from current_date)::int + 6) % 7) * interval '1 day'
  )::date AS d0
),
wk AS (
  SELECT
    to_char(d0, 'YYYY-MM-DD') AS wk_start,
    to_char(d0 + 6, 'YYYY-MM-DD') AS wk_end,
    to_char(d0 - 7, 'YYYY-MM-DD') AS prev_wk_start,
    to_char(d0 - 1, 'YYYY-MM-DD') AS prev_wk_end
  FROM mon
)
UPDATE public.tasks t
SET due_date = wk.wk_start || '~' || wk.wk_end
FROM wk
WHERE t.is_archived = false
  AND t.status IS DISTINCT FROM 'done'
  AND (
    t.this_week = true
    OR t.due_date = (wk.prev_wk_start || '~' || wk.prev_wk_end)
  );

WITH mon AS (
  SELECT (
    current_date - ((extract(dow from current_date)::int + 6) % 7) * interval '1 day'
  )::date AS d0
),
wk AS (
  SELECT
    to_char(d0, 'YYYY-MM-DD') AS wk_start,
    to_char(d0 + 6, 'YYYY-MM-DD') AS wk_end,
    to_char(d0 - 7, 'YYYY-MM-DD') AS prev_wk_start,
    to_char(d0 - 1, 'YYYY-MM-DD') AS prev_wk_end
  FROM mon
)
UPDATE public.bugs b
SET due_date = wk.wk_start || '~' || wk.wk_end
FROM wk
WHERE b.is_archived = false
  AND b.status IS DISTINCT FROM 'done'
  AND (
    b.is_focus = true
    OR b.due_date = (wk.prev_wk_start || '~' || wk.prev_wk_end)
  );

WITH mon AS (
  SELECT (
    current_date - ((extract(dow from current_date)::int + 6) % 7) * interval '1 day'
  )::date AS d0
),
wk AS (
  SELECT
    to_char(d0, 'YYYY-MM-DD') AS wk_start,
    to_char(d0 + 6, 'YYYY-MM-DD') AS wk_end,
    to_char(d0 - 7, 'YYYY-MM-DD') AS prev_wk_start,
    to_char(d0 - 1, 'YYYY-MM-DD') AS prev_wk_end
  FROM mon
)
UPDATE public.ops_actions o
SET target_date = wk.wk_start || '~' || wk.wk_end
FROM wk
WHERE COALESCE(o.is_archived, false) = false
  AND o.status IS DISTINCT FROM 'done'
  AND (
    o.is_focus = true
    OR o.target_date = (wk.prev_wk_start || '~' || wk.prev_wk_end)
  );
