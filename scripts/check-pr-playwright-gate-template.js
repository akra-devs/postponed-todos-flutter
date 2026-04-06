#!/usr/bin/env node
const fs = require('node:fs');
const path = require('node:path');

const root = process.cwd();
const canonicalPath = path.join(root, '.github', 'PULL_REQUEST_TEMPLATE.md');
const auxiliaryPath = path.join(root, '.github', 'PULL_REQUEST_TEMPLATE', 'playwright-smoke-gate-checklist.md');

function fail(message) {
  console.error(`- ${message}`);
  process.exitCode = 1;
}

function checkPatterns(patterns, target, failurePrefix) {
  let failed = false;

  for (const { label, pattern } of patterns) {
    if (!pattern.test(target)) {
      fail(`${failurePrefix}${label}`);
      failed = true;
    }
  }

  return failed;
}

let failed = false;

if (!fs.existsSync(canonicalPath)) {
  fail(`Canonical PR template missing: ${canonicalPath}`);
  process.exit(1);
}

const canonical = fs.readFileSync(canonicalPath, 'utf8');

const headingPattern = /^###\s*Playwright CI Gate \(해당 시\)/m;

const canonicalPatterns = [
  { label: 'Playwright CI Gate section', pattern: headingPattern },
];

if (checkPatterns(canonicalPatterns, canonical, 'Canonical template missing required item: ')) {
  failed = true;
}

const headingMatch = canonical.match(headingPattern);
if (!headingMatch) {
  fail('Canonical template missing required item: Playwright CI Gate section');
  process.exit(1);
}

const sectionStartIndex = headingMatch.index;
const afterSectionStart = canonical.slice(sectionStartIndex);
const nextSectionIndex = afterSectionStart.search(/\n###\s+/m);
const ciGateSection = nextSectionIndex === -1 ? afterSectionStart : afterSectionStart.slice(0, nextSectionIndex);

const sectionPatterns = [
  { label: 'Playwright CI command marker', pattern: /npm run playwright-smoke-gate-ci/i },
  { label: 'Playwright CI command checklist item', pattern: /-\s*\[\s*\]\s*`?npm run playwright-smoke-gate-ci`?/i },
  { label: 'Playwright failure sample checklist item', pattern: /-\s*\[\s*\]\s*Playwright 실패 샘플을 변경\/추가했는지 확인/ },
  { label: 'Playwright CI Gate checklist order', pattern: /^\s*-\s*\[\s*\]\s*Playwright 실패 샘플을 변경\/추가했는지 확인[\s\S]*?^\s*-\s*\[\s*\]\s*`?npm run playwright-smoke-gate-ci`?[\s\S]*?^\s*-\s*\[\s*\]\s*PR\s+본문에\s*`playwright-smoke-gate`\s*요약\s*반영\s*-[\s\S]*?`runs`\s*,\s*`pass`\s*,\s*`fail`\s*,\s*`passRate`\s*,\s*`threshold`\s*,\s*`ok`/m },
  { label: 'Playwright summary fields format', pattern: /-\s*\[\s*\]\s*PR\s+본문에\s*`playwright-smoke-gate`\s*요약\s*반영\s*-[\s\S]*?`runs`\s*,\s*`pass`\s*,\s*`fail`\s*,\s*`passRate`\s*,\s*`threshold`\s*,\s*`ok`/i },
  { label: 'passRate summary field', pattern: /`passRate`/i },
  { label: 'runs summary token', pattern: /`runs`/i },
  { label: 'pass summary token', pattern: /`pass`/i },
  { label: 'fail summary token', pattern: /`fail`/i },
  { label: 'threshold summary token', pattern: /`threshold`/i },
  { label: 'ok summary token', pattern: /`ok`/i },
  { label: 'Playwright failure sample path', pattern: /`?e2e\/playwright-smoke-gate-failure-samples\.json`?/ },
];

if (checkPatterns(sectionPatterns, ciGateSection, 'Canonical template missing required item: ')) {
  failed = true;
}

if (!fs.existsSync(auxiliaryPath)) {
  fail(`Auxiliary template missing: ${auxiliaryPath}`);
  process.exit(1);
}

const auxiliary = fs.readFileSync(auxiliaryPath, 'utf8');
const auxiliaryChecks = [
  { label: 'Auxiliary template references canonical path', pattern: /PULL_REQUEST_TEMPLATE\.md/ },
  { label: 'Auxiliary template marked as reference', pattern: /참고용|reference|reference template/i },
  { label: 'Auxiliary template has at least one Playwright marker', pattern: /playwright-smoke-gate/i },
];

if (checkPatterns(auxiliaryChecks, auxiliary, 'Auxiliary template missing required item: ')) {
  failed = true;
}

const auxiliaryChecklistPattern = /^\s*[-*]\s*\[[ xX]\]/m;
if (auxiliaryChecklistPattern.test(auxiliary)) {
  fail('Auxiliary template contains checklist item; keep reference-only format');
  failed = true;
}

if (failed) {
  console.error('Playwright PR template check FAILED');
  process.exit(1);
}

console.log('Playwright PR template checks PASS');
