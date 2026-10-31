# ubc-quarto-brand: a command anyone runs more than once is a target here (`make help`).
.PHONY: help hooks check test test-utc lint leaks docs

help: ## List the targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-9s %s\n", $$1, $$2}'

hooks: ## Install the git hooks (none exist yet)
	@echo "No git hooks are installed yet: plan-driven-development's hooks are not built."

check: test test-utc leaks ## Run the tests, the tests under TZ=UTC, and the leak scan

test: ## Run the test suite
	@echo "no test command yet: the plan's CI task sets it"; exit 1

test-utc: ## Run the tests with TZ=UTC
	TZ=UTC $(MAKE) test

lint: ## Run the linters
	@echo "no lint command yet: the plan's CI task sets it"; exit 1

leaks: ## Scan the whole git history for secrets
	gitleaks git --redact --no-banner .

docs: ## Render the test book and docs site
	@echo "no docs command yet: the plan's site task sets it"; exit 1
