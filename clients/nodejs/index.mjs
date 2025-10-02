// Export schemas object that loads from the namespaced cache
// The cache is namespaced by consumer package name and version to avoid conflicts

import { createRequire } from 'module';
import { fileURLToPath } from 'url';
import { dirname, join, basename } from 'path';
import { readFileSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const require = createRequire(import.meta.url);

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
    if (fileName && !fileName.includes('@sourcemeta/registry') && !fileName.startsWith('node:')) {
      // Convert file:// URL to path if needed
      let filePath = fileName;
      if (filePath.startsWith('file://')) {
        filePath = fileURLToPath(filePath);
      }

      // Walk up from this file to find its package.json
      let currentPath = dirname(filePath);
      while (currentPath !== dirname(currentPath)) {
        const packageJsonPath = join(currentPath, 'package.json');
        try {
          const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf8'));
          return { name: packageJson.name, version: packageJson.version, path: currentPath };
        } catch (error) {
          // Continue searching
        }
        currentPath = dirname(currentPath);
      }
    }
  }

  // Fallback to the old method
  let currentPath = dirname(dirname(__dirname)); // Start from node_modules parent
  while (currentPath !== dirname(currentPath)) {
    const packageJsonPath = join(currentPath, 'package.json');
    try {
      const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf8'));
      if (packageJson.name !== '@sourcemeta/registry') {
        return { name: packageJson.name, version: packageJson.version, path: currentPath };
      }
    } catch (error) {
      // Continue searching
    }
    currentPath = dirname(currentPath);
  }

  throw new Error('Could not find consumer package.json');
}

// Cache schemas per consumer package
const schemasCache = new Map();

function getSchemas() {
  const consumer = findConsumerPackageFromCaller();
  const cacheKey = `${consumer.name}@${consumer.version}`;

  if (!schemasCache.has(cacheKey)) {
    // Find the root node_modules directory by walking up from @sourcemeta/registry's location
    // The cache is always in the root node_modules, not in the package's own node_modules
    let rootNodeModules = dirname(__dirname); // node_modules/@sourcemeta
    while (basename(rootNodeModules) !== 'node_modules' && rootNodeModules !== dirname(rootNodeModules)) {
      rootNodeModules = dirname(rootNodeModules);
    }

    const cacheIndexPath = join(
      rootNodeModules,
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

export const schemas = new Proxy({}, {
  get(target, prop) {
    return getSchemas()[prop];
  },
  has(target, prop) {
    return prop in getSchemas();
  },
  ownKeys() {
    return Object.keys(getSchemas());
  },
  getOwnPropertyDescriptor(target, prop) {
    const schemas = getSchemas();
    if (prop in schemas) {
      return {
        enumerable: true,
        configurable: true,
        value: schemas[prop]
      };
    }
  }
});
