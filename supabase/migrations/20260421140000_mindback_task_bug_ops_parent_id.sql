-- 功能 / Bug / 运营：主项与子项
-- 说明：
-- 1) 增加 parent_id 自引用外键
-- 2) 数据库层仅限制“不能指向自己”
-- 3) “父级必须为主项 / 不允许多层嵌套”放在前端与写入逻辑中校验
--    （PostgreSQL CHECK 约束不支持这里所需的跨行子查询）

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS parent_id integer REFERENCES public.tasks(id) ON DELETE SET NULL;

ALTER TABLE public.bugs
  ADD COLUMN IF NOT EXISTS parent_id integer REFERENCES public.bugs(id) ON DELETE SET NULL;

ALTER TABLE public.ops_actions
  ADD COLUMN IF NOT EXISTS parent_id integer REFERENCES public.ops_actions(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_tasks_parent_id ON public.tasks(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bugs_parent_id ON public.bugs(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ops_actions_parent_id ON public.ops_actions(parent_id) WHERE parent_id IS NOT NULL;

ALTER TABLE public.tasks DROP CONSTRAINT IF EXISTS tasks_parent_must_be_root;
ALTER TABLE public.tasks DROP CONSTRAINT IF EXISTS tasks_parent_not_self;
ALTER TABLE public.tasks
  ADD CONSTRAINT tasks_parent_not_self
  CHECK (parent_id IS NULL OR parent_id <> id);

ALTER TABLE public.bugs DROP CONSTRAINT IF EXISTS bugs_parent_must_be_root;
ALTER TABLE public.bugs DROP CONSTRAINT IF EXISTS bugs_parent_not_self;
ALTER TABLE public.bugs
  ADD CONSTRAINT bugs_parent_not_self
  CHECK (parent_id IS NULL OR parent_id <> id);

ALTER TABLE public.ops_actions DROP CONSTRAINT IF EXISTS ops_actions_parent_must_be_root;
ALTER TABLE public.ops_actions DROP CONSTRAINT IF EXISTS ops_actions_parent_not_self;
ALTER TABLE public.ops_actions
  ADD CONSTRAINT ops_actions_parent_not_self
  CHECK (parent_id IS NULL OR parent_id <> id);
