-- MindBack 看板数据库 v2 — 表结构变更 + 真实数据回填
-- 来源：《MindBack 看板数据库 — 变更说明 + 完整数据 v2》
-- 依赖：已执行 20260408170000_mindback_v2_phases_versions.sql

-- ---------------------------------------------------------------------------
-- Step 3：milestones 加 phase_id 并回填
-- ---------------------------------------------------------------------------
ALTER TABLE public.milestones
  ADD COLUMN IF NOT EXISTS phase_id int REFERENCES public.phases(id);

UPDATE public.milestones SET phase_id = 1 WHERE id IN ('M1','M2','M3','M4','M5');
UPDATE public.milestones SET phase_id = 2 WHERE id IN ('M6','M7','M8');
UPDATE public.milestones SET phase_id = 3 WHERE id IN ('M9','M10');

-- ---------------------------------------------------------------------------
-- Step 4：tasks version(text) → version_id(FK)
-- ---------------------------------------------------------------------------
ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS version_id int REFERENCES public.versions(id);

-- 通过 versions.slug 回填（旧字段存在时才执行）
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='tasks' AND column_name='version'
  ) THEN
    UPDATE public.tasks
    SET version_id = v.id
    FROM public.versions v
    WHERE public.tasks.version = v.slug AND public.tasks.version <> '';

    ALTER TABLE public.tasks DROP COLUMN IF EXISTS version;
  END IF;
END $$;

-- 按 v2 文档提供的真实数据“完整重建 tasks”
-- 注意：会清空 tasks 并重置序列（如你已经有生产增量数据，请先确认再执行）
TRUNCATE public.tasks RESTART IDENTITY CASCADE;

INSERT INTO public.tasks
  (id, name, priority, platforms, owners, status, task_type, source,
   note, version_id, this_week, milestone_id, is_archived)
OVERRIDING SYSTEM VALUE
VALUES
-- ── 本周冲刺任务（this_week = true）──────────────────────────
(28, '共享频道客户端开发',       'p0', ARRAY['ios'],
  ARRAY['黄镇威'],      'prog', 'task', 'internal',
  '', NULL, true, 'M5', false),

(4,  '划词评论 - 开发/交互推进', 'p1', ARRAY['ios'],
  ARRAY['择良','芒格','小依'], 'prog', 'task', 'internal',
  '目标4/17上线', NULL, true, 'M4', false),

(6,  '共享频道后端推进',          'p1', ARRAY['backend'],
  ARRAY['尼卡'],        'prog', 'task', 'internal',
  '目标4/27上线', NULL, true, 'M5', false),

(25, 'MindBack支持展示图片',      'p0', ARRAY['ios'],
  ARRAY['择良'],        'prog', 'task', 'internal',
  '', 2, true, 'M3', false),

(2,  'Web 全面开放',              'p0', ARRAY['web'],
  ARRAY['李天宇'],      'prog', 'task', 'internal',
  '', NULL, true, 'M2', false),

(17, '广告可投放 - CAID接入 + 三方联调', 'p0', ARRAY['ios','backend'],
  ARRAY['亚修','尼卡'], 'prog', 'task', 'internal',
  '亚修提供CAID · 尼卡提供接口 · 联调完成后广告正式可投', 1, true, 'M2', false),

(26, '问一问-prompt优化',         'p1', ARRAY['ai'],
  ARRAY['望之'],        'prog', 'task', 'internal',
  '平衡关联与洞察', 2, true, 'M3', false),

(27, 'iOS APP评价弹窗',           'p0', ARRAY['ios'],
  ARRAY['黄镇威'],      'ns',   'task', 'internal',
  '在MindBack/周记模块新增评价弹窗，月章/周记阅读停留3-5s后触发', 2, true, 'M3', false),

(30, '完整数据看板',              'p1', ARRAY['backend','web'],
  ARRAY['小依','尼卡','望之','凯隐'], 'ns', 'task', 'internal',
  '新增用户数趋势 + 用户内容行为分析（文字/语音/图片占比、交互习惯）', NULL, true, NULL, false),

