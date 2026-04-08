-- MindBack 看板 — 规范化表结构 + RLS
-- 来源：《MindBack看板数据库设计与迁移文档》v1.0
-- 在 Supabase SQL Editor 执行本文件后，再执行 20260408120001_mindback_seed.sql

-- ---------------------------------------------------------------------------
-- updated_at 自动刷新（PATCH 时由 PostgREST 写库）
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mindback_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

-- ---------------------------------------------------------------------------
-- milestones
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.milestones (
  id          text PRIMARY KEY,
  num         text NOT NULL,
  month       text,
  date_short  text,
  date_full   text,
  title       text NOT NULL,
  tags        text[] DEFAULT '{}',
  cost        text,
  status      text NOT NULL DEFAULT 'plan'
    CHECK (status IN ('done','current','plan','campaign')),
  features    text,
  sort_order  int DEFAULT 0,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_milestones_updated_at ON public.milestones;
CREATE TRIGGER trg_milestones_updated_at
  BEFORE UPDATE ON public.milestones
  FOR EACH ROW EXECUTE FUNCTION public.mindback_set_updated_at();

ALTER TABLE public.milestones ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.milestones;
DROP POLICY IF EXISTS "service write" ON public.milestones;
CREATE POLICY "public read" ON public.milestones
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.milestones
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');

-- ---------------------------------------------------------------------------
-- tasks（依赖 milestones）
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tasks (
  id            serial PRIMARY KEY,
  name          text NOT NULL,
  priority      text DEFAULT 'p2'
    CHECK (priority IN ('p0','p1','p2','p3')),
  platforms     text[] DEFAULT '{}',
  owners        text[] DEFAULT '{}',
  status        text NOT NULL DEFAULT 'ns'
    CHECK (status IN ('ns','prog','test','risk','block','done')),
  task_type     text DEFAULT 'task'
    CHECK (task_type IN ('task','bug','fix')),
  source        text DEFAULT 'internal'
    CHECK (source IN ('internal','user','campaign')),
  note          text DEFAULT '',
  version       text DEFAULT '',
  this_week     boolean DEFAULT false,
  milestone_id  text REFERENCES public.milestones(id),
  is_archived   boolean DEFAULT false,
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_tasks_updated_at ON public.tasks;
CREATE TRIGGER trg_tasks_updated_at
  BEFORE UPDATE ON public.tasks
  FOR EACH ROW EXECUTE FUNCTION public.mindback_set_updated_at();

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.tasks;
DROP POLICY IF EXISTS "service write" ON public.tasks;
CREATE POLICY "public read" ON public.tasks
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.tasks
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');

-- ---------------------------------------------------------------------------
-- bugs
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.bugs (
  id          serial PRIMARY KEY,
  severity    text NOT NULL DEFAULT 's1'
    CHECK (severity IN ('s0','s1','s2')),
  name        text NOT NULL,
  platforms   text[] DEFAULT '{}',
  owners      text[] DEFAULT '{}',
  status      text NOT NULL DEFAULT 'ns'
    CHECK (status IN ('ns','prog','done','risk','block')),
  source      text DEFAULT 'user'
    CHECK (source IN ('internal','user')),
  note        text DEFAULT '',
  is_archived boolean DEFAULT false,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_bugs_updated_at ON public.bugs;
CREATE TRIGGER trg_bugs_updated_at
  BEFORE UPDATE ON public.bugs
  FOR EACH ROW EXECUTE FUNCTION public.mindback_set_updated_at();

ALTER TABLE public.bugs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.bugs;
DROP POLICY IF EXISTS "service write" ON public.bugs;
CREATE POLICY "public read" ON public.bugs
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.bugs
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');

-- ---------------------------------------------------------------------------
-- people
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.people (
  id          serial PRIMARY KEY,
  name        text NOT NULL UNIQUE,
  role        text,
  workload    int DEFAULT 0
    CHECK (workload >= 0 AND workload <= 100),
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_people_updated_at ON public.people;
CREATE TRIGGER trg_people_updated_at
  BEFORE UPDATE ON public.people
  FOR EACH ROW EXECUTE FUNCTION public.mindback_set_updated_at();

ALTER TABLE public.people ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.people;
DROP POLICY IF EXISTS "service write" ON public.people;
CREATE POLICY "public read" ON public.people
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.people
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');

-- ---------------------------------------------------------------------------
-- ops_actions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ops_actions (
  id          serial PRIMARY KEY,
  category    text NOT NULL
    CHECK (category IN ('merch','collab','campaign')),
  name        text NOT NULL,
  status      text NOT NULL DEFAULT 'plan'
    CHECK (status IN ('plan','prog','done','pause')),
  target_date text,
  channel     text DEFAULT '',
  owners      text[] DEFAULT '{}',
  note        text DEFAULT '',
  is_archived boolean DEFAULT false,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_ops_actions_updated_at ON public.ops_actions;
CREATE TRIGGER trg_ops_actions_updated_at
  BEFORE UPDATE ON public.ops_actions
  FOR EACH ROW EXECUTE FUNCTION public.mindback_set_updated_at();

ALTER TABLE public.ops_actions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.ops_actions;
DROP POLICY IF EXISTS "service write" ON public.ops_actions;
CREATE POLICY "public read" ON public.ops_actions
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.ops_actions
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');

-- ---------------------------------------------------------------------------
-- backlog
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.backlog (
  id          serial PRIMARY KEY,
  name        text NOT NULL,
  priority    text DEFAULT 'p2'
    CHECK (priority IN ('p0','p1','p2','p3')),
  platforms   text[] DEFAULT '{}',
  note        text DEFAULT '',
  source      text DEFAULT 'internal'
    CHECK (source IN ('internal','user','campaign')),
  is_archived boolean DEFAULT false,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_backlog_updated_at ON public.backlog;
CREATE TRIGGER trg_backlog_updated_at
  BEFORE UPDATE ON public.backlog
  FOR EACH ROW EXECUTE FUNCTION public.mindback_set_updated_at();

ALTER TABLE public.backlog ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.backlog;
DROP POLICY IF EXISTS "service write" ON public.backlog;
CREATE POLICY "public read" ON public.backlog
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.backlog
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');

-- ---------------------------------------------------------------------------
-- tech_debt
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tech_debt (
  id          serial PRIMARY KEY,
  name        text NOT NULL,
  owner       text,
  progress    int DEFAULT 0
    CHECK (progress >= 0 AND progress <= 100),
  note        text DEFAULT '',
  is_archived boolean DEFAULT false,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_tech_debt_updated_at ON public.tech_debt;
CREATE TRIGGER trg_tech_debt_updated_at
  BEFORE UPDATE ON public.tech_debt
  FOR EACH ROW EXECUTE FUNCTION public.mindback_set_updated_at();

ALTER TABLE public.tech_debt ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.tech_debt;
DROP POLICY IF EXISTS "service write" ON public.tech_debt;
CREATE POLICY "public read" ON public.tech_debt
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.tech_debt
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');
