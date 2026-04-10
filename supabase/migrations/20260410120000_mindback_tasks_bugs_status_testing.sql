-- 功能任务、Bug：增加「测试中」状态（与前端值 test 对齐；tasks 表初始 schema 已含 test，此处主要扩展 bugs）

DO $$
DECLARE
  chk_name text;
BEGIN
  -- bugs：扩展 status 允许 test
  ALTER TABLE public.bugs DROP CONSTRAINT IF EXISTS bugs_status_check;

  SELECT con.conname INTO chk_name
  FROM pg_constraint con
  JOIN pg_class rel ON rel.oid = con.conrelid
  JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
  WHERE nsp.nspname = 'public'
    AND rel.relname = 'bugs'
    AND con.contype = 'c'
    AND pg_get_constraintdef(con.oid) LIKE '%status IN (%'
  LIMIT 1;

  IF chk_name IS NOT NULL AND chk_name <> 'bugs_status_check' THEN
    EXECUTE format('ALTER TABLE public.bugs DROP CONSTRAINT IF EXISTS %I', chk_name);
  END IF;

  ALTER TABLE public.bugs
    ADD CONSTRAINT bugs_status_check
    CHECK (status IN ('ns','prog','test','done','risk','block'));

  -- tasks：若历史库约束不含 test，则重建（幂等）
  ALTER TABLE public.tasks DROP CONSTRAINT IF EXISTS tasks_status_check;

  SELECT con.conname INTO chk_name
  FROM pg_constraint con
  JOIN pg_class rel ON rel.oid = con.conrelid
  JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
  WHERE nsp.nspname = 'public'
    AND rel.relname = 'tasks'
    AND con.contype = 'c'
    AND pg_get_constraintdef(con.oid) LIKE '%status IN (%'
  LIMIT 1;

  IF chk_name IS NOT NULL AND chk_name <> 'tasks_status_check' THEN
    EXECUTE format('ALTER TABLE public.tasks DROP CONSTRAINT IF EXISTS %I', chk_name);
  END IF;

  ALTER TABLE public.tasks
    ADD CONSTRAINT tasks_status_check
    CHECK (status IN ('ns','prog','test','risk','block','done'));
END $$;
