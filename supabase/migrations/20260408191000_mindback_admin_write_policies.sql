-- MindBack 看板数据库 v2.2 — 允许管理员账号写入（RLS）
-- 背景：前端使用 anon key 读；管理员登录后用 access_token 写
-- 规则：仅允许指定 auth.uid() 写入；其余保持公开只读
--
-- 重要：把下面这个 UUID 改成你的管理员 user id（如果已经是这个，则无需改）
DO $$
DECLARE
  admin_uid uuid := '618d276a-fbba-4c40-a261-6567c00b0b5f';
BEGIN
  -- tasks
  DROP POLICY IF EXISTS "admin write" ON public.tasks;
  EXECUTE format(
    'CREATE POLICY "admin write" ON public.tasks
      FOR ALL
      TO authenticated
      USING (auth.uid() = %L::uuid)
      WITH CHECK (auth.uid() = %L::uuid);',
    admin_uid, admin_uid
  );

  -- bugs
  DROP POLICY IF EXISTS "admin write" ON public.bugs;
  EXECUTE format(
    'CREATE POLICY "admin write" ON public.bugs
      FOR ALL
      TO authenticated
      USING (auth.uid() = %L::uuid)
      WITH CHECK (auth.uid() = %L::uuid);',
    admin_uid, admin_uid
  );

  -- ops_actions
  DROP POLICY IF EXISTS "admin write" ON public.ops_actions;
  EXECUTE format(
    'CREATE POLICY "admin write" ON public.ops_actions
      FOR ALL
      TO authenticated
      USING (auth.uid() = %L::uuid)
      WITH CHECK (auth.uid() = %L::uuid);',
    admin_uid, admin_uid
  );

  -- backlog
  DROP POLICY IF EXISTS "admin write" ON public.backlog;
  EXECUTE format(
    'CREATE POLICY "admin write" ON public.backlog
      FOR ALL
      TO authenticated
      USING (auth.uid() = %L::uuid)
      WITH CHECK (auth.uid() = %L::uuid);',
    admin_uid, admin_uid
  );

  -- versions（允许切状态/改备注）
  DROP POLICY IF EXISTS "admin write" ON public.versions;
  EXECUTE format(
    'CREATE POLICY "admin write" ON public.versions
      FOR ALL
      TO authenticated
      USING (auth.uid() = %L::uuid)
      WITH CHECK (auth.uid() = %L::uuid);',
    admin_uid, admin_uid
  );

  -- milestones（允许切状态/写延期说明）
  DROP POLICY IF EXISTS "admin write" ON public.milestones;
  EXECUTE format(
    'CREATE POLICY "admin write" ON public.milestones
      FOR ALL
      TO authenticated
      USING (auth.uid() = %L::uuid)
      WITH CHECK (auth.uid() = %L::uuid);',
    admin_uid, admin_uid
  );

  -- board_overview（允许改月目标/KPI/预告）
  DROP POLICY IF EXISTS "admin write" ON public.board_overview;
  EXECUTE format(
    'CREATE POLICY "admin write" ON public.board_overview
      FOR ALL
      TO authenticated
      USING (auth.uid() = %L::uuid)
      WITH CHECK (auth.uid() = %L::uuid);',
    admin_uid, admin_uid
  );
END $$;

