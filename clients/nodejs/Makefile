SANDBOX_PORT ?= 8000
SANDBOX_URL ?= http://localhost:$(SANDBOX_PORT)

.PHONY: all
all: test

.PHONY: test
test:
	./test/bundling-commonjs.sh $(SANDBOX_URL)
	./test/bundling-modules.sh $(SANDBOX_URL)
	./test/postinstall-auto.sh $(SANDBOX_URL)
	./test/schema-add.sh $(SANDBOX_URL)
	./test/nested-package.sh $(SANDBOX_URL)
