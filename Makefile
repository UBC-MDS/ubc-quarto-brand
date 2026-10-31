# ubc-quarto-brand: a command anyone runs more than once is a target here (`make help`).
.PHONY: help setup hooks check test test-utc lint docs leaks clean fetch-521

help: ## List the targets
	@grep -E '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install the Python (uv) and R (renv) packages for the executed cells
	uv sync
	Rscript -e 'renv::restore(prompt = FALSE)'

hooks: ## Install the git hooks (none exist yet)
	@echo "No git hooks are installed yet: plan-driven-development's hooks are not built."

check: test test-utc lint docs leaks ## Everything CI runs

test: ## Render the test book, fail on any Quarto warning, then check the output
	@rm -rf _book
	uv run quarto render 2>&1 | tee .render.log
	@if grep -E 'WARN|ERROR' .render.log; then echo "Quarto warned or failed: see .render.log"; exit 1; fi
	tests/check-render.sh

test-utc: ## Re-run the output checks under TZ=UTC
	TZ=UTC tests/check-render.sh

lint: ## Lint the GitHub Actions workflows
	uvx --from actionlint-py actionlint .github/workflows/*.yml

docs: ## Check the rendered book's links (CI runs lychee if it isn't installed here)
	@if command -v lychee >/dev/null; then lychee --offline --no-progress _book; else echo "lychee not installed: the link check runs in CI"; fi

leaks: ## Scan the whole git history for secrets
	gitleaks git --redact --no-banner .

clean: ## Remove rendered output
	rm -rf _book .quarto .render.log .render-website.log tests/website/_extensions tests/website/_site tests/website/.quarto

fetch-521: ## Re-fetch the brand files from DSCI 521 (SHA=<commit> to change the pin)
	scripts/fetch-521.sh $(SHA)
