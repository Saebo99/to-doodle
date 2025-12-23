SHELL := /bin/bash

UID := $(shell id -u)
GID := $(shell id -g)

APP_DIR := app
BACKEND_DIR := backend

DC := docker compose run --rm dev
DC_APP := docker compose run --rm -w /workspace/$(APP_DIR) dev
DC_BACKEND := docker compose run --rm -w /workspace/$(BACKEND_DIR) dev

.PHONY: setup shell doctor format lint test run-web clean go-test go-fmt go-lint

setup: ## Build image + install git hooks
	@echo "UID=$(UID)" > .env
	@echo "GID=$(GID)" >> .env
	@docker compose build
	@git config core.hooksPath .githooks
	@chmod +x .githooks/* || true
	@echo "Setup complete. Try: make doctor"

shell: ## Open a shell inside the dev container
	@$(DC) bash

doctor: ## Diagnose toolchain versions
	@$(DC_APP) flutter doctor -v
	@$(DC) go version

deps: # Get Flutter dependencies
	@$(DC_APP) flutter pub get

deps-reset: ## Remove host-generated flutter artifacts + re-get deps (in container)
	@$(DC_APP) bash -lc 'rm -rf .dart_tool .packages .flutter-plugins .flutter-plugins-dependencies build && flutter clean && flutter pub get'

format: ## Format Dart
	@$(DC_APP) dart format .

lint: ## Flutter analyze
	@$(DC_APP) flutter analyze

test: ## Flutter tests
	@$(DC_APP) flutter test

run-web: ## Flutter web server on port 5000
	@docker compose run --rm --service-ports dev \
		flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000

clean: ## Flutter clean
	@$(DC_APP) flutter clean

go-fmt: ## gofmt backend
	@$(DC) bash -lc 'test -d $(BACKEND_DIR) || exit 0; gofmt -w $(BACKEND_DIR)'

go-test: ## go test backend
	@$(DC) bash -lc 'test -d $(BACKEND_DIR) || exit 0; go test ./...'

go-lint: ## golangci-lint (installs in container uses GOPATH)
	@$(DC) bash -lc \
		'test -d $(BACKEND_DIR) || exit 0; \
		command -v golangci-lint >/dev/null 2>&1 || go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest; \
		cd $(BACKEND_DIR) && golangci-lint run ./...'


