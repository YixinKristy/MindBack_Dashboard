-- MindBack 看板数据库 v2.4 — 风险字段（任务 / Bug / 运营）
-- 需求：详情页可选“是否有风险”，并可填写风险描述（可为空）

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS is_risk boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS risk_note text DEFAULT '';

ALTER TABLE public.bugs
  ADD COLUMN IF NOT EXISTS is_risk boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS risk_note text DEFAULT '';

ALTER TABLE public.ops_actions
  ADD COLUMN IF NOT EXISTS is_risk boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS risk_note text DEFAULT '';

