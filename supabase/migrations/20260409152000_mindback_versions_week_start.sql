-- MindBack v2.5 — versions 增加“所属周”（周一日期）
-- 目标：每个版本可明确填写所属周（week_start），总览按该字段自然归类上周/本周/下周。

ALTER TABLE public.versions
  ADD COLUMN IF NOT EXISTS week_start date;

-- 尝试从 target_date(YYYY-MM-DD) 回填 week_start（只对可解析日期生效）
-- 规则：week_start = 该日期所在周的周一
UPDATE public.versions
SET week_start = (
  to_date(target_date, 'YYYY-MM-DD')
  - ((extract(dow from to_date(target_date, 'YYYY-MM-DD'))::int + 6) % 7) * interval '1 day'
)::date
WHERE week_start IS NULL
  AND target_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

