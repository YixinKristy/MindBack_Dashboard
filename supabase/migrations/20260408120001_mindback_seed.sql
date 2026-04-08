-- MindBack 看板 — 初始种子数据 + 序列校准 + milestone_id 建议更新
-- 依赖：已执行 20260408120000_mindback_core_schema.sql
-- 重复执行前请先清空相关表（注意外键：先 tasks 再 milestones，或 TRUNCATE ... CASCADE）

-- ---------------------------------------------------------------------------
-- 5.1 milestones
-- ---------------------------------------------------------------------------
INSERT INTO public.milestones (id, num, month, date_short, date_full, title, tags, cost, status, features, sort_order) VALUES
('M1',  'M1',  'done', '3/16', '3/16–3/20',       'Live 上线',
  ARRAY['ios','android','web'], '—', 'done',
  'Live图混合上传、个人日历、基础稳定性', 1),

('M2',  'M2',  '4月',  '3/30', '3/30–4/3（本周）',
  '广告可投放 · Web 全面开放 · 个性化设置上线',
  ARRAY['ios','android','web','backend'], '当前冲刺', 'current',
  '广告CAID接入+三方联调（亚修+尼卡）· 个性化设置上线（黄镇威）· Web全面开放（李天宇）· 列表卡片显示图片（择良）· 搜狗键盘iOS卡死修复（择良，已复现）· 消息定位（黄镇威）· 热云SDK联调（择良）', 2),

('M3',  'M3',  '4月',  '4/6',  '4/6–4/10',        '功能补全节点',
  ARRAY['ios','android'], '低', 'plan',
  '消息置顶、MB列表页问一问、OB引导、ToDo消除、MD格式渲染升级（顺延自M2）', 3),

('M4',  'M4',  '4月',  '4/13', '4/13–4/17',       '划词评论上线（个人频道）',
  ARRAY['ios','android'], 'iOS 2–3周（开发中）', 'plan',
  '文字高亮、inline标记、底部弹窗、存档/分享', 4),

('M5',  'M5',  '4月',  '4/27', '4/27–4/30',       '共享频道上线',
  ARRAY['ios','android','web','backend'], '累计约6周', 'plan',
  '频道创建、内容分享至频道、频道展示页', 5),

('M6',  'M6',  '5月',  '5/5',  '5/5–5/9',         'iOS 小组件 v1 上线',
  ARRAY['ios','ai','backend'], 'iOS 3周 + 后端3–5天', 'plan',
  '小/中尺寸：回响+快记入口、空状态、夜间模式', 6),

('M7',  'M7',  '5月',  '5/20', '5/20（520活动）',  '「给未来的自己」封存活动',
  ARRAY['ios','android','backend'], '约1–1.5周', 'campaign',
  '消息封存（时间胶囊）+ 活动页 + 解锁通知', 7),

('M8',  'M8',  '5月',  '5月中', '5月中下旬',        '心情地图 MVP',
  ARRAY['ios','android','backend','ai'], '约2–3周', 'plan',
  '记录时手动打情绪标签、按月聚合日历热力图', 8),

('M9',  'M9',  '6月',  '6月初', '5月底–6月初',      'Android 小组件 v1',
  ARRAY['android','backend'], '约3–4周（原生Kotlin）', 'plan',
  '跟进iOS小组件内容，WebView不可复用需独立开发', 9),

('M10', 'M10', '6月',  '6月底', '6月底',            '「半年见」用户总结',
  ARRAY['ios','android','web','ai','backend'], 'AI侧2–3周+后端1周+前端1周', 'plan',
  '6个月记录AI聚合+个性化生成+展示/分享；封存消息解锁', 10)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 5.2 tasks
-- ---------------------------------------------------------------------------
INSERT INTO public.tasks (id, name, priority, platforms, owners, status, task_type, source, note, version, this_week)
OVERRIDING SYSTEM VALUE
VALUES
(1,  '个性化设置上线（共情/幽默/批判）', 'p0', ARRAY['ios'],
  ARRAY['黄镇威'], 'done', 'task', 'internal',
  'AI后端已对齐，交互修改中', 'ios-125', false),

