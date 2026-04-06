const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');

const BASE_CANONICAL = `# Pull Request

## 요약
- 변경 의도:

## 테스트
- [ ] Playwright 관련 변경이 있는 경우 아래 항목을 추가로 확인

### Playwright CI Gate (해당 시)
- [ ] Playwright 실패 샘플을 변경/추가했는지 확인 (e2e/playwright-smoke-gate-failure-samples.json)
- [ ] npm run playwright-smoke-gate-ci
- [ ] PR 본문에 \`playwright-smoke-gate\` 요약 반영\n  - \`runs\`, \`pass\`, \`fail\`, \`passRate\`, \`threshold\`, \`ok\`
`;

const BASE_AUX = `# Playwright CI Gate Checklist (Reference)

기본 템플릿은 ../PULL_REQUEST_TEMPLATE.md에서 통합 관리됩니다.
playwright-smoke-gate 체크리스트 참고
`;

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

function createTemplateFiles({ cwd, canonical, auxiliary, hasAux = true }) {
  const templateDir = path.join(cwd, '.github');
  const auxDir = path.join(templateDir, 'PULL_REQUEST_TEMPLATE');
  fs.mkdirSync(auxDir, { recursive: true });
  fs.writeFileSync(path.join(templateDir, 'PULL_REQUEST_TEMPLATE.md'), canonical);
  if (hasAux) {
    fs.writeFileSync(path.join(auxDir, 'playwright-smoke-gate-checklist.md'), auxiliary);
  }
}

function withTempFixture(name, setup, expectedCode, expectText) {
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), `pr-template-test-${name}-`));
  try {
    setup(tempRoot);
    const actual = runCheck(tempRoot);
    assert.strictEqual(actual.code, expectedCode, `${name} expected exit ${expectedCode}, got ${actual.code}. stdout=${actual.stdout} stderr=${actual.stderr}`);
    if (expectText) {
      assert.ok(
        actual.stdout.includes(expectText) || actual.stderr.includes(expectText),
        `${name} expected text ${expectText}`
      );
    }
  } finally {
    fs.rmSync(tempRoot, { recursive: true, force: true });
  }
}

withTempFixture(
  'pass',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL,
      auxiliary: BASE_AUX,
    });
  },
  0,
  'Playwright PR template checks PASS',
);

withTempFixture(
  'fail:missing canonical command',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL.replace('npm run playwright-smoke-gate-ci', 'npm run playwright-smoke-gate'),
      auxiliary: BASE_AUX,
    });
  },
  1,
  'Canonical template missing required item: Playwright CI command marker',
);

withTempFixture(
  'fail:aux missing reference',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL,
      auxiliary: 'This is a note.\nPlease read Playwright notes.\n',
    });
  },
  1,
  'Auxiliary template missing required item: Auxiliary template references canonical path',
);

withTempFixture(
  'fail:aux missing template',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL,
      auxiliary: BASE_AUX,
      hasAux: false,
    });
  },
  1,
  'Auxiliary template missing: ',
);


withTempFixture(
  'fail:canonical missing pass field',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL.replace('\`runs\`, \`pass\`, \`fail\`, \`passRate\`, \`threshold\`, \`ok\`', '\`runs\`, \`fail\`, \`passRate\`, \`threshold\`, \`ok\`'),
      auxiliary: BASE_AUX,
    });
  },
  1,
  'Canonical template missing required item: pass summary token',
);

withTempFixture(
  'fail:canonical missing fail field',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL.replace('\`runs\`, \`pass\`, \`fail\`, \`passRate\`, \`threshold\`, \`ok\`', '\`runs\`, \`pass\`, \`passRate\`, \`threshold\`, \`ok\`'),
      auxiliary: BASE_AUX,
    });
  },
  1,
  'Canonical template missing required item: fail summary token',
);

withTempFixture(
  'fail:canonical missing summary threshold',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL.replace('\`runs\`, \`pass\`, \`fail\`, \`passRate\`, \`threshold\`, \`ok\`', '\`runs\`, \`pass\`, \`fail\`, \`passRate\`, \`ok\`'),
      auxiliary: BASE_AUX,
    });
  },
  1,
  'Canonical template missing required item: threshold summary token',
);

withTempFixture(
  'fail:canonical missing ok field',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL.replace('\`runs\`, \`pass\`, \`fail\`, \`passRate\`, \`threshold\`, \`ok\`', '\`runs\`, \`pass\`, \`fail\`, \`passRate\`, \`threshold\`'),
      auxiliary: BASE_AUX,
    });
  },
  1,
  'Canonical template missing required item: ok summary token',
);

withTempFixture(
  'fail:canonical missing passRate field',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL.replace('\`runs\`, \`pass\`, \`fail\`, \`passRate\`, \`threshold\`, \`ok\`', '\`runs\`, \`pass\`, \`fail\`, \`threshold\`, \`ok\`'),
      auxiliary: BASE_AUX,
    });
  },
  1,
  'Canonical template missing required item: passRate summary field',
);

withTempFixture(
  'fail:canonical summary fields not formatted with backticks',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL.replace('\`runs\`, \`pass\`, \`fail\`, \`passRate\`, \`threshold\`, \`ok\`', 'runs, pass, fail, passRate, threshold, ok'),
      auxiliary: BASE_AUX,
    });
  },
  1,
  'Canonical template missing required item: Playwright summary fields format',
);

withTempFixture(
  'fail:canonical missing sample path',
  (tmpRoot) => {
    createTemplateFiles({
      cwd: tmpRoot,
      canonical: BASE_CANONICAL.replace('e2e/playwright-smoke-gate-failure-samples.json', 'e2e/missing-samples.json'),
      auxiliary: BASE_AUX,
    });
  },
  1,
  'Canonical template missing required item: Playwright failure sample path',
);

console.log('All Playwright PR template checker regression tests passed');
