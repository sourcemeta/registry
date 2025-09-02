# Programs
CMAKE ?= cmake
CTEST ?= ctest
HURL ?= hurl
DOCKER ?= docker
SHELLCHECK ?= shellcheck
MKDOCS ?= mkdocs
NPM ?= npm

# Options
INDEX ?= ON
SERVER ?= ON
EDITION ?= enterprise
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
		-DREGISTRY_EDITION:STRING=$(EDITION) \
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
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target jsonschema_fmt

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
test-e2e:
	$(HURL) --test --variable base=$(SANDBOX_URL) \
		test/e2e/$(SANDBOX_CONFIGURATION)/*.hurl \
		test/e2e/api/*.hurl \
		test/e2e/explorer/*.hurl \
		test/e2e/schemas/*.hurl

.PHONY: sandbox
sandbox: compile
	SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1 \
		$(PREFIX)/bin/sourcemeta-registry-index \
		$(SANDBOX)/registry-$(SANDBOX_CONFIGURATION).json \
		$(OUTPUT)/sandbox --url $(SANDBOX_URL)
	./test/sandbox/manifest-check.sh $(OUTPUT)/sandbox \
		$(SANDBOX)/manifest-$(SANDBOX_CONFIGURATION).txt
	SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1 \
		$(PREFIX)/bin/sourcemeta-registry-server \
		$(OUTPUT)/sandbox $(SANDBOX_PORT)

.PHONY: docker
docker:
	$(DOCKER) build --tag registry-$(EDITION) . --file Dockerfile \
		--build-arg SOURCEMETA_REGISTRY_EDITION=$(EDITION) \
		--progress plain
	SOURCEMETA_REGISTRY_EDITION=$(EDITION) \
	SOURCEMETA_REGISTRY_CONFIGURATION=$(SANDBOX_CONFIGURATION) \
	SOURCEMETA_REGISTRY_PORT=$(SANDBOX_PORT) \
		$(DOCKER) compose --file test/sandbox/compose.yaml config
	SOURCEMETA_REGISTRY_EDITION=$(EDITION) \
	SOURCEMETA_REGISTRY_CONFIGURATION=$(SANDBOX_CONFIGURATION) \
	SOURCEMETA_REGISTRY_PORT=$(SANDBOX_PORT) \
		$(DOCKER) compose --file test/sandbox/compose.yaml up --build

.PHONY: docs
docs: mkdocs.yml
	$(MKDOCS) serve --config-file $< --strict --open

.PHONY: public
public:
	SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1 \
		$(PREFIX)/bin/sourcemeta-registry-index $(PUBLIC)/registry.json $(OUTPUT)/public
	SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1 \
		$(PREFIX)/bin/sourcemeta-registry-server $(OUTPUT)/public

.PHONY: clean
clean:
	$(CMAKE) -E rm -R -f build
	$(DOCKER) system prune --force --all --volumes || true
