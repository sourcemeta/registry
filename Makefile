# Programs
CMAKE ?= cmake
CTEST ?= ctest
HURL ?= hurl
JSONSCHEMA ?= jsonschema
DOCKER ?= docker
SHELLCHECK ?= shellcheck
NPX ?= npx
NPM ?= npm

# Options
INDEX ?= ON
SERVER ?= ON
EDITION ?= enterprise
PRESET ?= Debug
OUTPUT ?= ./build
PREFIX ?= $(OUTPUT)/dist
SANDBOX ?= ./test/sandbox

.PHONY: all
all: configure compile test-schemas test 

.PHONY: configure
configure: 
	$(CMAKE) -S . -B $(OUTPUT) \
		-DCMAKE_BUILD_TYPE:STRING=$(PRESET) \
		-DCMAKE_COMPILE_WARNING_AS_ERROR:BOOL=ON \
		-DREGISTRY_DEVELOPMENT:BOOL=ON \
		-DREGISTRY_TESTS:BOOL=ON \
		-DREGISTRY_INDEX:BOOL=$(INDEX) \
		-DREGISTRY_SERVER:BOOL=$(SERVER) \
		-DREGISTRY_EDITION:STRING=$(EDITION) \
		-DREGISTRY_PREFIX:STRING=$(or $(realpath $(PREFIX)),$(abspath $(PREFIX))) \
		-DBUILD_SHARED_LIBS:BOOL=OFF

.PHONY: compile
compile: 
	$(JSONSCHEMA) fmt --verbose schemas/*.json
	$(JSONSCHEMA) lint --verbose schemas/*.json
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target clang_format
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --parallel 4
	$(CMAKE) --install $(OUTPUT) --prefix $(PREFIX) --config $(PRESET) --verbose \
		--component sourcemeta_registry

.PHONY: lint
lint:
	$(JSONSCHEMA) fmt --check --verbose schemas/*.json
	$(JSONSCHEMA) lint --verbose schemas/*.json
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target clang_format_test
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target shellcheck

.PHONY: test
test: 
	$(CTEST) --test-dir $(OUTPUT) --build-config $(PRESET) --output-on-failure --parallel
	./test/cli/common/index/invalid-configuration.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/invalid-schema.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/output-non-directory.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/external-reference.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/url-base-trailing-slash.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/trailing-slash-identifier.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/bundle-ref-no-fragment.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/directory-index.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/search-index.sh $(PREFIX)/bin/sourcemeta-registry-index
ifeq ($(EDITION), enterprise)
	./test/cli/$(EDITION)/index/no-options.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/$(EDITION)/index/no-output.sh $(PREFIX)/bin/sourcemeta-registry-index
endif
ifeq ($(EDITION), pro)
	./test/cli/$(EDITION)/index/no-options.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/$(EDITION)/index/no-output.sh $(PREFIX)/bin/sourcemeta-registry-index
endif
ifeq ($(EDITION), starter)
	./test/cli/$(EDITION)/index/no-options.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/$(EDITION)/index/no-output.sh $(PREFIX)/bin/sourcemeta-registry-index
endif

.PHONY: test-schemas
test-schemas: 
	$(JSONSCHEMA) test test/schemas --resolve schemas

.PHONY: test-e2e
test-e2e: 
	$(HURL) --test \
		--variable base=$(shell jq --raw-output '.url' < $(SANDBOX)/configuration.json) \
			test/e2e/*.hurl
	$(NPM) --prefix test/ui install
	$(NPX) --prefix test/ui playwright install --with-deps
	env BASE_URL=$(shell jq --raw-output '.url' < $(SANDBOX)/configuration.json) \
		$(NPX) --prefix test/ui playwright test --config test/ui/playwright.config.js

.PHONY: sandbox
sandbox: compile
	$(PREFIX)/bin/sourcemeta-registry-index $(SANDBOX)/configuration.json $(OUTPUT)/sandbox
	./test/sandbox/manifest-check.sh $(OUTPUT)/sandbox $(SANDBOX)/manifest.txt
	$(PREFIX)/bin/sourcemeta-registry-server $(OUTPUT)/sandbox

.PHONY: docker
docker:
	$(DOCKER) build --tag registry-$(EDITION) . --file Dockerfile \
		--build-arg SOURCEMETA_REGISTRY_EDITION=$(EDITION) --progress plain
	SOURCEMETA_REGISTRY_EDITION=$(EDITION) \
		$(DOCKER) compose --file test/sandbox/compose.yaml config
	SOURCEMETA_REGISTRY_EDITION=$(EDITION) \
		$(DOCKER) compose --file test/sandbox/compose.yaml up --build

.PHONY: clean
clean: 
	$(CMAKE) -E rm -R -f build test/ui/node_modules test/ui/test-results
	$(DOCKER) system prune --force --all --volumes || true
