-- MindBack 看板数据库 v2.3 — 允许管理员写 phases（RLS）
-- 说明：里程碑 Tab 编辑“大目标/时间范围”写入 public.phases，需要管理员写权限
DO $$
DECLARE
  admin_uid uuid := '618d276a-fbba-4c40-a261-6567c00b0b5f';
BEGIN
  DROP POLICY IF EXISTS "admin write" ON public.phases;
  EXECUTE format(
    'CREATE POLICY "admin write" ON public.phases
      FOR ALL
      TO authenticated
      USING (auth.uid() = %L::uuid)
      WITH CHECK (auth.uid() = %L::uuid);',
    admin_uid, admin_uid
  );
END $$;