(22, 'UBA打点',                   'p0', ARRAY['ios'],
  ARRAY['择良'],        'prog', 'task', 'internal',
  '每周新增10-20个打点', NULL, true, NULL, false),

(29, 'APM打点（语音等）',          'p0', ARRAY['ios'],
  ARRAY['择良'],        'prog', 'task', 'internal',
  '', NULL, true, NULL, false),

-- ── 进行中/未开始（非本周重点）────────────────────────────────
(1,  '个性化设置上线（共情/幽默/批判）', 'p0', ARRAY['ios'],
  ARRAY['黄镇威'],      'done', 'task', 'internal',
  'AI后端已对齐，交互修改中', 1, false, 'M2', false),

(3,  'MD 格式渲染升级',           'p2', ARRAY['ios'],
  ARRAY['择良','张淙琳'], 'ns', 'task', 'internal',
  '顺延至下下周，不在本周冲刺范围', 2, false, 'M3', false),

(5,  '消息置顶',                  'p1', ARRAY['ios'],
  ARRAY['择良'],        'prog', 'task', 'internal',
  '', 2, false, 'M3', false),

(8,  '搜狗键盘卡死-主页面',        'p0', ARRAY['ios'],
  ARRAY['择良'],        'done', 'bug',  'user',
  '外测包已发出；还原默认高度后卡死消失，偶发崩溃可继续', 1, false, 'M2', false),

(9,  '语音转文字 5分钟问题',       'p1', ARRAY['ios'],
  ARRAY['黄镇威'],      'done', 'task', 'user',
  '纯客户端问题，黄镇威负责解决，不需要后端 API', 1, false, 'M2', false),

(10, '周记漏发修复',              'p0', ARRAY['ai'],
  ARRAY['望之'],        'prog', 'bug',  'internal',
  '审核拦截、重发bug，需明确报警链路', NULL, false, NULL, false),

(11, '广告可投放 - 接口就绪',     'p0', ARRAY['backend'],
  ARRAY['尼卡'],        'done', 'task', 'internal',
  '', 1, false, 'M2', false),

(12, '热云SDK接入',               'p1', ARRAY['ios'],
  ARRAY['择良'],        'done', 'task', 'internal',
  '', 1, false, 'M2', false),

(13, '碎片补录支持图片',           'p1', ARRAY['ios'],
  ARRAY['黄镇威'],      'done', 'task', 'internal',
  '', 1, false, 'M2', false),

(15, '消息定位跳转',              'p0', ARRAY['ios'],
  ARRAY['黄镇威'],      'done', 'task', 'internal',
  '', 1, false, 'M2', false),

(16, '热云SDK联调',               'p1', ARRAY['ios'],
  ARRAY['择良'],        'prog', 'task', 'internal',
  '配合热云SDK接入后的联调验证', 1, false, 'M2', false),

(18, '导出一天的记录（精美样式）', 'p1', ARRAY['ios','android'],
  ARRAY[]::text[],      'ns',   'task', 'user',
  '用户希望以好看的方式导出单日记录，偏分享/展示场景', NULL, false, NULL, false),

(19, '批量导出记录（数据安全备份）','p1', ARRAY['ios','android'],
  ARRAY[]::text[],      'ns',   'task', 'user',
  '用户希望能导出全部记录以确保数据安全，偏备份/迁移', NULL, false, NULL, false),

(20, '删除回收箱',                'p2', ARRAY['ios','android'],
  ARRAY[]::text[],      'ns',   'task', 'user',
  '删除内容后进入回收箱，支持找回', NULL, false, NULL, false),

(21, 'minback/问一问卡片里图片定位','p2', ARRAY['ios'],
  ARRAY['择良'],        'done', 'task', 'internal',
  '', 1, false, 'M2', false),

(23, '键盘卡住-搜索页面',         'p0', ARRAY['ios'],
  ARRAY['择良'],        'done', 'bug',  'internal',
  '', 1, false, 'M2', false),

(24, 'OB优化',                    'p1', ARRAY['ios'],
  ARRAY['黄镇威'],      'ns',   'task', 'internal',
  '', NULL, false, 'M3', false);