(2,  'Web 全面开放', 'p0', ARRAY['web'],
  ARRAY['李天宇'], 'prog', 'task', 'internal',
  '', '', true),

(3,  'MD 格式渲染升级', 'p2', ARRAY['ios'],
  ARRAY['择良','张淙琳'], 'ns', 'task', 'internal',
  '顺延至下下周，不在本周冲刺范围', 'ios-126', false),

(4,  '划词评论 - 开发/交互推进', 'p1', ARRAY['ios'],
  ARRAY['择良','芒格','小依'], 'prog', 'task', 'internal',
  '目标4/17上线', '', true),

(5,  '消息置顶', 'p1', ARRAY['ios'],
  ARRAY['择良'], 'prog', 'task', 'internal',
  '', 'ios-126', false),

(6,  '共享频道后端推进', 'p1', ARRAY['backend'],
  ARRAY['尼卡'], 'prog', 'task', 'internal',
  '目标4/27上线', '', true),

(8,  '搜狗键盘卡死-主页面', 'p0', ARRAY['ios'],
  ARRAY['择良'], 'done', 'bug', 'user',
  '外测包已发出；还原默认高度后卡死消失，偶发崩溃可继续；需跟进「高度调整为何导致卡死」', 'ios-125', false),

(9,  '语音转文字 5分钟问题', 'p1', ARRAY['ios'],
  ARRAY['黄镇威'], 'done', 'task', 'user',
  '纯客户端问题，黄镇威负责解决，不需要后端 API', 'ios-125', false),

(10, '周记漏发修复', 'p0', ARRAY['ai'],
  ARRAY['望之'], 'prog', 'bug', 'internal',
  '审核拦截、重发bug，需明确报警链路', '', false),

(11, '广告可投放 - 接口就绪', 'p0', ARRAY['backend'],
  ARRAY['尼卡'], 'done', 'task', 'internal',
  '', 'ios-125', false),

(12, '热云SDK接入', 'p1', ARRAY['ios'],
  ARRAY['择良'], 'done', 'task', 'internal',
  '', 'ios-125', false),

(13, '碎片补录支持图片', 'p1', ARRAY['ios'],
  ARRAY['黄镇威'], 'done', 'task', 'internal',
  '', 'ios-125', false),

(15, '消息定位跳转', 'p0', ARRAY['ios'],
  ARRAY['黄镇威'], 'done', 'task', 'internal',
  '', 'ios-125', false),

(16, '热云SDK联调', 'p1', ARRAY['ios'],
  ARRAY['择良'], 'prog', 'task', 'internal',
  '配合热云SDK接入后的联调验证', 'ios-125', false),

(17, '广告可投放 - CAID接入 + 三方联调', 'p0', ARRAY['ios','backend'],
  ARRAY['亚修','尼卡'], 'prog', 'task', 'internal',
  '亚修提供CAID · 尼卡提供接口 · 联调完成后广告正式可投', 'ios-125', true),

(18, '导出一天的记录（精美样式）', 'p1', ARRAY['ios','android'],
  ARRAY[]::text[], 'ns', 'task', 'user',
  '用户希望以好看的方式导出单日记录，偏分享/展示场景', '', false),

(19, '批量导出记录（数据安全备份）', 'p1', ARRAY['ios','android'],
  ARRAY[]::text[], 'ns', 'task', 'user',
  '用户希望能导出全部记录以确保数据安全，偏备份/迁移场景', '', false),

(20, '删除回收箱', 'p2', ARRAY['ios','android'],
  ARRAY[]::text[], 'ns', 'task', 'user',
  '删除内容后进入回收箱，支持找回', '', false),

(21, 'minback/问一问卡片里图片定位', 'p2', ARRAY['ios'],
  ARRAY['择良'], 'done', 'task', 'internal',
  '', 'ios-125', false),

(22, 'UBA打点', 'p0', ARRAY['ios'],
  ARRAY['择良'], 'prog', 'task', 'internal',
  '每周新增10-20个打点', '', true),

(23, '键盘卡住-搜索页面', 'p0', ARRAY['ios'],
  ARRAY['择良'], 'done', 'bug', 'internal',
  '', 'ios-125', false),

