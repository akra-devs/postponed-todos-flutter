const { test, expect } = require('@playwright/test');

const APP_URL = process.env.PLAYWRIGHT_APP_URL || 'http://127.0.0.1:8080';

// NOTE:
// Flutter web app rendered by the current engine is canvas-based, so
// strict text-based assertions are unreliable. This smoke keeps assertions
// to presence/stability checks and click-point reachability only.

test('home and core canvas interaction smoke', async ({ page }) => {
  await page.goto(APP_URL, { waitUntil: 'networkidle', timeout: 120000 });

  await expect(page).toHaveTitle(/(Postponed Todos|미뤄둔 할일들)/);
  const bootstrap = page.locator('script[src*="flutter_bootstrap.js"]');
  await expect(bootstrap).toHaveCount(1, { timeout: 15000 });

  const viewport = page.viewportSize() || { width: 390, height: 844 };

  // Quick-check interaction points: FAB-like bottom-right zone + bottom tab area.
  await page.mouse.click(viewport.width / 2, viewport.height / 2);
  await page.mouse.click(viewport.width - 56, viewport.height - 56);
  await page.waitForTimeout(500);
  await page.mouse.click(viewport.width / 2, viewport.height - 24);

  const screenshot = await page.screenshot();
  expect(screenshot.length).toBeGreaterThan(0);
});