SELECT setval(pg_get_serial_sequence('public.tasks','id'), COALESCE((SELECT MAX(id) FROM public.tasks), 1));

-- ---------------------------------------------------------------------------
-- Step 5：backlog 加 phase_id 并用 v2 文档重建 21 条真实数据
-- ---------------------------------------------------------------------------
ALTER TABLE public.backlog
  ADD COLUMN IF NOT EXISTS phase_id int REFERENCES public.phases(id);

TRUNCATE public.backlog RESTART IDENTITY CASCADE;

INSERT INTO public.backlog (id, name, priority, platforms, note, source, phase_id, is_archived)
OVERRIDING SYSTEM VALUE
VALUES
-- ── P1 优先级 ─────────────────────────────────────────────────
(1,  '音视频解析交互方案（额度分配）', 'p1', ARRAY['ios','android'],
  '额度分配交互设计；看本周是否安排', 'internal', 1, false),

(2,  'Onboarding AI 回复设计',        'p1', ARRAY['ios','android'],
  '第一条记录高优队列，30s~2min回复，内容暗示异步特性', 'internal', 1, false),

(3,  '分享功能重设计',                'p1', ARRAY['ios','android'],
  '短内容→卡片；长内容→多图/H5；不做长图；与link preview/周记月章 cluster规划', 'internal', 2, false),

(7,  '导出一天的记录（精美样式）',    'p1', ARRAY['ios','android'],
  '用户以好看的方式导出单日记录，偏分享/展示场景', 'user', 3, false),

(8,  '批量导出记录（数据安全备份）',  'p1', ARRAY['ios','android'],
  '全量导出，偏备份/迁移', 'user', 3, false),

(12, '列表页支持问一问',              'p1', ARRAY['ios','android','web'],
  '', 'internal', 1, false),

-- ── P2 优先级 ─────────────────────────────────────────────────
(4,  'To-Do 卡片体验设计',            'p2', ARRAY['ios','android'],
  '完成状态打勾 + 完成后留存时间线 + 与洞察卡片/月章差异化呈现', 'internal', 2, false),

(5,  '支持发送位置',                  'p2', ARRAY['ios','android'],
  '', 'user', 4, false),

(6,  '支持记录心情',                  'p2', ARRAY['ios','android'],
  '手动打情绪标签，月历热力图聚合', 'user', 2, false),

(9,  '删除回收箱',                    'p2', ARRAY['ios','android'],
  '删除内容后进回收箱，支持找回', 'user', 3, false),

(11, '消息封存功能',                  'p2', ARRAY['ios','android','backend'],
  '结合节假日活动；参见里程碑M7（520封存活动）', 'internal', 2, false),

(13, '内容+锚点 支持跳转查看',        'p2', ARRAY['ios','android','web'],
  '', 'internal', 2, false),

(14, 'app支持密码',                   'p2', ARRAY['ios','android','web'],
  '', 'internal', 4, false),

(15, '记忆点兑换',                    'p2', ARRAY['ios','android','web'],
  '各个功能的记忆点建设（live图66/88积分、音视频解析）；商业化体系核心', 'internal', 4, false),

(16, '语音功能优化',                  'p2', ARRAY['ios','android','web'],
  '', 'internal', 2, false),

(17, 'MindBack列表筛选',              'p2', ARRAY['ios','android','web'],
  '', 'internal', 3, false),

(18, '小组件',                        'p2', ARRAY['ios','android'],
  '', 'internal', 3, false),

(19, 'OB优化',                        'p2', ARRAY['ios','android'],
  '新增新手用户引导交互', 'internal', 1, false),

(20, '通知优化',                      'p2', ARRAY['ios','android'],
  '安卓接入通知，通用通知个性化', 'internal', 2, false),

(21, '多端登陆能力',                  'p2', ARRAY['ios','android'],
  '上线并支持用记忆点兑换', 'internal', 4, false);

SELECT setval(pg_get_serial_sequence('public.backlog','id'), COALESCE((SELECT MAX(id) FROM public.backlog), 1));

