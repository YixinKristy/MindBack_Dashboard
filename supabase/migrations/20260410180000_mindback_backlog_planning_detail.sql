-- Backlog：规划明细（类型、关联版本、负责人等），便于转入任务/Bug/运营并挂版本

ALTER TABLE public.backlog
  ADD COLUMN IF NOT EXISTS item_kind text DEFAULT 'task';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'backlog_item_kind_check'
  ) THEN
    ALTER TABLE public.backlog
      ADD CONSTRAINT backlog_item_kind_check
      CHECK (item_kind IN ('task','bug','ops'));
  END IF;
END $$;

ALTER TABLE public.backlog
  ADD COLUMN IF NOT EXISTS version_ios_id int REFERENCES public.versions(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS version_android_id int REFERENCES public.versions(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS version_web_id int REFERENCES public.versions(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS version_id int REFERENCES public.versions(id) ON DELETE SET NULL;

ALTER TABLE public.backlog
  ADD COLUMN IF NOT EXISTS owners text[] DEFAULT '{}';

ALTER TABLE public.backlog
  ADD COLUMN IF NOT EXISTS due_date text DEFAULT '';

ALTER TABLE public.backlog
  ADD COLUMN IF NOT EXISTS moved_to_bug_id int REFERENCES public.bugs(id) ON DELETE SET NULL;

ALTER TABLE public.backlog
  ADD COLUMN IF NOT EXISTS moved_to_ops_id int REFERENCES public.ops_actions(id) ON DELETE SET NULL;
