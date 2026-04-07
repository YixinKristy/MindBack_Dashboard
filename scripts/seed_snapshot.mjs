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

function parseFirstJsonValue(src, label) {
  const s = src.trimStart();
  if (!s.trim()) throw new Error(`Empty value for ${label}`);

  const first = s[0];
  if (first !== '[' && first !== '{') {
    throw new Error(`Unexpected first char for ${label}: ${JSON.stringify(first)}`);
  }

  const openToClose = { '[': ']', '{': '}' };
  const stack = [openToClose[first]];
  let inStr = false;
  let escaped = false;

  for (let i = 1; i < s.length; i++) {
    const ch = s[i];

    if (inStr) {
      if (escaped) {
        escaped = false;
        continue;
      }
      if (ch === '\\') {
        escaped = true;
        continue;
      }
      if (ch === '"') {
        inStr = false;
      }
      continue;
    }

    if (ch === '"') {
      inStr = true;
      continue;
    }

    if (ch === '[') stack.push(']');
    else if (ch === '{') stack.push('}');
    else if (ch === ']' || ch === '}') {
      const expected = stack.pop();
      if (expected !== ch) {
        throw new Error(`Mismatched closing bracket for ${label}: expected ${expected}, got ${ch}`);
      }
      if (stack.length === 0) {
        const jsonText = s.slice(0, i + 1);
        return JSON.parse(jsonText);
      }
    }
  }

  throw new Error(`Unterminated JSON for ${label}`);
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
    tasks: parseFirstJsonValue(tasksSrc.replace(/^\s*=/, ''), 'tasks'),
    bugs: parseFirstJsonValue(bugsSrc.replace(/^\s*=/, ''), 'bugs'),
    milestones: parseFirstJsonValue(milestonesSrc.replace(/^\s*=/, ''), 'milestones'),
    people: parseFirstJsonValue(peopleSrc.replace(/^\s*=/, ''), 'people'),
    debtItems: parseFirstJsonValue(debtItemsSrc.replace(/^\s*=/, ''), 'debtItems'),
    ops: parseFirstJsonValue(opsSrc.replace(/^\s*=/, ''), 'ops'),
    backlog: parseFirstJsonValue(backlogSrc.replace(/^\s*=/, ''), 'backlog'),
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

