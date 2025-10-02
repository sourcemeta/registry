#!/usr/bin/env node

'use strict';

const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');

/**
 * Find node_modules directory by walking up the directory tree
 */
function findNodeModules(startPath) {
  let currentPath = startPath;
  while (true) {
    const nodeModulesPath = path.join(currentPath, 'node_modules');
    if (fs.existsSync(nodeModulesPath)) {
      return nodeModulesPath;
    }
    const parentPath = path.dirname(currentPath);
    if (parentPath === currentPath) {
      // Reached root without finding node_modules
      return path.join(startPath, 'node_modules');
    }
    currentPath = parentPath;
  }
}

/**
 * Parse HTTP URL and return components
 */
function parseUrl(urlString) {
  const url = new URL(urlString);
  return {
    protocol: url.protocol,
    hostname: url.hostname,
    port: url.port || (url.protocol === 'https:' ? 443 : 80),
    path: url.pathname + url.search
  };
}

/**
 * Make HTTP/HTTPS request with conditional headers
 */
function makeRequest(url, conditionalHeaders) {
  return new Promise((resolve, reject) => {
    const urlParts = parseUrl(url);
    const httpModule = urlParts.protocol === 'https:' ? https : http;

    const headers = {
      'Accept': 'application/schema+json'
    };

    if (conditionalHeaders) {
      if (conditionalHeaders.etag) {
        headers['If-None-Match'] = conditionalHeaders.etag;
      }
      if (conditionalHeaders.lastModified) {
        headers['If-Modified-Since'] = conditionalHeaders.lastModified;
      }
    }

    const options = {
      hostname: urlParts.hostname,
      port: urlParts.port,
      path: urlParts.path,
      method: 'GET',
      headers: headers
    };

    const request = httpModule.request(options, (response) => {
      let data = '';

      response.on('data', (chunk) => {
        data += chunk;
      });

      response.on('end', () => {
        resolve({
          statusCode: response.statusCode,
          headers: response.headers,
          body: data
        });
      });
    });

    request.on('error', (error) => {
      reject(error);
    });

    request.end();
  });
}

/**
 * Download schema from URL with caching support
 */
async function downloadSchema(url, cachedMetadata) {
  const conditionalHeaders = cachedMetadata ? {
    etag: cachedMetadata.etag,
    lastModified: cachedMetadata.lastModified
  } : null;

  const response = await makeRequest(url, conditionalHeaders);

  if (response.statusCode === 304) {
    // Not modified, use cached version
    return { notModified: true };
  }

  if (response.statusCode !== 200) {
    throw new Error(`HTTP ${response.statusCode} when fetching ${url}`);
  }

  const etag = response.headers['etag'];
  const lastModified = response.headers['last-modified'];

  if (!etag && !lastModified) {
    throw new Error(`Schema at ${url} does not provide ETag or Last-Modified header, caching not possible`);
  }

  let schema;
  try {
    schema = JSON.parse(response.body);
  } catch (error) {
    throw new Error(`Failed to parse JSON from ${url}: ${error.message}`);
  }

  return {
    notModified: false,
    etag: etag || undefined,
    lastModified: lastModified || undefined,
    schema: schema
  };
}

/**
 * Ensure directory exists, creating it recursively if needed
 */
function ensureDirectoryExists(directoryPath) {
  if (!fs.existsSync(directoryPath)) {
    fs.mkdirSync(directoryPath, { recursive: true });
  }
}

/**
 * Get existing cached schemas
 */
function getExistingCachedSchemas(cacheDirectory) {
  if (!fs.existsSync(cacheDirectory)) {
    return [];
  }

  const files = fs.readdirSync(cacheDirectory);
  return files
    .filter(file => file.endsWith('.json'))
    .map(file => path.basename(file, '.json'));
}

/**
 * Main installation function
 */
