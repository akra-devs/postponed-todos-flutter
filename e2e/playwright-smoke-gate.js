const { spawnSync } = require('node:child_process');
const path = require('node:path');

const scriptDir = __dirname;
const projectRoot = path.resolve(scriptDir, '..');

const command = ['playwright', 'test', '--config=playwright.config.js', 'e2e/playwright-web-smoke.spec.js'];
const runLimit = Math.max(1, Number.parseInt(process.env.PLAYWRIGHT_SMOKE_RUNS || '6', 10));
const passThresholdPercent = Math.max(0, Math.min(100, Number.parseInt(process.env.PLAYWRIGHT_SMOKE_PASS_PERCENT || '95', 10)));

let passCount = 0;
let failCount = 0;
const failures = [];

console.log(`[gate] start: runs=${runLimit}, threshold=${passThresholdPercent}%`);

for (let i = 1; i <= runLimit; i += 1) {
  const label = `[gate] run ${i}/${runLimit}`;
  const start = Date.now();

  const result = spawnSync('npx', command, {
    cwd: projectRoot,
    shell: false,
    stdio: ['ignore', 'pipe', 'pipe'],
    encoding: 'utf8',
  });

  const elapsed = Date.now() - start;
  const output = `${result.stdout || ''}\n${result.stderr || ''}`;
  const outputLine = `    status=${result.status}, elapsedMs=${elapsed}`;
  console.log(`${label} ${outputLine}`);

  if (result.status === 0) {
    passCount += 1;
  } else {
    failCount += 1;
    const marker = output.includes('toHaveText') || output.includes('toHaveCount') || output.includes('Timeout')
      ? output.split('\n').find((line) => line.includes('Expected') || line.includes('Timeout') || line.includes('locator'))
      : 'non-zero exit';
    failures.push({ run: i, code: result.status, marker: marker?.trim() || 'non-zero exit', preview: output.slice(0, 300) });
  }
}

const total = passCount + failCount;
const passRate = total > 0 ? Math.round((passCount / total) * 100) : 0;
const ok = passRate >= passThresholdPercent;

const summary = {
  runs: total,
  pass: passCount,
  fail: failCount,
  passRate,
  threshold: passThresholdPercent,
  ok,
  failures,
};

console.log('--- PLAYWRIGHT_SMOKE_GATE_SUMMARY ---');
console.log(JSON.stringify(summary, null, 2));

if (!ok || failCount > 0) {
  console.log(`[gate] FAIL: passRate ${passRate}% (threshold ${passThresholdPercent}%)`);
} else {
  console.log(`[gate] PASS: passRate ${passRate}% (threshold ${passThresholdPercent}%)`);
}

process.exit(ok ? 0 : 1);
