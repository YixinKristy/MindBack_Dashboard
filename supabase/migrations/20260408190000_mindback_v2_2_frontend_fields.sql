-- MindBack 看板数据库 v2.2 — 为「新前端指令」补齐字段
-- 目标：不重复已有字段；只补 UI 必需的最小字段集
-- 说明：
-- - ops_actions 已有 target_date，可直接作为“截止日期”，不新增重复字段
-- - milestones 已有 date_short/date_full
-- - versions 已有 target_date

-- ---------------------------------------------------------------------------
-- 1) tasks：截止日期 + “本周重点”标记 + 模块标签
-- ---------------------------------------------------------------------------
ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS due_date text DEFAULT '';

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS is_focus boolean DEFAULT false;

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS module text DEFAULT '';

-- 让筛选更好用：可选索引（不影响功能；幂等）
CREATE INDEX IF NOT EXISTS idx_tasks_this_week ON public.tasks(this_week);
CREATE INDEX IF NOT EXISTS idx_tasks_is_focus ON public.tasks(is_focus);

-- ---------------------------------------------------------------------------
-- 2) bugs：截止日期 + “本周重点”标记 + 模块标签
-- ---------------------------------------------------------------------------
ALTER TABLE public.bugs
  ADD COLUMN IF NOT EXISTS due_date text DEFAULT '';

ALTER TABLE public.bugs
  ADD COLUMN IF NOT EXISTS is_focus boolean DEFAULT false;

ALTER TABLE public.bugs
  ADD COLUMN IF NOT EXISTS module text DEFAULT '';

CREATE INDEX IF NOT EXISTS idx_bugs_is_focus ON public.bugs(is_focus);

-- ---------------------------------------------------------------------------
-- 3) backlog：模块标签（用于 UI 的“所属模块标签”）
-- ---------------------------------------------------------------------------
ALTER TABLE public.backlog
  ADD COLUMN IF NOT EXISTS module text DEFAULT '';

