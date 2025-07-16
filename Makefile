# Programs
CMAKE ?= cmake
CTEST ?= ctest
HURL ?= hurl
DOCKER ?= docker
SHELLCHECK ?= shellcheck
MKDOCS ?= mkdocs
JSONSCHEMA ?= ./build/dist/bin/jsonschema
NODE ?= node
MKDIR ?= mkdir

# Options
INDEX ?= ON
SERVER ?= ON
EDITION ?= enterprise
PRESET ?= Debug
OUTPUT ?= ./build
PREFIX ?= $(OUTPUT)/dist
SANDBOX ?= ./test/sandbox
PUBLIC ?= ./public

.PHONY: all
all: configure compile test 

.PHONY: configure
configure: 
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
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target jsonschema_fmt_test
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target shellcheck
	$(CMAKE) --build $(OUTPUT) --config $(PRESET) --target jsonschema_lint

.PHONY: test
test: 
	$(CTEST) --test-dir $(OUTPUT) --build-config $(PRESET) --output-on-failure --parallel

.PHONY: test-e2e
test-e2e: 
	$(HURL) --test \
		--variable base=$(shell jq --raw-output '.url' < $(SANDBOX)/registry.json) \
			test/e2e/*.hurl

.PHONY: sandbox
sandbox: compile
	SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1 \
		$(PREFIX)/bin/sourcemeta-registry-index $(SANDBOX)/registry.json $(OUTPUT)/sandbox
	./test/sandbox/manifest-check.sh $(OUTPUT)/sandbox $(SANDBOX)/manifest.txt
	SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1 \
		$(PREFIX)/bin/sourcemeta-registry-server $(OUTPUT)/sandbox

.PHONY: docker
docker:
	$(DOCKER) build --tag registry-$(EDITION) . --file Dockerfile \
		--build-arg SOURCEMETA_REGISTRY_EDITION=$(EDITION) --progress plain
	SOURCEMETA_REGISTRY_EDITION=$(EDITION) \
		$(DOCKER) compose --file test/sandbox/compose.yaml config
	SOURCEMETA_REGISTRY_EDITION=$(EDITION) \
		$(DOCKER) compose --file test/sandbox/compose.yaml up --build

.PHONY: docs
docs: mkdocs.yml
	$(MKDOCS) serve --config-file $< --strict --open

define geojson_prepare
$(OUTPUT)/geojson-$(1)/%.json: vendor/public/geojson-$(1)/bin/format.js vendor/public/geojson-$(1)/src/schema/%.js
	$(MKDIR) -p $$(dir $$@) && $(NODE) $$< $$(word 2,$$^) > $$@
endef
$(eval $(call geojson_prepare,1-0-5))
$(eval $(call geojson_prepare,1-0-4))
$(eval $(call geojson_prepare,1-0-3))
$(eval $(call geojson_prepare,1-0-2))
$(eval $(call geojson_prepare,1-0-1))
$(eval $(call geojson_prepare,1-0-0))
.PHONY: public-prepare
public-prepare: \
	$(patsubst vendor/public/geojson-1-0-5/src/schema/%.js,$(OUTPUT)/geojson-1-0-5/%.json,$(wildcard vendor/public/geojson-1-0-5/src/schema/*.js)) \
	$(patsubst vendor/public/geojson-1-0-4/src/schema/%.js,$(OUTPUT)/geojson-1-0-4/%.json,$(wildcard vendor/public/geojson-1-0-4/src/schema/*.js)) \
	$(patsubst vendor/public/geojson-1-0-3/src/schema/%.js,$(OUTPUT)/geojson-1-0-3/%.json,$(wildcard vendor/public/geojson-1-0-3/src/schema/*.js)) \
	$(patsubst vendor/public/geojson-1-0-2/src/schema/%.js,$(OUTPUT)/geojson-1-0-2/%.json,$(wildcard vendor/public/geojson-1-0-2/src/schema/*.js)) \
	$(patsubst vendor/public/geojson-1-0-1/src/schema/%.js,$(OUTPUT)/geojson-1-0-1/%.json,$(wildcard vendor/public/geojson-1-0-1/src/schema/*.js)) \
	$(patsubst vendor/public/geojson-1-0-0/src/schema/%.js,$(OUTPUT)/geojson-1-0-0/%.json,$(wildcard vendor/public/geojson-1-0-0/src/schema/*.js))
.PHONY: public
public: public-prepare
	SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1 \
		$(PREFIX)/bin/sourcemeta-registry-index $(PUBLIC)/registry.json $(OUTPUT)/public
	SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1 \
		$(PREFIX)/bin/sourcemeta-registry-server $(OUTPUT)/public

.PHONY: clean
clean: 
	$(CMAKE) -E rm -R -f build
	$(DOCKER) system prune --force --all --volumes || true
