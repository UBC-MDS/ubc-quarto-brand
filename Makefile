# ubc-quarto-brand: a command anyone runs more than once is a target here (`make help`).
.PHONY: help setup deps hooks check test test-utc lint docs leaks clean fetch-521

help: ## List the targets
	@grep -E '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install the Python (uv) and R (renv) packages for the executed cells
	uv sync
	Rscript -e 'renv::restore(prompt = FALSE)'

# custom-callout and quizdown, which the brand styles but does not ship (Q&A 33), in the
# folders `quarto add <owner>/<repo>` uses, which git ignores. CI runs their Lua filters
# with write access, so each is fetched at a pinned commit, like the actions' SHAs (Q&A 35):
# `quarto add` cannot take a commit. Moving a pin is a reviewed commit; a changed pin
# re-fetches, because these targets depend on the Makefile.
CALLOUT_SHA := 810a6472b16f7826812a912a70f6e4a0bf373887
QUIZDOWN_SHA := aff12fa75f33dc4cabaf4c998412209ce4fd6026
CALLOUT := _extensions/coatless-quarto/custom-callout/_extension.yml
QUIZDOWN := _extensions/UBC-MDS/quizdown/_extension.yml

deps: ## Re-install custom-callout and quizdown at their pinned commits (the brand styles them but does not ship them)
	rm -rf _extensions/coatless-quarto _extensions/UBC-MDS/quizdown
	$(MAKE) $(CALLOUT) $(QUIZDOWN)

$(CALLOUT): Makefile
	rm -rf $(@D) && mkdir -p $(@D)
	curl -sSfL https://github.com/coatless-quarto/custom-callout/archive/$(CALLOUT_SHA).tar.gz \
	  | tar -xzf - -C $(@D) --strip-components=3 custom-callout-$(CALLOUT_SHA)/_extensions/custom-callout
	touch $@

$(QUIZDOWN): Makefile
	rm -rf $(@D) && mkdir -p $(@D)
	curl -sSfL https://github.com/UBC-MDS/quarto-quizdown-mds-ext/archive/$(QUIZDOWN_SHA).tar.gz \
	  | tar -xzf - -C $(@D) --strip-components=3 quarto-quizdown-mds-ext-$(QUIZDOWN_SHA)/_extensions/quizdown
	touch $@

hooks: ## Install the git hooks (none exist yet)
	@echo "No git hooks are installed yet: plan-driven-development's hooks are not built."

check: test test-utc lint docs leaks ## Everything CI runs

test: $(CALLOUT) $(QUIZDOWN) ## Render the test book and the website check, fail on any Quarto warning, then check the output
	@rm -rf _book
	uv run quarto render 2>&1 | tee .render.log
	@if grep -E 'WARN|ERROR' .render.log; then echo "Quarto warned or failed: see .render.log"; exit 1; fi
	rm -rf tests/website/_extensions tests/website/_site
	mkdir -p tests/website/_extensions/UBC-MDS
	cp -R _extensions/ubc tests/website/_extensions/UBC-MDS/ubc
	cp -R _extensions/UBC-MDS/quizdown tests/website/_extensions/UBC-MDS/quizdown
	cp -R _extensions/coatless-quarto tests/website/_extensions/coatless-quarto
	cd tests/website && uv run quarto render 2>&1 | tee ../../.render-website.log
	@if grep -E 'WARN|ERROR' .render-website.log; then echo "Quarto warned or failed: see .render-website.log"; exit 1; fi
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

fetch-521: ## Re-fetch the brand files from DSCI 521 at the pinned commit (SHA=<commit> fetches another; the pin is in scripts/fetch-521.sh)
	scripts/fetch-521.sh $(SHA)
