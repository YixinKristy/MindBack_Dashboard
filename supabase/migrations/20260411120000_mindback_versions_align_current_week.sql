-- 新自然周维护：将仍在发布管线中、且 week_start 早于「本周一」的版本对齐到本周一
-- 规则与前端 startOfWeekMonday 一致（周一为周起始；PostgreSQL dow：周日=0）
-- 已发布（released）版本不改，保留历史周次。
-- 含 week_start 为 NULL 的进行中版本，一并写入本周一，避免总览落在「未识别日期」。

WITH mon AS (
  SELECT (
    current_date - ((extract(dow from current_date)::int + 6) % 7) * interval '1 day'
  )::date AS this_mon
)
UPDATE public.versions v
SET week_start = mon.this_mon
FROM mon
WHERE v.status IN ('not_started', 'dev', 'testing', 'submitted')
  AND (
    v.week_start IS NULL
    OR v.week_start < mon.this_mon
  );
