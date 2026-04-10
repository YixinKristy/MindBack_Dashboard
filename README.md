# MindBack Dashboard

MindBack 产品看板的 **Web 控制台**：用于统一管理 **功能任务、Bug、运营动作、版本、里程碑与阶段目标**，并与 **Supabase（PostgreSQL + PostgREST）** 实时读写同步。默认入口为 **总览**，支持管理员登录后的写操作、离线队列与本地草稿缓存。

---

## 这个 Dashboard 做什么

- **总览**：阶段/月目标、本周各端版本、风险预警、近三周版本分组、里程碑摘要等。
- **本周**：按 **截止日期/目标日期与当周（周一至周日）时间范围重叠** 展示任务、Bug、运营；支持重点卡片、拖拽排序、状态下拉、多端版本关联。
- **版本管理**：多平台（iOS / Android / Web）版本、状态、周起始、关联功能与 Bug 等。
- **里程碑**：阶段时间轴、周目标、展开查看周内关联事项。
- **全量任务**：全局列表、筛选与排序。
- **Backlog**：需求池与移入本周等流程（视数据与权限而定）。

业务数据落在 Supabase 的 `public` schema 多张表中；前端通过 **REST API** 访问，并依赖 **RLS** 控制读写权限。

---

## 仓库结构：前端在哪、后端在哪

| 部分 | 位置 | 说明 |
|------|------|------|
| **前端** | 根目录 [`index.html`](./index.html) | 单页应用（SPA）：HTML + CSS + JavaScript，无构建步骤。历史/参考页面：`index.html.backup`、`MindBack产品看板_部署版 (13).html`。 |
| **后端（数据库与策略）** | [`supabase/migrations/`](./supabase/migrations/) | PostgreSQL 迁移：表结构、字段扩展、**RLS 策略** 等。部署时在 Supabase SQL 或 CLI 中按顺序执行。 |
| **辅助脚本** | [`scripts/seed_snapshot.mjs`](./scripts/seed_snapshot.mjs) | 可选：将静态 HTML 快照写入 `kanban_snapshot`（旧版只读快照方案）。当前主线以 `index.html` 直连业务表为准。 |
| **文档** | `PROJECT_OVERVIEW.md`、`DESIGN_V2.md`、`QUICKREF.md` 等 | 设计与使用补充说明。 |

---

## 如何使用

### 1. 本地预览前端

无需打包，任选一种方式：

```bash
# 若已安装 Python 3
cd MindBack_Dashboard
python3 -m http.server 8080
# 浏览器打开 http://localhost:8080/index.html
```

或直接双击/用浏览器打开 `index.html`（部分环境可能对 `file://` 跨域有限制，建议用本地 HTTP 服务）。

### 2. 连接 Supabase

1. 在 Supabase 创建项目，并在 **SQL Editor** 中按顺序执行 [`supabase/migrations/`](./supabase/migrations/) 下的迁移（或自行用 Supabase CLI 管理迁移）。
2. 在 [`index.html`](./index.html) 中配置 **`SUPABASE_URL`** 与 **`SUPABASE_ANON_KEY`**（建议使用你自己的项目密钥；**不要将 service role 或敏感密钥提交到公开仓库**）。
3. 若修改表结构后接口404/字段不匹配，可在 Supabase 侧 **刷新 PostgREST schema cache**（例如 `NOTIFY pgrst, 'reload schema';`，具体以你项目文档为准）。

### 3. 管理员写入

看板写操作（新增/编辑/排序等）需要 **已认证的管理员会话**。前端会在登录后缓存 token，并在下次打开页面时尝试 **静默刷新会话**（见 `index.html` 内 `mindback_auth_v1` 等逻辑）。

请确保对应表的 **RLS 策略** 已允许 `authenticated` 角色在预期场景下 `INSERT/UPDATE/DELETE`（迁移中已包含多类 admin write 策略，仍以你实际执行的 SQL 为准）。

### 4. 部署

将本仓库作为 **静态站点** 部署即可（例如 Netlify、Vercel、GitHub Pages、对象存储 + CDN）。构建产物即为 `index.html` 及静态资源；**环境相关配置目前写在前端代码中**，生产环境建议改为构建时注入或独立配置文件，并注意密钥轮换与 RLS 审计。

### 5.（可选）旧版快照脚本

若仍使用 `kanban_snapshot` 只读快照链路，可参考仓库内历史说明，在本地设置 `SUPABASE_URL`、`SUPABASE_SERVICE_ROLE_KEY` 后运行：

```bash
node ./scripts/seed_snapshot.mjs "./MindBack产品看板_部署版 (13).html"
```

当前主版本以业务表 + `index.html` 为准，不一定依赖该表。

---

## 相关文档

- [`PROJECT_OVERVIEW.md`](./PROJECT_OVERVIEW.md) — 项目结构与阅读顺序  
- [`QUICKREF.md`](./QUICKREF.md) — 快速参考  
- [`TEST_GUIDE.md`](./TEST_GUIDE.md) — 测试清单

---

## License

若未单独声明，以仓库内现有约定为准。
