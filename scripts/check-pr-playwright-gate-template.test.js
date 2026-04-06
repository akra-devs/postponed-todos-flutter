const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');

const BASE_CANONICAL = `# Pull Request\n\n## 요약\n- 변경 의도:\n\n## 테스트\n- [ ] Playwright 관련 변경이 있는 경우 아래 항목을 추가로 확인\n\n### Playwright CI Gate (해당 시)\n- [ ] Playwright 실패 샘플을 변경/추가했는지 확인 (e2e/playwright-smoke-gate-failure-samples.json)\n- [ ] npm run playwright-smoke-gate-ci\n- [ ] PR 본문에 runs/pass/fail/passRate/threshold/ok 반영\n`;
const BASE_AUX = `# Playwright CI Gate Checklist (Reference)\n\n기본 템플릿은 ../PULL_REQUEST_TEMPLATE.md에서 통합 관리됩니다.\nplaywright-smoke-gate 체크리스트 참고\n`; 

function runCheck(cwd) {
  const checkerPath = path.join(__dirname, 'check-pr-playwright-gate-template.js');
  const result = spawnSync('node', [checkerPath], {
    cwd,
    encoding: 'utf8',
  });

  return {
    code: result.status,
    stdout: result.stdout || '',
    stderr: result.stderr || '',
  };
}

function writeFixture({ cwd, canonical, auxiliary }) {
  const templateDir = path.join(cwd, '.github');
  const auxDir = path.join(templateDir, 'PULL_REQUEST_TEMPLATE');
  fs.mkdirSync(auxDir, { recursive: true });
  fs.writeFileSync(path.join(templateDir, 'PULL_REQUEST_TEMPLATE.md'), canonical);
  fs.writeFileSync(path.join(auxDir, 'playwright-smoke-gate-checklist.md'), auxiliary);
}

function withTempFixture(name, canonical, auxiliary, expectedCode, expectText) {
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), `pr-template-test-${name}-`));
  try {
    writeFixture({ cwd: tempRoot, canonical, auxiliary });
    const actual = runCheck(tempRoot);
    assert.strictEqual(actual.code, expectedCode, `${name} expected exit ${expectedCode}, got ${actual.code}. stdout=${actual.stdout} stderr=${actual.stderr}`);
    if (expectText) {
      assert.ok(actual.stdout.includes(expectText) || actual.stderr.includes(expectText), `${name} expected text ${expectText}`);
    }
  } finally {
    fs.rmSync(tempRoot, { recursive: true, force: true });
  }
}

withTempFixture(
  'pass',
  BASE_CANONICAL,
  BASE_AUX,
  0,
  'Playwright PR template checks PASS',
);

withTempFixture(
  'fail:missing canonical command',
  BASE_CANONICAL.replace('npm run playwright-smoke-gate-ci', 'npm run playwright-smoke-gate'),
  BASE_AUX,
  1,
  'Canonical template missing required item: Playwright CI command marker',
);

withTempFixture(
  'fail:aux missing reference',
  BASE_CANONICAL,
  'This is a note.\nPlease read Playwright notes.\n',
  1,
  'Auxiliary template missing required item: Auxiliary template references canonical path',
);

console.log('All Playwright PR template checker regression tests passed');
