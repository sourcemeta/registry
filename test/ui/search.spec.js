import { test, expect } from '@playwright/test';

test.describe('Search UI', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('search input is present in navigation', async ({ page }) => {
    const searchInput = page.locator('#search');
    await expect(searchInput).toBeVisible();
    await expect(searchInput).toHaveAttribute('type', 'search');
    await expect(searchInput).toHaveAttribute('placeholder', 'Search');
  });

  test('search results dropdown is hidden by default', async ({ page }) => {
    const searchResult = page.locator('#search-result');
    await expect(searchResult).toHaveClass(/d-none/);
  });

  test('typing shows search results with title and description', async ({ page }) => {
    const searchInput = page.locator('#search');
    const searchResult = page.locator('#search-result');

    await searchInput.fill('bundling');

    // Wait for results to appear (debounce is 300ms)
    await expect(searchResult).not.toHaveClass(/d-none/, { timeout: 1000 });

    // Verify we have 2 results as per API test
    const results = searchResult.locator('.list-group-item');
    await expect(results).toHaveCount(2);

    // First result has title and description
    const firstResult = results.nth(0);
    await expect(firstResult).toContainText('/test/bundling/single');
    await expect(firstResult).toContainText('Bundling');
    await expect(firstResult).toContainText('A bundling example');
    await expect(firstResult).toHaveAttribute('href', '/test/bundling/single');

    // Second result has no title/description
    const secondResult = results.nth(1);
    await expect(secondResult).toContainText('/test/bundling/double');
    await expect(secondResult).toHaveAttribute('href', '/test/bundling/double');
  });

  test('search is case-insensitive', async ({ page }) => {
    const searchInput = page.locator('#search');
    const searchResult = page.locator('#search-result');

    await searchInput.fill('bUNdLing');

    await expect(searchResult).not.toHaveClass(/d-none/, { timeout: 1000 });

    const results = searchResult.locator('.list-group-item');
    await expect(results).toHaveCount(2);
    await expect(results.nth(0)).toContainText('Bundling');
  });

  test('no results shows "No results" message', async ({ page }) => {
    const searchInput = page.locator('#search');
    const searchResult = page.locator('#search-result');

    await searchInput.fill('xxxxxxxxxxxx');

    await expect(searchResult).not.toHaveClass(/d-none/, { timeout: 1000 });

    const noResults = searchResult.locator('.list-group-item');
    await expect(noResults).toHaveCount(1);
    await expect(noResults).toContainText('No results');
    await expect(noResults).toHaveClass(/disabled/);
  });

  test('clearing search hides dropdown', async ({ page }) => {
    const searchInput = page.locator('#search');
    const searchResult = page.locator('#search-result');

    // Type to show results
    await searchInput.fill('bundling');
    await expect(searchResult).not.toHaveClass(/d-none/, { timeout: 1000 });

    // Clear the input
    await searchInput.clear();

    // Dropdown should hide
    await expect(searchResult).toHaveClass(/d-none/);
  });

  test('clicking outside search hides dropdown', async ({ page }) => {
    const searchInput = page.locator('#search');
    const searchResult = page.locator('#search-result');

    // Type to show results
    await searchInput.fill('bundling');
    await expect(searchResult).not.toHaveClass(/d-none/, { timeout: 1000 });

    // Click outside (on the body)
    await page.locator('body').click({ position: { x: 10, y: 10 } });

    // Dropdown should hide
    await expect(searchResult).toHaveClass(/d-none/);
  });

  test('refocusing search shows results again', async ({ page }) => {
    const searchInput = page.locator('#search');
    const searchResult = page.locator('#search-result');

    // Type to show results
    await searchInput.fill('bundling');
    await expect(searchResult).not.toHaveClass(/d-none/, { timeout: 1000 });

    // Click outside to hide
    await page.locator('body').click({ position: { x: 10, y: 10 } });
    await expect(searchResult).toHaveClass(/d-none/);

    // Focus back on search
    await searchInput.focus();

    // Results should reappear
    await expect(searchResult).not.toHaveClass(/d-none/);
  });

  test('clicking on search result navigates to correct page', async ({ page }) => {
    const searchInput = page.locator('#search');
    const searchResult = page.locator('#search-result');

    await searchInput.fill('bundling');
    await expect(searchResult).not.toHaveClass(/d-none/, { timeout: 1000 });

    // Click on first result
    const firstResult = searchResult.locator('.list-group-item').nth(0);
    await firstResult.click();

    // Should navigate to the schema page
    await expect(page).toHaveURL(/\/test\/bundling\/single/);
  });

  test('search without title shows only path', async ({ page }) => {
    const searchInput = page.locator('#search');
    const searchResult = page.locator('#search-result');

    await searchInput.fill('schemas/camelcase');

    await expect(searchResult).not.toHaveClass(/d-none/, { timeout: 1000 });

    const results = searchResult.locator('.list-group-item');
    await expect(results).toHaveCount(1);
    await expect(results.nth(0)).toContainText('/test/schemas/camelcase');
  });
});
