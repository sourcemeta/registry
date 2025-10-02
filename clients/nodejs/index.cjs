'use strict';

const path = require('path');
const fs = require('fs');

/**
 * Find the node_modules directory
 * We're installed at node_modules/@sourcemeta/registry, so we can walk up
 */
function findNodeModules() {
  let currentPath = __dirname;

  while (currentPath !== path.dirname(currentPath)) {
    const basename = path.basename(currentPath);

    // Check if we're inside node_modules/@sourcemeta/registry
    if (basename === 'registry') {
      const parentPath = path.dirname(currentPath);
      if (path.basename(parentPath) === '@sourcemeta') {
        const grandParentPath = path.dirname(parentPath);
        if (path.basename(grandParentPath) === 'node_modules') {
          return grandParentPath;
        }
      }
    }

    currentPath = path.dirname(currentPath);
  }

  throw new Error('Could not find node_modules directory');
}

/**
 * Find the consumer's package.json by looking at who is importing this module
 * Uses the stack trace to find the actual caller's location
 */
function findConsumerPackageFromCaller() {
  // Get the stack trace
  const originalPrepareStackTrace = Error.prepareStackTrace;
  Error.prepareStackTrace = (_, stack) => stack;
  const stack = new Error().stack;
  Error.prepareStackTrace = originalPrepareStackTrace;

  // Find the first call site that's NOT in @sourcemeta/registry
  for (const callSite of stack) {
    const fileName = callSite.getFileName();
    if (fileName && !fileName.includes('@sourcemeta/registry') && !fileName.includes('node:')) {
      // Walk up from this file to find its package.json
      let currentPath = path.dirname(fileName);
      while (currentPath !== path.dirname(currentPath)) {
        const packageJsonPath = path.join(currentPath, 'package.json');
        if (fs.existsSync(packageJsonPath)) {
          const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
          return { name: packageJson.name, version: packageJson.version, path: currentPath };
        }
        currentPath = path.dirname(currentPath);
      }
    }
  }

  // Fallback to the old method
  const nodeModulesDirectory = findNodeModules();
  const consumerRoot = path.dirname(nodeModulesDirectory);
  const packageJsonPath = path.join(consumerRoot, 'package.json');

  if (fs.existsSync(packageJsonPath)) {
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
    return { name: packageJson.name, version: packageJson.version, path: consumerRoot };
  }

  throw new Error('Could not find consumer package.json');
}

// Cache schemas per consumer package
const schemasCache = new Map();

function getSchemas() {
  const consumer = findConsumerPackageFromCaller();
  const cacheKey = `${consumer.name}@${consumer.version}`;

  if (!schemasCache.has(cacheKey)) {
    const nodeModulesPath = path.join(consumer.path, 'node_modules');
    const cacheIndexPath = path.join(
      nodeModulesPath,
      '.cache',
      '@sourcemeta',
      'registry',
      consumer.name,
      consumer.version,
      'index.cjs'
    );
    schemasCache.set(cacheKey, require(cacheIndexPath));
  }

  return schemasCache.get(cacheKey);
}

module.exports = {
  get schemas() {
    return getSchemas();
  }
};
