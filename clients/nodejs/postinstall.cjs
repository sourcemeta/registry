#!/usr/bin/env node

'use strict';

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

/**
 * Find the consumer's package.json
 * When running as a postinstall script, we need to find the package that owns
 * the postinstall script (which might be a dependency, not the root package)
 */
function findConsumerPackageJson() {
  // First, try to find the package that's running this postinstall script
  // Walk up from __dirname to find a package.json with schemas
  let currentPath = __dirname;

  while (currentPath !== path.dirname(currentPath)) {
    // Go up to the parent of node_modules
    if (path.basename(currentPath) === 'registry' &&
        path.basename(path.dirname(currentPath)) === '@sourcemeta' &&
        path.basename(path.dirname(path.dirname(currentPath))) === 'node_modules') {
      // We're in node_modules/@sourcemeta/registry
      // Go up to the package that has this as a dependency
      const packageRoot = path.dirname(path.dirname(path.dirname(currentPath)));
      const packageJsonPath = path.join(packageRoot, 'package.json');

      if (fs.existsSync(packageJsonPath)) {
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
        // Check if this package has schemas defined
        if (packageJson.schemas && Object.keys(packageJson.schemas).length > 0) {
          return packageJsonPath;
        }
      }
    }

    currentPath = path.dirname(currentPath);
  }

  // Fall back to INIT_CWD for backwards compatibility
  const consumerRoot = process.env.INIT_CWD || process.cwd();
  const packageJsonPath = path.join(consumerRoot, 'package.json');

  if (fs.existsSync(packageJsonPath)) {
    return packageJsonPath;
  }

  return null;
}

/**
 * Add postinstall script to consumer's package.json if not present
 */
function ensurePostinstallScript(packageJsonPath) {
  const packageJsonContent = fs.readFileSync(packageJsonPath, 'utf8');
  const packageJson = JSON.parse(packageJsonContent);

  // Check if postinstall script already exists
  if (packageJson.scripts && packageJson.scripts.postinstall) {
    // Already has postinstall, don't override
    return false;
  }

  // Add postinstall script
  if (!packageJson.scripts) {
    packageJson.scripts = {};
  }

  packageJson.scripts.postinstall = 'sourcemeta-registry-sync';

  // Write back to package.json
  fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2) + '\n', 'utf8');
  return true;
}

/**
 * Run sourcemeta-registry-sync on the consumer's package.json
 */
function runSync() {
  try {
    // Use the bin script from this package
    const syncScript = path.join(__dirname, 'install.cjs');
    execSync(`node "${syncScript}"`, { stdio: 'inherit', cwd: process.env.INIT_CWD || process.cwd() });
  } catch (error) {
    // Don't fail the installation if sync fails
  }
}

/**
 * Find all packages with schemas defined in their package.json
 * This includes both the root package and any dependencies
 */
function findAllPackagesWithSchemas(nodeModulesPath) {
  const packages = [];

  // Check the root package
  const rootPackageJsonPath = path.join(path.dirname(nodeModulesPath), 'package.json');
  if (fs.existsSync(rootPackageJsonPath)) {
    const rootPackageJson = JSON.parse(fs.readFileSync(rootPackageJsonPath, 'utf8'));
    if (rootPackageJson.schemas && Object.keys(rootPackageJson.schemas).length > 0) {
      packages.push(rootPackageJsonPath);
    }
  }

  // Check all installed packages in node_modules
  if (fs.existsSync(nodeModulesPath)) {
    const entries = fs.readdirSync(nodeModulesPath, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory() || entry.name.startsWith('.')) {
        continue;
      }

      if (entry.name.startsWith('@')) {
        // Scoped package, check subdirectories
        const scopePath = path.join(nodeModulesPath, entry.name);
        const scopedEntries = fs.readdirSync(scopePath, { withFileTypes: true });
        for (const scopedEntry of scopedEntries) {
          if (scopedEntry.isDirectory()) {
            const packageJsonPath = path.join(scopePath, scopedEntry.name, 'package.json');
            if (fs.existsSync(packageJsonPath)) {
              const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
              if (packageJson.schemas && Object.keys(packageJson.schemas).length > 0) {
                packages.push(packageJsonPath);
              }
            }
          }
        }
      } else {
        // Regular package
        const packageJsonPath = path.join(nodeModulesPath, entry.name, 'package.json');
        if (fs.existsSync(packageJsonPath)) {
          const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
          if (packageJson.schemas && Object.keys(packageJson.schemas).length > 0) {
            packages.push(packageJsonPath);
          }
        }
      }
    }
  }

  return packages;
}

/**
 * Run sync for a specific package
 */
function runSyncForPackage(packageJsonPath) {
  try {
    const packageDir = path.dirname(packageJsonPath);
    const syncScript = path.join(__dirname, 'install.cjs');
    execSync(`node "${syncScript}"`, { stdio: 'inherit', cwd: packageDir });
  } catch (error) {
    // Don't fail the installation if sync fails
  }
}

// Main execution
const packageJsonPath = findConsumerPackageJson();

if (packageJsonPath) {
  // Add postinstall script to consumer's package.json
  const scriptAdded = ensurePostinstallScript(packageJsonPath);

  // Find all packages with schemas and sync them
  const packageDir = path.dirname(packageJsonPath);
  const nodeModulesPath = path.join(packageDir, 'node_modules');
  const allPackagesWithSchemas = findAllPackagesWithSchemas(nodeModulesPath);

  // Sync all packages that have schemas
  for (const pkgPath of allPackagesWithSchemas) {
    runSyncForPackage(pkgPath);
  }
}
