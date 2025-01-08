const { test, expect } = require('@playwright/test');

test('/ page title', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle('Sourcemeta Schemas');
});

test('directory with title', async ({ page }) => {
  await page.goto('/doc');
  await expect(page).toHaveTitle('A sample schema folder');
});

test('directory without title', async ({ page }) => {
  await page.goto('/example/v2.0');
  await expect(page).toHaveTitle('/example/v2.0');
});

test('404', async ({ page }) => {
  await page.goto('/xxxxxxx');
  await expect(page).toHaveTitle('Not Found');
});
