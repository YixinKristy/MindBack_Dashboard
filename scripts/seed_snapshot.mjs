import { readFile } from 'node:fs/promises';

function requireEnv(name) {
  const v = process.env[name];
  if (!v) {
    throw new Error(`Missing env: ${name}`);
  }
  return v;
}

function extractBlock(html, start, end) {
  const s = html.indexOf(start);
  if (s === -1) throw new Error(`Start marker not found: ${start}`);
  const from = s + start.length;
  const e = html.indexOf(end, from);
  if (e === -1) throw new Error(`End marker not found: ${end}`);
  return html.slice(from, e);
}

function parseJsonValue(src, label) {
  const trimmed = src.trim();
  if (!trimmed) throw new Error(`Empty value for ${label}`);
  return JSON.parse(trimmed);
}

async function main() {
  const filePath = process.argv[2] || 'MindBack产品看板_部署版 (13).html';

  const SUPABASE_URL = requireEnv('SUPABASE_URL');
  const SUPABASE_SERVICE_ROLE_KEY = requireEnv('SUPABASE_SERVICE_ROLE_KEY');
  const SNAPSHOT_KEY = process.env.SNAPSHOT_KEY || 'prod';

  const html = await readFile(filePath, 'utf8');

  const tasksSrc = extractBlock(html, 'let tasks =', 'let bugs =');
  const bugsSrc = extractBlock(html, 'let bugs =', 'let milestones =');
  const milestonesSrc = extractBlock(html, 'let milestones =', 'let people =');
  const peopleSrc = extractBlock(html, 'let people =', 'let debtItems =');
  const debtItemsSrc = extractBlock(html, 'let debtItems =', 'let ops =');
  const opsSrc = extractBlock(html, 'let ops =', '// ── BACKLOG');
  const backlogSrc = extractBlock(html, 'let backlog =', '/*%%DATA_END%%*/');

  const snapshot = {
    tasks: parseJsonValue(tasksSrc.replace(/^\s*=/, ''), 'tasks'),
    bugs: parseJsonValue(bugsSrc.replace(/^\s*=/, ''), 'bugs'),
    milestones: parseJsonValue(milestonesSrc.replace(/^\s*=/, ''), 'milestones'),
    people: parseJsonValue(peopleSrc.replace(/^\s*=/, ''), 'people'),
    debtItems: parseJsonValue(debtItemsSrc.replace(/^\s*=/, ''), 'debtItems'),
    ops: parseJsonValue(opsSrc.replace(/^\s*=/, ''), 'ops'),
    backlog: parseJsonValue(backlogSrc.replace(/^\s*=/, ''), 'backlog'),
  };

  const endpoint = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/kanban_snapshot?key=eq.${encodeURIComponent(SNAPSHOT_KEY)}`;
  const res = await fetch(endpoint, {
    method: 'PATCH',
    headers: {
      'apikey': SUPABASE_SERVICE_ROLE_KEY,
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    },
    body: JSON.stringify({ data: snapshot }),
  });

  const bodyText = await res.text();
  if (!res.ok) {
    throw new Error(`Supabase PATCH failed: ${res.status} ${res.statusText}\n${bodyText}`);
  }
  console.log('Seeded snapshot successfully.');
  console.log(bodyText);
}

main().catch((e) => {
  console.error(e?.stack || e);
  process.exit(1);
});

