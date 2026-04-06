const fs = require('node:fs');
const { spawnSync } = require('node:child_process');
const path = require('node:path');

const scriptDir = __dirname;
const projectRoot = path.resolve(scriptDir, '..');

const command = ['playwright', 'test', '--config=playwright.config.js', 'e2e/playwright-web-smoke.spec.js'];
const runLimit = Math.max(1, Number.parseInt(process.env.PLAYWRIGHT_SMOKE_RUNS || '6', 10));
const passThresholdPercent = Math.max(0, Math.min(100, Number.parseInt(process.env.PLAYWRIGHT_SMOKE_PASS_PERCENT || '95', 10)));
const summaryPath = path.resolve(process.env.PLAYWRIGHT_SMOKE_GATE_SUMMARY_PATH || path.join(projectRoot, 'test-results', 'playwright-smoke-gate-summary.json'));

const classifyFailure = (output) => {
  const lines = (output || '').split('\n').map((line) => line.trim()).filter(Boolean);
  const joined = lines.join('\n');

  if (/Timeout|timed out|timedOut/i.test(joined)) {
    return 'timeout';
  }
  if (/selector.*not found|no node found|Unable to locate|Target closed/i.test(joined)) {
    return 'selector_or_target';
  }
  if (/toHaveCount\(|Expected: 3|Received: 0|count/i.test(joined)) {
    return 'count-mismatch';
  }
  if (/toHaveText|text/i.test(joined)) {
    return 'text-assertion';
  }
  if (/click/i.test(joined)) {
    return 'interaction';
  }

  return 'unknown';
};

let passCount = 0;
let failCount = 0;
const failures = [];
const signatureCounts = {};

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
    const signature = classifyFailure(output);
    signatureCounts[signature] = (signatureCounts[signature] || 0) + 1;
    const marker = output.split('\n').find((line) => line.includes('Expected') || line.includes('Timeout') || line.includes('locator') || line.includes('Error:'));
    failures.push({
      run: i,
      code: result.status,
      signature,
      marker: (marker || 'non-zero exit').trim(),
      preview: output.slice(0, 300),
      elapsedMs: elapsed,
    });
  }
}

const total = passCount + failCount;
const passRate = total > 0 ? Math.round((passCount / total) * 100) : 0;
const ok = passRate >= passThresholdPercent && failCount === 0;

const summary = {
  runs: total,
  pass: passCount,
  fail: failCount,
  passRate,
  threshold: passThresholdPercent,
  ok,
  failures,
  signatureCounts,
};

console.log('--- PLAYWRIGHT_SMOKE_GATE_SUMMARY ---');
console.log(JSON.stringify(summary, null, 2));

try {
  fs.mkdirSync(path.dirname(summaryPath), { recursive: true });
  fs.writeFileSync(summaryPath, `${JSON.stringify(summary, null, 2)}\n`, 'utf8');
  console.log(`[gate] summary saved: ${summaryPath}`);
} catch (error) {
  console.warn(`[gate] failed to write summary: ${error.message}`);
}

const hasFailure = !ok;
if (process.env.GITHUB_STEP_SUMMARY) {
  const summaryMarkdown = [
    '## Playwright Smoke Gate Summary',
    '',
    `- Runs: ${summary.runs}`,
    `- Pass: ${summary.pass}`,
    `- Fail: ${summary.fail}`,
    `- Pass Rate: ${summary.passRate}%`,
    `- Threshold: ${summary.threshold}%`,
    `- Result: ${summary.ok ? 'PASS' : 'FAIL'}`,
    '',
  ];

  if (Object.keys(signatureCounts).length > 0) {
    summaryMarkdown.push('### Failure signatures', '', '| Signature | Count |', '| --- | --- |');
    Object.entries(signatureCounts).forEach(([sig, count]) => {
      summaryMarkdown.push(`| ${sig} | ${count} |`);
    });
    summaryMarkdown.push('');
  }

  if (failures.length > 0) {
    summaryMarkdown.push('### Top failures', '');
    failures.forEach((failure) => {
      summaryMarkdown.push(`- run ${failure.run}: ${failure.signature} (code ${failure.code}, elapsed ${failure.elapsedMs}ms)`);
    });
  }

  try {
    fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, `${summaryMarkdown.join('\n')}\n`, 'utf8');
  } catch (error) {
    console.warn(`[gate] failed to append github summary: ${error.message}`);
  }
}

if (hasFailure) {
  console.log(`[gate] FAIL: passRate ${passRate}% (threshold ${passThresholdPercent}%)`);
} else {
  console.log(`[gate] PASS: passRate ${passRate}% (threshold ${passThresholdPercent}%)`);
}

process.exit(hasFailure ? 1 : 0);
