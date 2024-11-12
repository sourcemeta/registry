# Programs
CMAKE ?= cmake
HURL ?= hurl
JSONSCHEMA ?= jsonschema
DOCKER ?= docker

# Options
INDEX ?= ON
SERVER ?= ON
PRESET ?= Debug
OUTPUT ?= ./build
PREFIX ?= $(OUTPUT)/dist
SANDBOX ?= ./test/sandbox

.PHONY: all
all: configure compile test

.PHONY: configure
configure: 
	$(CMAKE) -S . -B $(OUTPUT) \
		-DCMAKE_BUILD_TYPE:STRING=$(PRESET) \
		-DCMAKE_COMPILE_WARNING_AS_ERROR:BOOL=ON \
		-DREGISTRY_DEVELOPMENT:BOOL=ON \
		-DREGISTRY_INDEX:BOOL=$(INDEX) \
		-DREGISTRY_SERVER:BOOL=$(SERVER) \
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
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target clang_format

.PHONY: test
test: 
	./test/cli/index/no-options.sh $(PREFIX)/bin/sourcemeta-registry-index
	./test/cli/index/invalid-configuration.sh $(PREFIX)/bin/sourcemeta-registry-index

.PHONY: test-e2e
test-e2e: 
	$(HURL) --test \
		--variable base=$(shell jq --raw-output '.url' < $(SANDBOX)/configuration.json) \
		test/e2e/*.hurl

.PHONY: sandbox
sandbox: compile
	$(PREFIX)/bin/sourcemeta-registry-index $(SANDBOX)/configuration.json $(OUTPUT)/sandbox
	./test/sandbox/manifest-check.sh $(OUTPUT)/sandbox $(SANDBOX)/manifest.txt
	$(PREFIX)/bin/sourcemeta-registry-server $(OUTPUT)/sandbox

.PHONY: docker
docker:
	$(DOCKER) build --tag registry . --progress plain
	$(DOCKER) compose up --build

.PHONY: clean
clean: 
	$(CMAKE) -E rm -R -f build
	$(DOCKER) system prune --force --all --volumes || true
