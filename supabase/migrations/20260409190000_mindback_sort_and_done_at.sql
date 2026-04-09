-- MindBack 看板数据库 v2.5 — 列表手动排序 + 完成时间
-- 用途：
-- - sort_order：支持拖拽手动排序（前端持久化）
-- - done_at：支持“按完成时间”排序（避免 updated_at 被后续编辑污染）

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS sort_order int DEFAULT 0,
  ADD COLUMN IF NOT EXISTS done_at timestamptz;

ALTER TABLE public.bugs
  ADD COLUMN IF NOT EXISTS sort_order int DEFAULT 0,
  ADD COLUMN IF NOT EXISTS done_at timestamptz;

ALTER TABLE public.ops_actions
  ADD COLUMN IF NOT EXISTS sort_order int DEFAULT 0,
  ADD COLUMN IF NOT EXISTS done_at timestamptz;

CREATE INDEX IF NOT EXISTS idx_tasks_sort_order ON public.tasks(sort_order);
CREATE INDEX IF NOT EXISTS idx_bugs_sort_order ON public.bugs(sort_order);
CREATE INDEX IF NOT EXISTS idx_ops_actions_sort_order ON public.ops_actions(sort_order);

