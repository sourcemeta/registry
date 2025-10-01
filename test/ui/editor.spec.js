import { test, expect } from '@playwright/test';

test.describe('Schema Editor', () => {
  test('editor loads correct schema data from API', async ({ page }) => {
    await page.goto('/test/schemas/draft4-top-level-ref');

    // Wait for the editor element to be present
    const editor = page.locator('#schema');
    await expect(editor).toBeVisible();

    // Fetch the actual schema data from the API
    const response = await page.request.get('/test/schemas/draft4-top-level-ref.json');
    expect(response.ok()).toBeTruthy();
    const expectedSchema = await response.text();

    // Wait for CodeMirror content to be present and contain actual schema data
    const editorContentLocator = page.locator('#schema .cm-content');
    await expect(editorContentLocator).not.toBeEmpty();
    await expect(editorContentLocator).not.toContainText('Loading schema...');

    // Get the actual editor content from the CodeMirror editor
    // The content is in the .cm-content element (the editable area)
    const editorContent = await editorContentLocator.textContent();

    // Parse both as JSON and compare them to avoid formatting differences
    const editorJSON = JSON.parse(editorContent);
    const expectedJSON = JSON.parse(expectedSchema);

    expect(editorJSON).toEqual(expectedJSON);
  });
});
