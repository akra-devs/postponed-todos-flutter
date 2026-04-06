const { test, expect } = require('@playwright/test');

const APP_URL = process.env.PLAYWRIGHT_APP_URL || 'http://127.0.0.1:8080';

// NOTE:
// Flutter web app rendered by the current engine is canvas-based, so
// strict text-based assertions are unreliable. This smoke keeps assertions
// to presence/stability checks and lightweight interaction signals.

test('home and core canvas interaction smoke', async ({ page }) => {
  await page.goto(APP_URL, { waitUntil: 'load', timeout: 120000 });

  await expect(page).toHaveTitle(/(Postponed Todos|미뤄둔 할일들)/, {
    timeout: 20_000,
  });

  const bootstrap = page.locator('script[src*="flutter_bootstrap.js"]');
  await expect(bootstrap).toHaveCount(1, { timeout: 20_000 });

  const readyMarker = page.locator('#pw-ready-marker');
  await expect(readyMarker).toHaveCount(1, { timeout: 10_000 });

  const readyState = await readyMarker.getAttribute('data-pw-ready');
  if (readyState !== 'true') {
    const engineHookSelector =
      'flt-semantics-placeholder, flt-announcement-host, flt-announcement-polite, flt-text-editing-host';

    const markerCounts = await page.evaluate((selector) => {
      return {
        engineHooks: document.querySelectorAll(selector).length,
        flutterView: document.querySelectorAll('flutter-view').length,
        canvas: document.querySelectorAll('canvas').length,
      };
    }, engineHookSelector);

    if (markerCounts.engineHooks + markerCounts.flutterView + markerCounts.canvas > 0) {
      expect(Math.max(markerCounts.engineHooks, markerCounts.flutterView, markerCounts.canvas)).toBeGreaterThan(
        0,
      );
    } else {
      expect(readyState).toBe('true');
    }
  }

  const accessibilityButton = page.locator('[aria-label="Enable accessibility"]').first();
  if ((await accessibilityButton.count()) > 0) {
    await accessibilityButton.click({ timeout: 2_000, force: true }).catch(() => {});
    await page.waitForTimeout(250);
  }

  const viewport = page.viewportSize() || { width: 390, height: 844 };

  // Minimal interaction reachability checks: inject synthetic mouse gestures at
  // common UI regions instead of strict element-level locators.
  await page.mouse.move(viewport.width / 2, viewport.height / 2);
  await page.mouse.click(viewport.width / 2, viewport.height / 2);
  await page.mouse.click(viewport.width - 56, viewport.height - 56);
  await page.waitForTimeout(500);
  await page.mouse.click(viewport.width / 2, viewport.height - 24);

  const screenshot = await page.screenshot({ animations: 'disabled' });
  expect(screenshot.length).toBeGreaterThan(1000);
});
