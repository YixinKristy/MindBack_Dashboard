-- MindBack 看板数据库 v2 — 新增 phases / versions
-- 来源：《MindBack 看板数据库 — 变更说明 + 完整数据 v2》
-- 执行顺序：
-- 1) 先执行本文件
-- 2) 再执行 20260408170001_mindback_v2_alter_and_seed.sql

-- ---------------------------------------------------------------------------
-- phases
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.phases (
  id          serial PRIMARY KEY,
  name        text NOT NULL,
  theme       text,
  month_range text,
  description text,
  is_current  boolean DEFAULT false,
  sort_order  int DEFAULT 0,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE public.phases ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.phases;
DROP POLICY IF EXISTS "service write" ON public.phases;
CREATE POLICY "public read" ON public.phases
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.phases
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');

-- seed
INSERT INTO public.phases (id, name, theme, month_range, description, is_current, sort_order)
OVERRIDING SYSTEM VALUE
VALUES
(1, '第一阶段', '稳功能基础', '2026年4月',
  '完成共享频道上线，补齐功能缺口，建立数据监控基础，启动 Onboarding 深度优化',
  true, 1),
(2, '第二阶段', '打磨传播', '2026年5月',
  '共享频道上线后数据驱动迭代，分享功能重构，520封存活动，强化自传播机制',
  false, 2),
(3, '第三阶段', '深度功能与扩张', '2026年6月',
  '小组件上线，心情地图，「半年见」用户总结，Product Hunt 打榜，海外软启动准备',
  false, 3),
(4, '第四阶段', '商业化与海外', '2026年7-8月',
  '记忆点付费体系上线，日本/欧洲市场正式启动，Android 深度追赶，AI 能力深化',
  false, 4)
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('public.phases','id'), COALESCE((SELECT MAX(id) FROM public.phases), 1));

-- ---------------------------------------------------------------------------
-- versions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.versions (
  id            serial PRIMARY KEY,
  platform      text NOT NULL CHECK (platform IN ('ios','android','web')),
  version_num   text NOT NULL,
  slug          text UNIQUE,
  status        text DEFAULT 'dev'
    CHECK (status IN ('dev','testing','submitted','released')),
  target_date   text,
  submitted_at  timestamptz,
  released_at   timestamptz,
  notes         text DEFAULT '',
  sort_order    int DEFAULT 0,
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

-- keep updated_at aligned with other tables
DROP TRIGGER IF EXISTS trg_versions_updated_at ON public.versions;
CREATE TRIGGER trg_versions_updated_at
  BEFORE UPDATE ON public.versions
  FOR EACH ROW EXECUTE FUNCTION public.mindback_set_updated_at();

ALTER TABLE public.versions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public read" ON public.versions;
DROP POLICY IF EXISTS "service write" ON public.versions;
CREATE POLICY "public read" ON public.versions
  FOR SELECT USING (true);
CREATE POLICY "service write" ON public.versions
  FOR ALL
  USING ((SELECT auth.role()) = 'service_role')
  WITH CHECK ((SELECT auth.role()) = 'service_role');

-- seed
INSERT INTO public.versions (id, platform, version_num, slug, status, target_date, submitted_at, sort_order)
OVERRIDING SYSTEM VALUE
VALUES
(1, 'ios',     '1.2.5', 'ios-125',     'submitted', '2026-04-07', '2026-04-07 00:00:00+00', 1),
(2, 'ios',     '1.2.6', 'ios-126',     'dev',       '4月中下旬', NULL, 2),
(3, 'android', '1.0.6', 'android-106', 'dev',       '进行中',     NULL, 3)
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('public.versions','id'), COALESCE((SELECT MAX(id) FROM public.versions), 1));

