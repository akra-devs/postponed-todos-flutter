const fs = require('node:fs');
const { spawnSync } = require('node:child_process');
const path = require('node:path');

const scriptDir = __dirname;
const projectRoot = path.resolve(scriptDir, '..');

const command = ['playwright', 'test', '--config=playwright.config.js', 'e2e/playwright-web-smoke.spec.js'];
const runLimit = Math.max(1, Number.parseInt(process.env.PLAYWRIGHT_SMOKE_RUNS || '6', 10));
const passThresholdPercent = Math.max(0, Math.min(100, Number.parseInt(process.env.PLAYWRIGHT_SMOKE_PASS_PERCENT || '95', 10)));
const summaryPath = path.resolve(process.env.PLAYWRIGHT_SMOKE_GATE_SUMMARY_PATH || path.join(projectRoot, 'test-results', 'playwright-smoke-gate-summary.json'));

const recommendationCatalog = {
  timeout: [
    '클래스/페이지 로딩 대기시간을 늘리고, 앱 진입 marker 존재 여부 점검',
    'flutter startup 시 `flutter-first-frame` 이벤트와 마커 전환 경로 타이밍 로그를 확대',
  ],
  selector_or_target: [
    'Locator/target 안정성을 좌표 중심 fallback로 강화',
    '뷰/캔버스 DOM 준비 대기 정책을 보수적으로 조정',
  ],
  'count-mismatch': [
    '엔진 훅/레이디 상태 fallback 임계치를 완화하거나 마커 기반 대체 경로를 우선 적용',
    'Playwright 스모크 동작순서를 좌표 접근 후 marker 확인 순으로 재정렬',
  ],
  'text-assertion': [
    '텍스트 assertion 의존도를 축소하고 canvas 환경에서 대체 가능한 상태검증으로 전환',
  ],
  interaction: [
    '좌표 기반 click 타이밍/viewport를 조정하고, 클릭 전 hover/요소 준비 체크 추가',
    '앱 재렌더링 유발 동작 사이 간격을 확대해 상호작용 충돌 완화',
  ],
  unknown: [
    '에러 로그 상위 블록을 전체 캡처해 실패 패턴 템플릿에 매핑',
    'Playwright 브라우저 업그레이드/동작 환경 재현 여부 검토',
  ],
};

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

const getRecommendations = (signature) => recommendationCatalog[signature] || recommendationCatalog.unknown;

let passCount = 0;
let failCount = 0;
const failures = [];
const signatureCounts = {};
const recommendationCounts = {};

const addRecommendations = (signature) => {
  const recommendations = getRecommendations(signature);
  recommendations.forEach((recommendation) => {
    recommendationCounts[recommendation] = (recommendationCounts[recommendation] || 0) + 1;
  });
  return recommendations;
};

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
    const recommendations = addRecommendations(signature);
    failures.push({
      run: i,
      code: result.status,
      signature,
      marker: (marker || 'non-zero exit').trim(),
      preview: output.slice(0, 300),
      elapsedMs: elapsed,
      recommendations,
    });
  }
}

const total = passCount + failCount;
const passRate = total > 0 ? Math.round((passCount / total) * 100) : 0;
const ok = passRate >= passThresholdPercent && failCount === 0;

const recommendedActions = Object.entries(recommendationCounts)
  .sort((a, b) => b[1] - a[1])
  .map(([action, count]) => ({ action, count }));

const summary = {
  runs: total,
  pass: passCount,
  fail: failCount,
  passRate,
  threshold: passThresholdPercent,
  ok,
  failures,
  signatureCounts,
  recommendations: {
    counts: recommendationCounts,
    topActions: recommendedActions,
  },
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

  if (recommendedActions.length > 0) {
    summaryMarkdown.push('### Recommended actions', '', '| Priority | Action | Count |', '| --- | --- | --- |');
    recommendedActions.forEach((entry, index) => {
      summaryMarkdown.push(`| ${index + 1} | ${entry.action} | ${entry.count} |`);
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