async function install(packageJsonPath) {
  // Read package.json
  if (!fs.existsSync(packageJsonPath)) {
    throw new Error(`package.json not found at ${packageJsonPath}`);
  }

  const packageJsonContent = fs.readFileSync(packageJsonPath, 'utf8');
  const packageJson = JSON.parse(packageJsonContent);

  // Check if schemas property exists
  if (!packageJson.schemas || typeof packageJson.schemas !== 'object') {
    // Silently exit if no schemas to install
    return;
  }

  // Find node_modules directory
  const packageDirectory = path.dirname(path.resolve(packageJsonPath));
  const nodeModulesDirectory = findNodeModules(packageDirectory);

  // Namespace cache by consumer package name and version to avoid conflicts
  const cacheDirectory = path.join(
    nodeModulesDirectory,
    '.cache',
    '@sourcemeta',
    'registry',
    packageJson.name,
    packageJson.version
  );

  // Ensure cache directory exists
  ensureDirectoryExists(cacheDirectory);

  // Get existing cached schemas for cleanup
  const existingSchemas = getExistingCachedSchemas(cacheDirectory);
  const currentSchemas = Object.keys(packageJson.schemas);

  // Remove schemas that are no longer in package.json
  const schemasToRemove = existingSchemas.filter(schema => !currentSchemas.includes(schema));
  for (const schemaName of schemasToRemove) {
    const schemaPath = path.join(cacheDirectory, `${schemaName}.json`);
    fs.unlinkSync(schemaPath);
    console.log(`Removed ${schemaName}.json (no longer in package.json)`);
  }

  // Download or update schemas
  for (const [schemaName, schemaUrl] of Object.entries(packageJson.schemas)) {
    const schemaPath = path.join(cacheDirectory, `${schemaName}.json`);

    // Add ?bundle=1 query parameter to fetch schema with dependencies
    const urlWithBundle = schemaUrl + (schemaUrl.includes('?') ? '&' : '?') + 'bundle=1';

    // Check if schema already exists
    let cachedMetadata = null;
    if (fs.existsSync(schemaPath)) {
      try {
        const cachedContent = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
        cachedMetadata = {
          etag: cachedContent.etag,
          lastModified: cachedContent.lastModified
        };
      } catch (error) {
        // Ignore errors reading cached file, will re-download
      }
    }

    try {
      const result = await downloadSchema(urlWithBundle, cachedMetadata);

      if (result.notModified) {
        console.log(`${schemaName}: up to date`);
      } else {
        const cacheEntry = {
          etag: result.etag,
          lastModified: result.lastModified,
          schema: result.schema
        };

        fs.writeFileSync(schemaPath, JSON.stringify(cacheEntry, null, 2), 'utf8');
        console.log(`${schemaName}: downloaded from ${schemaUrl}`);
      }
    } catch (error) {
      throw new Error(`Failed to process schema '${schemaName}': ${error.message}`);
    }
  }

  // Generate index file that exports all schemas
  generateCacheIndex(cacheDirectory, currentSchemas);
}

/**
 * Generate index.cjs that exports all cached schemas
 */
function generateCacheIndex(cacheDirectory, schemaNames) {
  const indexCjsPath = path.join(cacheDirectory, 'index.cjs');
  const loadStatements = schemaNames.map(name => {
    return `  ${JSON.stringify(name)}: JSON.parse(fs.readFileSync(path.join(__dirname, ${JSON.stringify(name + '.json')}), 'utf8')).schema`;
  }).join(',\n');

  const cjsCode = `'use strict';

const fs = require('fs');
const path = require('path');

module.exports = {
${loadStatements}
};
`;

  fs.writeFileSync(indexCjsPath, cjsCode, 'utf8');
}

/**
 * Find consumer's package.json when running as bin script
 */
function findConsumerPackageJson() {
  // When running as a bin script, use the current working directory
  const consumerRoot = process.cwd();
  const packageJsonPath = path.join(consumerRoot, 'package.json');

  if (fs.existsSync(packageJsonPath)) {
    return packageJsonPath;
  }

  throw new Error('Could not find consumer package.json at ' + packageJsonPath);
}

// Main execution
if (require.main === module) {
  let packageJsonPath = process.argv[2];

  // If no path provided, try to find consumer's package.json (bin script scenario)
  if (!packageJsonPath) {
    try {
      packageJsonPath = findConsumerPackageJson();
    } catch (error) {
      console.error('Usage: node install.js <path-to-package.json>');
      console.error('Or run as sourcemeta-registry-sync to auto-detect consumer package.json');
      process.exit(1);
    }
  }

  install(packageJsonPath)
    .then(() => {
      // Only log completion message when explicitly called with path argument
      if (process.argv[2]) {
        console.log('Schema installation complete');
      }
    })
    .catch((error) => {
      console.error(`Error: ${error.message}`);
      process.exit(1);
    });
}

module.exports = { install };
