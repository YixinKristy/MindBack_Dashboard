-- 功能 / Bug / 运营：主项与子项（单层：parent 必须为根项）

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
ALTER TABLE public.tasks ADD CONSTRAINT tasks_parent_must_be_root CHECK (
  parent_id IS NULL OR EXISTS (
    SELECT 1 FROM public.tasks p WHERE p.id = tasks.parent_id AND p.parent_id IS NULL
  )
);

ALTER TABLE public.bugs DROP CONSTRAINT IF EXISTS bugs_parent_must_be_root;
ALTER TABLE public.bugs ADD CONSTRAINT bugs_parent_must_be_root CHECK (
  parent_id IS NULL OR EXISTS (
    SELECT 1 FROM public.bugs p WHERE p.id = bugs.parent_id AND p.parent_id IS NULL
  )
);

ALTER TABLE public.ops_actions DROP CONSTRAINT IF EXISTS ops_actions_parent_must_be_root;
ALTER TABLE public.ops_actions ADD CONSTRAINT ops_actions_parent_must_be_root CHECK (
  parent_id IS NULL OR EXISTS (
    SELECT 1 FROM public.ops_actions p WHERE p.id = ops_actions.parent_id AND p.parent_id IS NULL
  )
);
