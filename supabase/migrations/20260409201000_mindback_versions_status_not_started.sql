-- MindBack 看板数据库 v2.6 — versions 增加“未开始”状态
-- 说明：前端需要版本状态包含：未开始 / 开发中 / 测试中 / 已提审 / 已发布

DO $$
DECLARE
  chk_name text;
BEGIN
  SELECT con.conname INTO chk_name
  FROM pg_constraint con
  JOIN pg_class rel ON rel.oid = con.conrelid
  JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
  WHERE nsp.nspname = 'public'
    AND rel.relname = 'versions'
    AND con.contype = 'c'
    AND pg_get_constraintdef(con.oid) LIKE '%status IN (%';

  IF chk_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.versions DROP CONSTRAINT IF EXISTS %I', chk_name);
  END IF;

  ALTER TABLE public.versions
    ADD CONSTRAINT versions_status_check
    CHECK (status IN ('not_started','dev','testing','submitted','released'));
END $$;

