-- MindBack 看板数据库 v2.4 — 补齐 ops_actions.is_focus（与前端一致）
-- 修复：同步时报错 “Could not find the 'is_focus' column of 'ops_actions'”

ALTER TABLE public.ops_actions
  ADD COLUMN IF NOT EXISTS is_focus boolean DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_ops_actions_is_focus ON public.ops_actions(is_focus);

