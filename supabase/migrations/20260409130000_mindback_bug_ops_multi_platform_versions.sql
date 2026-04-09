-- MindBack v2.4 — Bug/运营支持按端分别关联版本（iOS / Android / Web）
-- 说明：
-- - bugs：需要关联版本（必选能力）
-- - ops_actions：可选关联版本，但系统需支持
-- - 前端会维护 version_*_id；bugs 也会同步 platforms（用于 Tag 展示等）

ALTER TABLE public.bugs
  ADD COLUMN IF NOT EXISTS version_ios_id int REFERENCES public.versions(id),
  ADD COLUMN IF NOT EXISTS version_android_id int REFERENCES public.versions(id),
  ADD COLUMN IF NOT EXISTS version_web_id int REFERENCES public.versions(id),
  ADD COLUMN IF NOT EXISTS version_id int REFERENCES public.versions(id);

ALTER TABLE public.ops_actions
  ADD COLUMN IF NOT EXISTS version_ios_id int REFERENCES public.versions(id),
  ADD COLUMN IF NOT EXISTS version_android_id int REFERENCES public.versions(id),
  ADD COLUMN IF NOT EXISTS version_web_id int REFERENCES public.versions(id),
  ADD COLUMN IF NOT EXISTS version_id int REFERENCES public.versions(id);