(24, 'OB优化', 'p1', ARRAY['ios'],
  ARRAY['黄镇威'], 'ns', 'task', 'internal',
  '', '', false),

(25, 'MindBack支持展示图片', 'p0', ARRAY['ios'],
  ARRAY['择良'], 'prog', 'task', 'internal',
  '', 'ios-126', true),

(26, '问一问-prompt优化', 'p1', ARRAY['ai'],
  ARRAY['望之'], 'prog', 'task', 'internal',
  '平衡关联与洞察', 'ios-126', true),

(27, 'iOS APP评价弹窗', 'p0', ARRAY['ios'],
  ARRAY['黄镇威'], 'ns', 'task', 'internal',
  '在MindBack/周记模块新增评价弹窗', 'ios-126', true),

(28, '共享频道客户端开发', 'p0', ARRAY['ios'],
  ARRAY['黄镇威'], 'prog', 'task', 'internal',
  '', '', true),

(29, 'APM打点（语音等）', 'p0', ARRAY['ios'],
  ARRAY['择良'], 'prog', 'task', 'internal',
  '', '', true),

(30, '完整数据看板', 'p1', ARRAY['backend','web'],
  ARRAY['小依','尼卡','望之','凯隐'], 'ns', 'task', 'internal',
  '新增用户数趋势 + 用户内容行为分析（文字/语音/图片占比、交互习惯）；当前看板尚未接入后端真实数据', '', true)
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('public.tasks', 'id'), COALESCE((SELECT MAX(id) FROM public.tasks), 1));

-- ---------------------------------------------------------------------------
-- 5.3 bugs
-- ---------------------------------------------------------------------------
INSERT INTO public.bugs (id, severity, name, platforms, owners, status, source, note)
OVERRIDING SYSTEM VALUE
VALUES
(1, 's0', '语音转文字长按 5分钟出现"嗯"后卡顿',
  ARRAY['android'], ARRAY['高胜禹'], 'done', 'user', '等后端接口'),

(2, 's0', '搜狗键盘：调整键盘高度后进入 App 卡死',
  ARRAY['android'], ARRAY['高胜禹'], 'done', 'user',
  '外测包已发；还原默认高度后卡死消失，偶发崩溃可继续；待查：高度调整触发卡死的根本原因'),

(3, 's1', 'MB卡片内容不存在时直接显示刷新而非加载中',
  ARRAY['ios'], ARRAY['择良'], 'done', 'user', ''),

(4, 's1', '5000字长文字导致卡顿',
  ARRAY['android'], ARRAY['高胜禹'], 'done', 'internal', ''),

(5, 's1', 'MD渲染升级兼容性风险',
  ARRAY['ios'], ARRAY['择良'], 'risk', 'internal', '有风险标记'),

(6, 's0', '豆包键盘：进入 App 依然卡死',
  ARRAY['android'], ARRAY['高胜禹'], 'done', 'user',
  '1位用户已反馈；本次修复未覆盖，需独立复现排查'),

(7, 's0', '搜狗键盘 iOS：进入 App 卡死（已复现）',
  ARRAY['ios'], ARRAY['择良'], 'done', 'user',
  '周一定位根因并修复；消息定位同步完成')
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('public.bugs', 'id'), COALESCE((SELECT MAX(id) FROM public.bugs), 1));

-- ---------------------------------------------------------------------------
-- 5.4 people
-- ---------------------------------------------------------------------------
INSERT INTO public.people (name, role, workload) VALUES
('择良',  'iOS 前端',       95),
('黄镇威', 'iOS 前端',       90),
('高胜禹', 'Android 前端',   85),
('亚修',  'iOS 前端',       70),
('尼卡',  '后端 / Web后端',  90),
('望之',  'AI 后端',        60),
('凯隐',  'AI 后端',        40),
('李天宇', 'Web 前端',       65),
('张淙琳', 'Web 前端',       50),
('祥福',  'Web 后端',       45)
ON CONFLICT (name) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 5.5 ops_actions
-- ---------------------------------------------------------------------------
INSERT INTO public.ops_actions (id, category, name, status, target_date, channel, owners, note)
OVERRIDING SYSTEM VALUE
VALUES
(1, 'merch',    '毛绒挂件',
  'prog', '待定', '线下活动奖品', ARRAY[]::text[], ''),

