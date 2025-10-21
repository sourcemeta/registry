# Programs
CMAKE ?= cmake
CTEST ?= ctest
HURL ?= hurl
DOCKER ?= docker
SHELLCHECK ?= shellcheck
MKDOCS ?= mkdocs
NPM ?= npm
NPX ?= npx

# Options
INDEX ?= ON
SERVER ?= ON
PRESET ?= Debug
OUTPUT ?= ./build
PREFIX ?= $(OUTPUT)/dist
SANDBOX ?= ./test/sandbox
SANDBOX_CONFIGURATION ?= html
SANDBOX_PORT ?= 8000
SANDBOX_URL ?= http://localhost:$(SANDBOX_PORT)
PUBLIC ?= ./public

.PHONY: all
all: configure compile test

node_modules: package.json package-lock.json
	$(NPM) ci

.PHONY: configure
configure: node_modules
	$(CMAKE) -S . -B $(OUTPUT) \
		-DCMAKE_BUILD_TYPE:STRING=$(PRESET) \
		-DCMAKE_COMPILE_WARNING_AS_ERROR:BOOL=ON \
		-DREGISTRY_TESTS:BOOL=ON \
		-DREGISTRY_INDEX:BOOL=$(INDEX) \
		-DREGISTRY_SERVER:BOOL=$(SERVER) \
		-DREGISTRY_PREFIX:STRING=$(or $(realpath $(PREFIX)),$(abspath $(PREFIX))) \
		-DBUILD_SHARED_LIBS:BOOL=OFF

.PHONY: compile
compile:
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target clang_format
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --parallel 4
	$(CMAKE) --install $(OUTPUT) --prefix $(PREFIX) --config $(PRESET) --verbose \
		--component sourcemeta_registry --component sourcemeta_registry
	$(CMAKE) --install $(OUTPUT) --prefix $(PREFIX) --config $(PRESET) --verbose \
		--component sourcemeta_registry --component sourcemeta_jsonschema

.PHONY: lint
lint:
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target clang_format_test
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target shellcheck
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target jsonschema_metaschema
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target jsonschema_lint

.PHONY: test
test:
	$(CTEST) --test-dir $(OUTPUT) --build-config $(PRESET) --output-on-failure --parallel

.PHONY: test-e2e
HURL_TESTS += test/e2e/$(SANDBOX_CONFIGURATION)/*.hurl
ifneq ($(SANDBOX_CONFIGURATION),empty)
HURL_TESTS += test/e2e/populated/schemas/*.hurl
HURL_TESTS += test/e2e/populated/api/*.hurl
endif
test-e2e:
	$(HURL) --test --variable base=$(SANDBOX_URL) $(HURL_TESTS)

.PHONY: test-ui
test-ui: node_modules
	$(NPX) playwright install --with-deps
	env PLAYWRIGHT_BASE_URL=$(SANDBOX_URL) \
		$(NPX) playwright test --config test/ui/playwright.config.js

.PHONY: sandbox-index
sandbox-index: compile
	$(PREFIX)/bin/sourcemeta-registry-index \
		$(SANDBOX)/registry-$(SANDBOX_CONFIGURATION).json \
		$(OUTPUT)/sandbox --url $(SANDBOX_URL) --profile
	./test/sandbox/manifest-check.sh $(OUTPUT)/sandbox \
		$(SANDBOX)/manifest-$(SANDBOX_CONFIGURATION).txt

.PHONY: sandbox
sandbox: sandbox-index
	$(PREFIX)/bin/sourcemeta-registry-server \
		$(OUTPUT)/sandbox $(SANDBOX_PORT)

.PHONY: docker
docker:
	$(DOCKER) build --tag registry . --file Dockerfile --progress plain
	SOURCEMETA_REGISTRY_SANDBOX_CONFIGURATION=$(SANDBOX_CONFIGURATION) \
	SOURCEMETA_REGISTRY_SANDBOX_PORT=$(SANDBOX_PORT) \
		$(DOCKER) compose --file test/sandbox/compose.yaml config
	SOURCEMETA_REGISTRY_SANDBOX_CONFIGURATION=$(SANDBOX_CONFIGURATION) \
	SOURCEMETA_REGISTRY_SANDBOX_PORT=$(SANDBOX_PORT) \
		$(DOCKER) compose --progress plain --file test/sandbox/compose.yaml up --build

.PHONY: docs
docs: mkdocs.yml
	$(MKDOCS) serve --config-file $< --strict --open

.PHONY: public
public:
	$(PREFIX)/bin/sourcemeta-registry-index $(PUBLIC)/registry.json $(OUTPUT)/public --verbose
	$(PREFIX)/bin/sourcemeta-registry-server $(OUTPUT)/public 8000

.PHONY: clean
clean:
	$(CMAKE) -E rm -R -f build
	$(DOCKER) system prune --force --all --volumes || true
