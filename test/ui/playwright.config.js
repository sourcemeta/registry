const { defineConfig, devices } = require('@playwright/test');

// See https://playwright.dev/docs/test-configuration
module.exports = defineConfig({
  testDir: '.',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'list',
  use: {
    baseURL: process.env.BASE_URL,
    trace: 'on-first-retry'
  }
});