(2, 'merch',    '贴纸',
  'prog', '待定', '线下活动奖品', ARRAY[]::text[], ''),

(3, 'collab',   '科技署 × MindBack「个人数字博物馆」',
  'plan', '4月', '小红书', ARRAY['PM'],
  '主题：把 MindBack 当作个人数字博物馆，探索自我'),

(4, 'campaign', '春季声音收集活动',
  'plan', '待定', '', ARRAY['PM'], '宣传录音功能'),

(5, 'campaign', 'Live 图专题宣传',
  'prog', '进行中', '', ARRAY['PM'], '')
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('public.ops_actions', 'id'), COALESCE((SELECT MAX(id) FROM public.ops_actions), 1));

-- ---------------------------------------------------------------------------
-- 5.6 backlog
-- ---------------------------------------------------------------------------
INSERT INTO public.backlog (id, name, priority, platforms, note, source)
OVERRIDING SYSTEM VALUE
VALUES
(1,  '音视频解析交互方案（额度分配）',  'p1', ARRAY['ios','android'],
  '额度分配交互设计；看本周是否安排', 'internal'),

(2,  'Onboarding AI 回复设计',        'p1', ARRAY['ios','android'],
  '第一条记录高优队列，30s~2min回复，内容暗示异步特性', 'internal'),

(3,  '分享功能重设计',                 'p1', ARRAY['ios','android'],
  '短内容→卡片；长内容→多图/H5；不做长图；与link preview/周记月章 cluster规划', 'internal'),

(4,  'To-Do 卡片体验设计',             'p2', ARRAY['ios','android'],
  '完成状态打勾 + 完成后留存时间线 + 与洞察卡片/月章差异化呈现', 'internal'),

(5,  '支持发送位置',                   'p2', ARRAY['ios','android'],
  '', 'user'),

(6,  '支持记录心情',                   'p2', ARRAY['ios','android'],
  '手动打情绪标签，月历热力图聚合', 'user'),

(7,  '导出一天的记录（精美样式）',      'p1', ARRAY['ios','android'],
  '用户以好看的方式导出单日记录，偏分享/展示场景', 'user'),

(8,  '批量导出记录（数据安全备份）',    'p1', ARRAY['ios','android'],
  '全量导出，偏备份/迁移', 'user'),

(9,  '删除回收箱',                     'p2', ARRAY['ios','android'],
  '删除内容后进回收箱，支持找回', 'user'),

(11, '消息封存功能',                   'p2', ARRAY['ios','android','backend'],
  '结合节假日活动；参见里程碑M7', 'internal'),

(12, '列表页支持问一问',               'p1', ARRAY['ios','android','web'],
  '', 'internal'),

(13, '内容+锚点 支持跳转查看',         'p2', ARRAY['ios','android','web'],
  '', 'internal')
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('public.backlog', 'id'), COALESCE((SELECT MAX(id) FROM public.backlog), 1));

-- ---------------------------------------------------------------------------
-- 5.7 tech_debt
-- ---------------------------------------------------------------------------
-- 无唯一键：重复执行本段会重复插入；重灌前可执行 TRUNCATE public.tech_debt RESTART IDENTITY;
INSERT INTO public.tech_debt (name, owner, progress, note) VALUES
('APM 打点（成功/失败）',       '择良', 30,  '本周优先稳定性，下周继续'),
('热云 SDK 接入',               '择良', 100, '已完成 ✓'),
('AI 问一问 稳定性监测',         '望之', 80,  '报警监测链路已建立'),
('link preview 稳定性监测',     '凯隐', 60,  '持续监测中'),
('Sentry 崩溃报错定位',          '择良', 50,  '进行中');

-- ---------------------------------------------------------------------------
-- 6.1 按 version 初步关联 milestone（仅更新尚未关联的行）
-- ---------------------------------------------------------------------------
UPDATE public.tasks SET milestone_id = 'M2' WHERE version = 'ios-125' AND milestone_id IS NULL;
UPDATE public.tasks SET milestone_id = 'M3' WHERE version = 'ios-126' AND milestone_id IS NULL;
