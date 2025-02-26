# Programs
CMAKE ?= cmake
HURL ?= hurl
JSONSCHEMA ?= jsonschema
DOCKER ?= docker
SHELLCHECK ?= shellcheck
NPX ?= npx
NPM ?= npm

# Options
INDEX ?= ON
SERVER ?= ON
EDITION ?= ee
PRESET ?= Debug
OUTPUT ?= ./build
PREFIX ?= $(OUTPUT)/dist
SANDBOX ?= ./test/sandbox

ifeq ($(EDITION), ee)
ENTERPRISE := ON
else
ENTERPRISE := OFF
endif

.PHONY: all
all: configure compile test-schemas test 

.PHONY: configure
configure: 
	$(CMAKE) -S . -B $(OUTPUT) \
		-DCMAKE_BUILD_TYPE:STRING=$(PRESET) \
		-DCMAKE_COMPILE_WARNING_AS_ERROR:BOOL=ON \
		-DREGISTRY_DEVELOPMENT:BOOL=ON \
		-DREGISTRY_INDEX:BOOL=$(INDEX) \
		-DREGISTRY_SERVER:BOOL=$(SERVER) \
		-DREGISTRY_ENTERPRISE:BOOL=$(ENTERPRISE) \
		-DREGISTRY_PREFIX:STRING=$(or $(realpath $(PREFIX)),$(abspath $(PREFIX))) \
		-DBUILD_SHARED_LIBS:BOOL=OFF

.PHONY: compile
compile: 
	$(JSONSCHEMA) fmt --verbose schemas/*.json
	$(JSONSCHEMA) lint --verbose schemas/*.json
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target clang_format
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target shellcheck
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --parallel 4
	$(CMAKE) --install $(OUTPUT) --prefix $(PREFIX) --config $(PRESET) --verbose \
		--component sourcemeta_registry

.PHONY: lint
lint:
	$(JSONSCHEMA) fmt --check --verbose schemas/*.json
	$(JSONSCHEMA) lint --verbose schemas/*.json
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target clang_format
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target shellcheck
	$(SHELLCHECK) test/cli/*/*/*.sh test/sandbox/*.sh

.PHONY: test
test: 
	./test/cli/common/index/invalid-configuration.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/invalid-schema.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/external-reference.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/url-base-trailing-slash.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/trailing-slash-identifier.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/common/index/bundle-ref-no-fragment.sh $(PREFIX)/bin/sourcemeta-registry-index
ifeq ($(ENTERPRISE), ON)
	./test/cli/ee/index/no-options.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/ee/index/no-output.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/ee/index/directory-index.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/ee/index/search-index.sh $(PREFIX)/bin/sourcemeta-registry-index
else
	./test/cli/ce/index/no-options.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/ce/index/no-output.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/ce/index/directory-index.sh $(PREFIX)/bin/sourcemeta-registry-index
endif

.PHONY: test-schemas
test-schemas: 
	$(JSONSCHEMA) test test/schemas --resolve schemas

.PHONY: test-e2e
test-e2e: 
	$(HURL) --test \
		--variable base=$(shell jq --raw-output '.url' < $(SANDBOX)/configuration.json) \
		test/e2e/common/*.hurl test/e2e/$(EDITION)/*.hurl
ifeq ($(ENTERPRISE), ON)
	$(NPM) --prefix test/ui install
	$(NPX) --prefix test/ui playwright install --with-deps
	env BASE_URL=$(shell jq --raw-output '.url' < $(SANDBOX)/configuration.json) \
		$(NPX) --prefix test/ui playwright test --config test/ui/playwright.config.js
endif

.PHONY: sandbox
sandbox: compile
	$(PREFIX)/bin/sourcemeta-registry-index $(SANDBOX)/configuration.json $(OUTPUT)/sandbox
	./test/sandbox/manifest-check.sh $(OUTPUT)/sandbox $(SANDBOX)/manifest-$(EDITION).txt
	$(PREFIX)/bin/sourcemeta-registry-server $(OUTPUT)/sandbox

.PHONY: docker
docker:
	$(DOCKER) build --tag registry-$(EDITION) . --file Dockerfile.$(EDITION) --progress plain
	$(DOCKER) compose --file test/sandbox/compose-$(EDITION).yaml up --build

.PHONY: clean
clean: 
	$(CMAKE) -E rm -R -f build test/ui/node_modules test/ui/test-results
	$(DOCKER) system prune --force --all --volumes || true
