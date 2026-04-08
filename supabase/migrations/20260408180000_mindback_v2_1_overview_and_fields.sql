-- MindBack 看板数据库 v2.1 — 为前端卡片/总览联动补字段
-- 目的：对齐《产品看板 — 完整设计文档》中的总览/版本/里程碑/卡片交互
-- 依赖：已执行 v1 + v2 迁移（含 public.mindback_set_updated_at、phases、versions）

-- ---------------------------------------------------------------------------
-- 1) 总览数据源：board_overview（按月存：月目标/KPI/下阶段预告）
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.board_overview (
  id                   bigserial PRIMARY KEY,
  month_key            text NOT NULL UNIQUE,       -- e.g. '2026-04'
  phase_id             int REFERENCES public.phases(id),
  month_goal           text DEFAULT '',            -- 月目标文字（支持换行）
  month_goal_updated_at timestamptz,              -- 前端行内编辑时自动写入
  kpis                 jsonb DEFAULT '{}'::jsonb,  -- 核心指标（值+更新时间等，前端自定义 schema）
  next_preview         text DEFAULT '',            -- 下阶段预告文字（支持换行）
  created_at           timestamptz DEFAULT now(),
  updated_at           timestamptz DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_board_overview_updated_at ON public.board_overview;
CREATE TRIGGER trg_board_overview_updated_at
  BEFORE UPDATE ON public.board_overview
  FOR EACH ROW EXECUTE FUNCTION public.mindback_set_updated_at();

ALTER TABLE public.board_overview ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.board_overview;
DROP POLICY IF EXISTS "service write" ON public.board_overview;
CREATE POLICY "public read" ON public.board_overview
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.board_overview
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');

-- ---------------------------------------------------------------------------
-- 2) 里程碑：支持“延期”状态（可筛选）
-- ---------------------------------------------------------------------------
ALTER TABLE public.milestones
  ADD COLUMN IF NOT EXISTS delayed_note text DEFAULT '';

-- 将 milestones.status 的 CHECK 扩展包含 'delay'
DO $$
DECLARE
  chk_name text;
BEGIN
  SELECT con.conname INTO chk_name
  FROM pg_constraint con
  JOIN pg_class rel ON rel.oid = con.conrelid
  JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
  WHERE nsp.nspname = 'public'
    AND rel.relname = 'milestones'
    AND con.contype = 'c'
    AND pg_get_constraintdef(con.oid) LIKE '%status IN (%';

  IF chk_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.milestones DROP CONSTRAINT IF EXISTS %I', chk_name);
  END IF;

  -- 迁移可能被重复执行：先删除同名约束，避免 42710
  ALTER TABLE public.milestones DROP CONSTRAINT IF EXISTS milestones_status_check;

  ALTER TABLE public.milestones
    ADD CONSTRAINT milestones_status_check
    CHECK (status IN ('done','current','plan','campaign','delay'));
END $$;

-- ---------------------------------------------------------------------------
-- 3) 版本：支持状态切换自动记时间戳 + Release Notes 信息源
-- ---------------------------------------------------------------------------
ALTER TABLE public.versions
  ADD COLUMN IF NOT EXISTS status_changed_at timestamptz;

ALTER TABLE public.versions
  ADD COLUMN IF NOT EXISTS testing_at timestamptz;

ALTER TABLE public.versions
  ADD COLUMN IF NOT EXISTS release_notes text DEFAULT '';

-- 可选：当 versions.status 被更新时，若前端未显式写 status_changed_at，则由触发器补全
CREATE OR REPLACE FUNCTION public.mindback_versions_status_ts()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.status IS DISTINCT FROM OLD.status THEN
    IF NEW.status_changed_at IS NULL THEN
      NEW.status_changed_at := now();
    END IF;
    IF NEW.status = 'testing' AND NEW.testing_at IS NULL THEN
      NEW.testing_at := now();
    END IF;
    IF NEW.status = 'submitted' AND NEW.submitted_at IS NULL THEN
      NEW.submitted_at := now();
    END IF;
    IF NEW.status = 'released' AND NEW.released_at IS NULL THEN
      NEW.released_at := now();
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_versions_status_ts ON public.versions;
CREATE TRIGGER trg_versions_status_ts
  BEFORE UPDATE ON public.versions
  FOR EACH ROW EXECUTE FUNCTION public.mindback_versions_status_ts();

-- ---------------------------------------------------------------------------
-- 4) 任务/Backlog：为“移入 Backlog / 移入本周冲刺”建立可追溯链接（可选但推荐）
-- ---------------------------------------------------------------------------
ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS moved_from_backlog_id int;

ALTER TABLE public.backlog
  ADD COLUMN IF NOT EXISTS moved_to_task_id int REFERENCES public.tasks(id);

