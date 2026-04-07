# MindBack Dashboard（公开只读）

本仓库是一个静态 HTML 看板。页面会 **优先从 Supabase 读取快照数据**（`kanban_snapshot` 表，`key='prod'`），读取失败则回退到 HTML 文件内置的默认数据。

## 1) Supabase（必须做：建表 + 开 RLS 公开只读）

在 Supabase 控制台 → SQL Editor 执行：

```sql
create table if not exists public.kanban_snapshot (
  id bigserial primary key,
  key text not null unique,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_kanban_snapshot_updated_at on public.kanban_snapshot;
create trigger trg_kanban_snapshot_updated_at
before update on public.kanban_snapshot
for each row execute function public.set_updated_at();

alter table public.kanban_snapshot enable row level security;

drop policy if exists "public read kanban_snapshot" on public.kanban_snapshot;
create policy "public read kanban_snapshot"
on public.kanban_snapshot
for select
to anon
using (true);

insert into public.kanban_snapshot (key, data)
values ('prod', '{}'::jsonb)
on conflict (key) do nothing;
```

## 2) 本地把内置数据灌进 Supabase（写入链路，公开只读不在网页写）

你需要在本地环境变量里提供 service role key（不要提交到仓库）。

```bash
export SUPABASE_URL="https://<your-project>.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="<your-service-role-key>"
export SNAPSHOT_KEY="prod"

node ./scripts/seed_snapshot.mjs "./MindBack产品看板_部署版 (13).html"
```

成功后，网页刷新就会从 Supabase 读到最新数据。

## 3) 部署

这是静态站点，直接用 Netlify 绑定仓库即可。

