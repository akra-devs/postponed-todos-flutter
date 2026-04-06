const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const {
  classifyFailure,
  getRecommendations,
  recommendationCatalog,
  signatureCatalog,
} = require('./playwright-smoke-gate-rules');

const fixturePath = path.resolve(__dirname, 'playwright-smoke-gate-failure-samples.json');
const failureSamples = JSON.parse(fs.readFileSync(fixturePath, 'utf8'));

describe('playwright-smoke-gate failure classification', () => {
  it('classifies timeout-like output', () => {
    const signature = classifyFailure('Error: Timeout 30000ms exceeded');
    assert.equal(signature, 'timeout');
  });

  it('classifies selector/target failures', () => {
    const signature = classifyFailure('Error: selector "button" not found');
    assert.equal(signature, 'selector_or_target');
  });

  it('classifies count mismatch failures', () => {
    const signature = classifyFailure('expect(locator).toHaveCount(3)\nExpected: 3 Received: 0');
    assert.equal(signature, 'count-mismatch');
  });

  it('classifies text assertion failures', () => {
    const signature = classifyFailure('Error: expect(page.getByText("foo")).toHaveText("bar") failed');
    assert.equal(signature, 'text-assertion');
  });

  it('classifies interaction failures', () => {
    const signature = classifyFailure('Error: click action failed with target out of bounds');
    assert.equal(signature, 'interaction');
  });

  it('falls back to unknown for unrecognized failures', () => {
    const signature = classifyFailure('Error: unexpected EOF in response');
    assert.equal(signature, 'unknown');
  });
});

describe('playwright-smoke-gate recommendation catalog', () => {
  it('keeps recommendation list for each known signature', () => {
    signatureCatalog.forEach((signature) => {
      const recommendations = getRecommendations(signature);
      assert.ok(Array.isArray(recommendations), `recommendations must be array for ${signature}`);
      assert.ok(recommendations.length > 0, `recommendation must exist for ${signature}`);
    });
  });

  it('provides fallback recommendations for unknown signature', () => {
    const recommendations = getRecommendations('new-undefined-sig');
    assert.ok(Array.isArray(recommendations));
    assert.ok(recommendations.length >= 1);
    assert.deepEqual(recommendations, recommendationCatalog.unknown);
  });
});

describe('playwright-smoke-gate failure sample fixtures', () => {
  failureSamples.forEach((sample) => {
    it(`classifies fixture sample: ${sample.name}`, () => {
      const signature = classifyFailure(sample.log);
      assert.equal(signature, sample.expectedSignature);
    });

    it(`returns recommendations for fixture sample: ${sample.name}`, () => {
      const recommendations = getRecommendations(sample.expectedSignature);
      assert.ok(Array.isArray(recommendations));
      assert.ok(recommendations.length > 0);
    });
  });
});
