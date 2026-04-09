-- MindBack v2.3 — 任务支持按端分别关联版本（iOS / Android / Web）
-- 说明：保留 version_id 作为兼容字段；前端会同时维护三端可选 FK。
-- 执行后请在 Supabase SQL Editor 运行（与仓库迁移文件一致）。

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS version_ios_id int REFERENCES public.versions(id),
  ADD COLUMN IF NOT EXISTS version_android_id int REFERENCES public.versions(id),
  ADD COLUMN IF NOT EXISTS version_web_id int REFERENCES public.versions(id);

-- 将历史 version_id 按 versions.platform 回填到对应列（仅当该端列为空时写入）
UPDATE public.tasks t
SET version_ios_id = t.version_id
FROM public.versions v
WHERE t.version_id IS NOT NULL
  AND t.version_id = v.id
  AND v.platform = 'ios'
  AND t.version_ios_id IS NULL;

UPDATE public.tasks t
SET version_android_id = t.version_id
FROM public.versions v
WHERE t.version_id IS NOT NULL
  AND t.version_id = v.id
  AND v.platform = 'android'
  AND t.version_android_id IS NULL;

UPDATE public.tasks t
SET version_web_id = t.version_id
FROM public.versions v
WHERE t.version_id IS NOT NULL
  AND t.version_id = v.id
  AND v.platform = 'web'
  AND t.version_web_id IS NULL;
