# ubc-quarto-brand Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Every rule for running a task is in `AGENTS.md`; read it first.

**Goal:** A Quarto extension, `ubc`, that packages the DSCI 521 book's UBC brand as a `ubc-html` format, with a test book at the repository root that renders every part of it and deploys as the demo.

**Architecture:** `_extensions/ubc/` contributes the brand through `metadata: project: brand:` and a `ubc-html` format (theme layers, the code-labels filter, embedded custom-callout and quizdown). Its files are fetched from DSCI 521 at one pinned commit by `scripts/fetch-521.sh`. The repository root is a Quarto book using that format; `tests/website/` is a one-page website using it from a GitHub-style install folder. `tests/check-render.sh` asserts on the rendered HTML and CSS.

**Tech Stack:** Quarto 1.11.6, brand.yml, SCSS, Lua filters, custom-callout 0.0.1-dev.3, quizdown 1.3.2; R 4.6.2 with renv (knitr, rmarkdown, reticulate, here); Python 3.14 with uv (matplotlib); GitHub Actions with pr-preview-action, github-pages-deploy-action and lychee-action; gitleaks 8.30.1; actionlint.

**Spec:** `docs/superpowers/specs/2026-10-30-ubc-quarto-brand-design.md`

**Now:** Task 2: The ubc extension, open.

## Global Constraints

- DSCI 521 source: `UBC-MDS/DSCI_521_platforms-dsci_book` at `991bae89cba904ae2dd0753338c306333eb5ea2e` (`991bae89cba9`).
- Extension folder `_extensions/ubc/`; format `ubc-html`; `version: 0.1.0`; `quarto-required: ">=1.11.0"`.
- CI: `ubuntu-latest`, Quarto `1.11.6`, R `4.6.2`, Python `3.14` (`.python-version`).
- Callouts (literal hex): activity `fa-person-chalkboard` `#0055B7`; exercise `fa-dumbbell` `#1C5F2E`; definition `fa-book-open` `#8A6D2B`; relevance-project, titled "Relevance to course project", `fa-diagram-project` `#0077C8`.
- Third-party actions pinned by SHA: `astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2` (v10.3.3), `rossjrw/pr-preview-action@873417d2df72380da1f3978378fb58560bcde976` (v1.8.2), `JamesIves/github-pages-deploy-action@fa24774553152dd7873cd16ebd8d959b010c5445` (v4.9.0), `lycheeverse/lychee-action@e7477775783ea5526144ba13e8db5eec57747ce8` (v2.9.0). GitHub's, Quarto's and r-lib's own actions stay on major tags.
- The agent commits and pushes straight to `main` (Q&A 29) after a passing `make leaks`; it never tags (Q&A 17).
- Commits: message in a file, `git commit -F`, stage by path, the `Plan:` trailer checked with `git log -1 --format='%(trailers)'`, and `uv run --quiet --script scripts/commitmsg.py <file>` before committing.

## Review Focus

1. **A book installed from GitHub** has the extension at `_extensions/UBC-MDS/ubc/`, not `_extensions/ubc/`; brand, filters and the logo path must resolve there. Task 5's website check installs into that folder.
2. **A page with no callout, listing or quiz** must still get the fonts, colours and dark mode. Task 2 asserts on the Home page.
3. **Dark mode's derived colours:** tab titles fall back to black on navy unless `$body-emphasis-color` is set. Task 2 asserts `--bs-emphasis-color` in the dark bundle.
4. **A book's own theme layer** must come after the extension's and see `$brand-*` names. Task 5's website check adds one.
5. **A pull request from a fork** cannot write a preview. It is documented in the spec's risks; no test can run it.

***

### Task 1: Environment, test book skeleton and CI

**Tier:** 3 · **Scenarios:** S13, S14

**Ruling:** test-utc re-runs the output checks, not the render: nothing rendered depends on the time zone; costs a render-time date bug going unseen.

**Ruling:** the plan's index.qmd listing escapes its shortcode (`{{{< … >}}}`), because Quarto expanded it when rendering this plan as a page; costs a reader copying three braces.

**Files:**
- Create: `.python-version`, `pyproject.toml`, `uv.lock`, `DESCRIPTION`, `renv.lock`, `.Rprofile`, `renv/activate.R`, `renv/settings.json`, `renv/.gitignore`, `.gitignore`, `_quarto.yml`, `index.qmd`, `tests/check-render.sh`, `.github/workflows/pr.yml`, `.github/workflows/publish.yml`
- Modify: `Makefile`

**Interfaces:**
- Consumes: nothing.
- Produces: `make setup`, `make test` (renders the book into `_book/`, fails on any Quarto `WARN` or `ERROR`, then runs `tests/check-render.sh`), `make test-utc`, `make lint`, `make docs`, `make leaks`, `make check`; `tests/check-render.sh` with `expect <description> <pattern> <file>` (case-insensitive extended regex) and `exists <description> <path>`, and `BOOK=_book`. Later tasks append sections to it.

- [x] **Step 0: Record the base:** `git rev-parse HEAD > .git/TASK_BASE`.

- [x] **Step 1: Write the failing test,** `tests/check-render.sh`, and `chmod 755` it:

```bash
#!/usr/bin/env bash
# Checks the rendered test book, and from Task 5 the website check, for every
# part of the brand. Run by `make test` after the renders.
set -euo pipefail
fail=0

expect() { # expect <description> <pattern> <file>: case-insensitive extended regex
  if grep -q -i -E -- "$2" "$3" 2>/dev/null; then echo "ok   $1"; else echo "FAIL $1 ($3)"; fail=1; fi
}
exists() { # exists <description> <path>
  if [ -e "$2" ]; then echo "ok   $1"; else echo "FAIL $1 ($2 missing)"; fail=1; fi
}

BOOK=_book

# --- Task 1: the book and the project docs render (S13, S14)
exists "home page"         "$BOOK/index.html"
exists "spec page"         "$BOOK/docs/superpowers/specs/2026-10-30-ubc-quarto-brand-design.html"
exists "kickoff Q&A page"  "$BOOK/docs/superpowers/specs/2026-10-30-ubc-quarto-brand-qa.html"
exists "plan page"         "$BOOK/docs/superpowers/plans/2026-10-30-ubc-quarto-brand.html"
exists "changelog page"    "$BOOK/CHANGELOG.html"
exists "how we work page"  "$BOOK/AGENTS.html"

exit $fail
```

- [x] **Step 2: Run it; watch it fail.** `tests/check-render.sh`. Expected: `FAIL home page (_book/index.html missing)` and exit 1.

- [x] **Step 3: Create the Python and R environments** for the executed cells (Task 3):

```bash
printf '3.14\n' > .python-version
uv init --bare --no-workspace --python 3.14 --name ubc-quarto-brand
uv add matplotlib
cat > DESCRIPTION <<'EOF'
Type: Project
Description: The R packages the test book's executed cells need. Not an R package.
Imports:
    knitr,
    rmarkdown,
    reticulate,
    here
EOF
Rscript -e 'renv::init(bare = TRUE, restart = FALSE)'
Rscript -e 'renv::settings$snapshot.type("explicit"); options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest")); renv::install(c("knitr", "rmarkdown", "reticulate", "here"), prompt = FALSE); renv::snapshot(prompt = FALSE)'
```

Expected: `uv.lock`, `.Rprofile`, `renv/`, and a `renv.lock` recording R 4.6.2 and the four packages.

- [x] **Step 4: Write `.gitignore`:**

```text
/_book/
/.quarto/
/.render.log
/.render-website.log
/.venv/
.Rproj.user/
.Rhistory
/tests/website/_extensions/
/tests/website/_site/
/tests/website/.quarto/
*.quarto_ipynb
.superpowers/
```

- [x] **Step 5: Write the book,** `_quarto.yml`:

```yaml
project:
  type: book
  # Only these become pages: README.md is included by index.qmd, and
  # tests/website/ is its own project.
  render:
    - index.qmd
    - docs/superpowers/specs/2026-10-30-ubc-quarto-brand-design.md
    - docs/superpowers/specs/2026-10-30-ubc-quarto-brand-qa.md
    - docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md
    - CHANGELOG.md
    - AGENTS.md

book:
  title: "UBC Quarto brand"
  subtitle: "The DSCI 521 book's brand, as a Quarto extension"
  site-url: https://ubc-mds.github.io/ubc-quarto-brand/
  repo-url: https://github.com/UBC-MDS/ubc-quarto-brand
  repo-actions: [source, issue]
  chapters:
    - index.qmd
    - part: "The project"
      chapters:
        - docs/superpowers/specs/2026-10-30-ubc-quarto-brand-design.md
        - docs/superpowers/specs/2026-10-30-ubc-quarto-brand-qa.md
        - docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md
        - CHANGELOG.md
        - AGENTS.md

format: html
```

and `index.qmd`, whose title is the README's first heading:

```markdown
{{{< include README.md >}}}
```

  (The plan writes the shortcode with Quarto's triple-brace escape, so this page renders on the site; the file itself holds the two-brace form.)

- [x] **Step 6: Replace the `Makefile`** (GNU make 3.81):

```make
# ubc-quarto-brand: a command anyone runs more than once is a target here (`make help`).
.PHONY: help setup hooks check test test-utc lint docs leaks clean

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
```

`test-utc` re-runs the checks rather than the render: nothing the render produces depends on the time zone (Ruling).

- [x] **Step 7: Write `.github/workflows/pr.yml`:**

```yaml
on:
  pull_request:
    branches: main
    types: [opened, reopened, synchronize, closed]

name: PR preview

# One run per PR: a newer event (a push, or the PR closing) cancels an older
# run, so a merge mid-build never deploys a preview after its removal.
concurrency:
  group: preview-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  preview:
    runs-on: ubuntu-latest
    permissions:
      contents: write # push the preview to gh-pages
      pull-requests: write # comment the preview link on the PR
    steps:
      - name: Check out repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # make leaks scans the whole history

      # The build steps are skipped when the PR closes;
      # the last step then removes the preview.
      - name: Set up Quarto
        if: github.event.action != 'closed'
        uses: quarto-dev/quarto-actions/setup@v2
        with:
          version: 1.11.6

      - name: Set up uv
        if: github.event.action != 'closed'
        # third-party: pin the SHA
        uses: astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2 # v10.3.3
        with:
          enable-cache: true # installs the Python in .python-version

      - name: Install Python packages
        if: github.event.action != 'closed'
        run: uv sync --locked

      - name: Install R
        if: github.event.action != 'closed'
        uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.6.2'

      - name: Install R packages
        if: github.event.action != 'closed'
        uses: r-lib/actions/setup-renv@v2

      - name: Install gitleaks
        if: github.event.action != 'closed'
        run: |
          cd "$RUNNER_TEMP"
          curl -sSfLO https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz
          curl -sSfLO https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_checksums.txt
          grep ' gitleaks_8.30.1_linux_x64.tar.gz$' gitleaks_8.30.1_checksums.txt | sha256sum -c -
          tar -xzf gitleaks_8.30.1_linux_x64.tar.gz gitleaks
          echo "$RUNNER_TEMP" >> "$GITHUB_PATH"

      - name: Render and check
        if: github.event.action != 'closed'
        run: make check

      - name: Check links
        if: github.event.action != 'closed'
        # third-party: pin the SHA
        uses: lycheeverse/lychee-action@e7477775783ea5526144ba13e8db5eec57747ce8 # v2.9.0
        with:
          args: --offline --no-progress _book
          fail: true

      # Deploys _book/ to gh-pages under pr-preview/pr-<N>/ and comments the
      # link, or removes the preview when the PR closes.
      - name: Deploy PR preview
        # third-party action with write access: pin the SHA
        uses: rossjrw/pr-preview-action@873417d2df72380da1f3978378fb58560bcde976 # v1.8.2
        with:
          source-dir: _book
```

- [x] **Step 8: Write `.github/workflows/publish.yml`:**

```yaml
on:
  workflow_dispatch:
  push:
    branches: main

name: Publish

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: write # push the book to gh-pages
    steps:
      - name: Check out repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # make leaks scans the whole history

      - name: Set up Quarto
        uses: quarto-dev/quarto-actions/setup@v2
        with:
          version: 1.11.6

      - name: Set up uv
        # third-party: pin the SHA
        uses: astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2 # v10.3.3
        with:
          enable-cache: true

      - name: Install Python packages
        run: uv sync --locked

      - name: Install R
        uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.6.2'

      - name: Install R packages
        uses: r-lib/actions/setup-renv@v2

      - name: Install gitleaks
        run: |
          cd "$RUNNER_TEMP"
          curl -sSfLO https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz
          curl -sSfLO https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_checksums.txt
          grep ' gitleaks_8.30.1_linux_x64.tar.gz$' gitleaks_8.30.1_checksums.txt | sha256sum -c -
          tar -xzf gitleaks_8.30.1_linux_x64.tar.gz gitleaks
          echo "$RUNNER_TEMP" >> "$GITHUB_PATH"

      - name: Render and check
        run: make check

      - name: Check links
        # third-party: pin the SHA
        uses: lycheeverse/lychee-action@e7477775783ea5526144ba13e8db5eec57747ce8 # v2.9.0
        with:
          args: --offline --no-progress _book
          fail: true

      # Keeps the PR previews in pr-preview/ and does not force-push,
      # as the pr-preview-action README recommends.
      - name: Deploy to GitHub Pages
        # third-party action with write access: pin the SHA
        uses: JamesIves/github-pages-deploy-action@fa24774553152dd7873cd16ebd8d959b010c5445 # v4.9.0
        with:
          folder: _book
          branch: gh-pages
          clean-exclude: pr-preview
          force: false
```

- [x] **Step 9: Run the checks; they pass.** `make setup && make check`. Expected: every `ok` line, `no leaks found`, actionlint silent, and no `FAIL`.

- [x] **Step 10: Commit.** Write the message to a file:

```text
build(repo): 🤖 add the test book skeleton, the environment and CI

The repository root becomes a Quarto book (plain html for now) that
renders the project docs as chapters, with tests/check-render.sh
checking the output. uv (Python 3.14, matplotlib) and renv (R 4.6.2:
knitr, rmarkdown, reticulate, here) hold what Task 3's executed cells
need. pr.yml previews every PR with pr-preview-action, cancelling a
PR's older run; publish.yml deploys main to gh-pages without wiping the
previews. The test first failed with: FAIL home page (_book/index.html
missing).

Plan: docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md Task 1
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

  `git add .python-version pyproject.toml uv.lock DESCRIPTION renv.lock .Rprofile renv/activate.R renv/settings.json renv/.gitignore .gitignore _quarto.yml index.qmd tests/check-render.sh .github/workflows/pr.yml .github/workflows/publish.yml Makefile`, `git commit -F <file>`, `git log -1 --format='%(trailers)'`. Then `make leaks` and `git push origin main`.

- [x] **Step 11: Review, look forward, close.** Tier 3: a self-review under *Standards* and *Spec*, plus the mechanical checks. Close with the plan's boxes ticked, **Now** set to `Task 2: The ubc extension, open.`, the spec's S13 and S14 rows noting the workflows exist (status stays `planned` until the PR and the publish run prove them), and this message:

```text
docs(plan): 🤖 close Task 1: Environment, test book skeleton and CI

Drift: none
Rulings: test-utc re-runs the output checks, not the render: nothing rendered depends on the time zone.
Phase-end: none
Forward: none
Tier: 3
Rounds: self-review (Standards, Spec) and make check
Findings: none

Plan: docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md Task 1
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

***

### Task 2: The ubc extension

**Tier:** 2 · **Scenarios:** S01, S02, S03, S06

**Files:**
- Create: `scripts/fetch-521.sh`; `_extensions/ubc/_extension.yml`; fetched by the script: `_extensions/ubc/brand.yml`, `styles.scss`, `styles-dark.scss`, `code-labels.lua`, `quizdown-theme.html`, `MDSlogo.png`, `_extensions/ubc/_extensions/coatless-quarto/custom-callout/{_extension.yml,customcallout.lua,fa.lua,assets/css/fontawesome.css,assets/webfonts/fa-solid-900.woff2}`, `_extensions/ubc/_extensions/quizdown/{_extension.yml,quizdown.lua,assets/quizdown-init.js,assets/quizdown.js,assets/quizdownHighlight.js,assets/quizdownKatex.js}`
- Modify: `_quarto.yml` (`format: ubc-html`), `tests/check-render.sh`, `Makefile`

**Interfaces:**
- Consumes: Task 1's `make test`, `expect`, `exists`, `BOOK`.
- Produces: the `ubc-html` format; `scripts/fetch-521.sh [commit]` with `fetch <path in 521> <path here>`; `make fetch-521`; in `tests/check-render.sh`, `LIGHT` and `DARK` (the book's light and dark Bootstrap bundles), which Tasks 3 to 5 reuse.

- [ ] **Step 0: Record the base:** `git rev-parse HEAD > .git/TASK_BASE`.

- [ ] **Step 1: Write the failing test.** Insert before `exit $fail` in `tests/check-render.sh`:

```bash
# --- Task 2: the brand on every page, the Home page included (S01, S02, S03, S06)
LIGHT=$(ls "$BOOK"/site_libs/bootstrap/bootstrap-*.min.css 2>/dev/null | grep -v -- '-dark-' | head -1 || true)
DARK=$(ls "$BOOK"/site_libs/bootstrap/bootstrap-dark-*.min.css 2>/dev/null | head -1 || true)
exists "light stylesheet"              "${LIGHT:-$BOOK/site_libs/bootstrap/bootstrap-LIGHT-missing.min.css}"
exists "dark stylesheet"               "${DARK:-$BOOK/site_libs/bootstrap/bootstrap-DARK-missing.min.css}"
expect "UBC blue in the palette"       '--brand-ubc-blue: ?#002145'                                  "$LIGHT"
expect "primary is UBC deep blue"      '--bs-primary: ?#0055B7'                                      "$LIGHT"
expect "navbar in UBC blue"            '\.navbar\{[^}]*background-color:#002145'                     "$LIGHT"
expect "Atkinson Hyperlegible Next"    'fonts\.googleapis\.com/css2\?family=Atkinson\+Hyperlegible\+Next' "$LIGHT"
expect "Atkinson Hyperlegible Mono"    'fonts\.googleapis\.com/css2\?family=Atkinson\+Hyperlegible\+Mono' "$LIGHT"
expect "dark page in UBC video blue"   '--bs-body-bg: ?#001328'                                      "$DARK"
expect "dark tab titles readable"      '--bs-emphasis-color: ?#ffffff'                               "$DARK"
expect "dark scrollbars"               'color-scheme:dark'                                           "$DARK"
expect "listing label bar rule"        '\.code-with-filename \.code-with-filename-file\{padding-top:\.1em' "$LIGHT"
expect "output listing surface"        'pre\.out\{padding:\.4em'                                     "$LIGHT"
expect "exercise counter"              '\.callout-exercise\{counter-increment:exercise\}'            "$LIGHT"
expect "exercise number in the title"  'counter\(exercise\)'                                         "$LIGHT"
expect "console window"                '\.term\{background:#1d2129'                                  "$LIGHT"
expect "quiz colours, light"           '--mds-quiz-fg: ?#002145'                                     "$LIGHT"
expect "quiz hover, dark"              '--mds-quiz-press: ?brightness\(1\.45\)'                       "$DARK"
expect "dark-mode toggle on Home"      'quarto-color-scheme-toggle'                                  "$BOOK/index.html"
expect "dark stylesheet linked"        'bootstrap-dark-[0-9a-f]+\.min\.css'                          "$BOOK/index.html"
expect "quizdown scripts on Home"      'quarto-contrib/quizdown-[0-9.]+/quizdown\.js'                "$BOOK/index.html"
expect "quiz theme include on Home"    'data-mds-quiz-theme'                                         "$BOOK/index.html"
```

- [ ] **Step 2: Run it; watch it fail.** `make test`. Expected: `FAIL dark stylesheet` (plain `html` has no dark bundle) and `FAIL UBC blue in the palette` (no brand yet), and exit 1.

- [ ] **Step 3: Write `scripts/fetch-521.sh`** and `chmod 755` it:

```bash
#!/usr/bin/env bash
# Copies the brand from the DSCI 521 book into this extension, from one pinned
# commit, so every file here can be traced to its original (the book's "Where it
# comes from" page). Usage: scripts/fetch-521.sh [commit]
set -euo pipefail
SHA="${1:-991bae89cba904ae2dd0753338c306333eb5ea2e}"
RAW="https://raw.githubusercontent.com/UBC-MDS/DSCI_521_platforms-dsci_book/$SHA"
EXT=_extensions/ubc

fetch() { # fetch <path in 521> <path here>
  mkdir -p "$(dirname "$2")"
  curl -sSfL "$RAW/$1" -o "$2"
  echo "fetched $1 -> $2"
}

fetch _brand.yml          "$EXT/brand.yml"
fetch styles.scss         "$EXT/styles.scss"
fetch styles-dark.scss    "$EXT/styles-dark.scss"
fetch code-labels.lua     "$EXT/code-labels.lua"
fetch quizdown-theme.html "$EXT/quizdown-theme.html"
fetch MDSlogo.png         "$EXT/MDSlogo.png"
for f in _extension.yml customcallout.lua fa.lua assets/css/fontawesome.css assets/webfonts/fa-solid-900.woff2; do
  fetch "_extensions/coatless-quarto/custom-callout/$f" "$EXT/_extensions/coatless-quarto/custom-callout/$f"
done
for f in _extension.yml quizdown.lua assets/quizdown-init.js assets/quizdown.js assets/quizdownHighlight.js assets/quizdownKatex.js; do
  fetch "_extensions/quizdown/$f" "$EXT/_extensions/quizdown/$f"
done

# brand.yml: DSCI 521's name and links belong to that book, not to the brand
# (Q&A 16), so its top-level `meta:` block goes.
awk '/^meta:/ {skip = 1; next} skip && /^[^ #]/ {skip = 0} !skip' "$EXT/brand.yml" > "$EXT/brand.yml.tmp"
mv "$EXT/brand.yml.tmp" "$EXT/brand.yml"
echo "removed meta: from $EXT/brand.yml"
```

Run it: `scripts/fetch-521.sh`. Expected: one `fetched` line per file and `removed meta:`; `grep -c '^meta:' _extensions/ubc/brand.yml` prints `0`.

- [ ] **Step 4: Write `_extensions/ubc/_extension.yml`:**

```yaml
title: UBC brand
author: UBC Master of Data Science
version: 0.1.0
quarto-required: ">=1.11.0"
contributes:
  # The brand applies to any project with this extension installed, whatever
  # its format: colours, fonts and dark mode. A format alone cannot carry it:
  # its `brand` theme layer means the project's brand.
  metadata:
    project:
      brand: brand.yml
  formats:
    html:
      # Precedence is left to right, so styles.scss wins over the brand.
      theme:
        light: [brand, styles.scss]
        dark: [brand, styles.scss, styles-dark.scss]
      filters:
        - code-labels.lua
        - custom-callout
        - quizdown
      # Themes the quizdown quizzes, which render into a shadow root.
      include-after-body: quizdown-theme.html
      # Literal hex: this YAML cannot read Sass. Keep in step with brand.yml.
      custom-callout:
        activity:
          title: "Activity"
          icon: true
          icon-symbol: "fa-person-chalkboard"
          color: "#0055B7"
        exercise:
          title: "Exercise"
          icon: true
          icon-symbol: "fa-dumbbell"
          color: "#1C5F2E"
        definition:
          title: "Definition"
          icon: true
          icon-symbol: "fa-book-open"
          color: "#8A6D2B"
        relevance-project:
          title: "Relevance to course project"
          icon: true
          icon-symbol: "fa-diagram-project"
          color: "#0077C8"
```

- [ ] **Step 5: Use the format.** In `_quarto.yml`, replace `format: html` with `format: ubc-html`. In the `Makefile`, add `fetch-521` to `.PHONY` and this target after `clean`:

```make
fetch-521: ## Re-fetch the brand files from DSCI 521 (SHA=<commit> to change the pin)
	scripts/fetch-521.sh $(SHA)
```

- [ ] **Step 6: Run the checks; they pass.** `make check`. Expected: every `ok`, no `FAIL`, no Quarto `WARN`.

- [ ] **Step 7: Commit.** Write the message to a file:

```text
feat(ext): 🤖 add the ubc extension: DSCI 521's brand as a format

_extensions/ubc contributes the brand through project metadata and a
ubc-html format with 521's theme layers, code-labels.lua, the quiz
theme, and the embedded custom-callout and quizdown extensions, plus
the four callout types. scripts/fetch-521.sh copies every file from
DSCI 521 at 991bae89cba9 and drops the brand's 521-specific meta. The
test book now uses the format. The new checks first failed with: FAIL
dark stylesheet.

Plan: docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md Task 2
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

  `git add scripts/fetch-521.sh _extensions/ubc _quarto.yml tests/check-render.sh Makefile`, `git commit -F <file>`, `git log -1 --format='%(trailers)'`. Then `make leaks` and `git push origin main`.

- [ ] **Step 8: Review, look forward, close.** Tier 2: Matt Pocock's `code-review` from `.git/TASK_BASE`, two axes in two subagents; fix Critical and Important. Close with the boxes ticked, **Now** `Task 3: The conventions page, open.`, the spec's S01 and S02 rows `built`, and:

```text
docs(plan): 🤖 close Task 2: The ubc extension

Drift: <none, or what was built differently and why>
Rulings: <none, or each ruling>
Phase-end: <none, or each deferred finding>
Forward: <none, or each later listing rewritten>
Tier: 2
Rounds: <the review's rounds: Standards and Spec, findings and fixes>
Findings: <none, or each finding with its severity and decision>

Plan: docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md Task 2
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

***

### Task 3: The conventions page

**Tier:** 3 · **Scenarios:** S05, S06, S11

**Files:**
- Create (fetched): `chapters/book-conventions.qmd`, `chapters/img/cheers.png`
- Modify: `scripts/fetch-521.sh`, `chapters/book-conventions.qmd` (one link), `_quarto.yml`, `tests/check-render.sh`

**Interfaces:**
- Consumes: Task 2's `fetch`, `LIGHT`, the `ubc-html` format; Task 1's uv and renv environments.
- Produces: `_book/chapters/book-conventions.html` (the page sets `output-file: book-conventions.html`), which Task 6 links to.

- [ ] **Step 0: Record the base:** `git rev-parse HEAD > .git/TASK_BASE`.

- [ ] **Step 1: Write the failing test.** Insert before `exit $fail` in `tests/check-render.sh`:

```bash
# --- Task 3: the conventions page (S05, S06, S11)
CONV="$BOOK/chapters/book-conventions.html"
exists "conventions page"              "$CONV"
expect "Terminal label"                '<div class="code-with-filename-file"><pre><strong>Terminal</strong>' "$CONV"
expect "Output label"                  '<strong>Output</strong>'                                     "$CONV"
expect "filename label"                '<strong>penguins\.py</strong>'                               "$CONV"
expect "a quiz"                        '<div class="quizdown">'                                      "$CONV"
expect "executed R output"             '\[1\]  1  4  9 16 25'                                        "$CONV"
expect "R warning in its own block"    'cell-output-stderr'                                          "$CONV"
expect "a matplotlib figure"           'book-conventions_files/figure-html/[^"]+\.png'               "$CONV"
expect "a captioned figure"            'img/cheers\.png'                                             "$CONV"
expect "activity callouts"             'callout-activity'                                            "$CONV"
expect "exercise callouts"             'callout-exercise'                                            "$CONV"
expect "a tabset"                      'panel-tabset'                                                "$CONV"
exists "the figure is copied"          "$BOOK/chapters/img/cheers.png"
```

- [ ] **Step 2: Run it; watch it fail.** `make test`. Expected: `FAIL conventions page (_book/chapters/book-conventions.html missing)`.

- [ ] **Step 3: Fetch the page and its figure.** In `scripts/fetch-521.sh`, after the quizdown loop, add:

```bash
fetch lectures/0-conventions.qmd chapters/book-conventions.qmd
fetch img/cheers.png             chapters/img/cheers.png
```

  Run `scripts/fetch-521.sh`; `git status` shows only the two new files (the others are byte-identical).

- [ ] **Step 4: Change the one link into DSCI 521.** In `chapters/book-conventions.qmd`, replace

```markdown
a [link to another page](1-MDStools-bash-filesystem.qmd)
```

with

```markdown
a [link to another page](../index.qmd)
```

  so the example stays an internal link, to this book's Home page. Nothing else in the page changes (Q&A 15).

- [ ] **Step 5: Add the chapter.** In `_quarto.yml`, add `chapters/book-conventions.qmd` to `project: render:` after `index.qmd`, and in `book: chapters:` insert, after `index.qmd`:

```yaml
    - part: "The brand"
      chapters:
        - chapters/book-conventions.qmd
```

- [ ] **Step 6: Run the checks; they pass.** `make check`. Expected: every `ok`, no `FAIL`, no Quarto `WARN` (a reticulate or knitr warning counts).

- [ ] **Step 7: Commit.** Write the message to a file:

```text
feat(book): 🤖 add DSCI 521's conventions page to the test book

The page holding every construct a book uses (listings with their
labels, executed R and Python cells, callouts, quizzes, tables, math,
figures, tabsets), fetched from DSCI 521 at 991bae89cba9 with its
figure. Its one link into another 521 chapter now points at this
book's Home page. The new checks first failed with: FAIL conventions
page (_book/chapters/book-conventions.html missing).

Plan: docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md Task 3
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

  `git add scripts/fetch-521.sh chapters/book-conventions.qmd chapters/img/cheers.png _quarto.yml tests/check-render.sh`, `git commit -F <file>`, `git log -1 --format='%(trailers)'`. Then `make leaks` and `git push origin main`.

- [ ] **Step 8: Review, look forward, close.** Tier 3: self-review under *Standards* and *Spec*, plus `make check`. Close with the boxes ticked, **Now** `Task 4: The callouts gallery, open.`, the spec's S05, S06 and S11 rows `built`, and the close message as in Task 2 with `Task 3: The conventions page`, `Tier: 3` and `Rounds: self-review (Standards, Spec) and make check`.

***

### Task 4: The callouts gallery

**Tier:** 3 · **Scenarios:** S03, S04, S07

**Files:**
- Create: `chapters/callouts.qmd`
- Modify: `_quarto.yml`, `tests/check-render.sh`

**Interfaces:**
- Consumes: Task 2's callout types and `.term` rules.
- Produces: `_book/chapters/callouts.html`.

- [ ] **Step 0: Record the base:** `git rev-parse HEAD > .git/TASK_BASE`.

- [ ] **Step 1: Write the failing test.** Insert before `exit $fail` in `tests/check-render.sh`:

```bash
# --- Task 4: the callouts gallery (S03, S04, S07)
CALL="$BOOK/chapters/callouts.html"
exists "callouts page"                 "$CALL"
for t in note tip important warning caution; do
  expect "built-in callout: $t"        "class=\"callout callout-style-default callout-$t"            "$CALL"
done
expect "custom callout: activity"      'callout-activity'                                            "$CALL"
expect "custom callout: definition"    'callout-definition'                                          "$CALL"
expect "custom callout: relevance"     'Relevance to course project'                                 "$CALL"
expect "activity colour"               'div\.callout-activity\.callout \{ ?border-left-color: ?#0055B7'          "$CALL"
expect "exercise colour"               'div\.callout-exercise\.callout \{ ?border-left-color: ?#1C5F2E'          "$CALL"
expect "definition colour"             'div\.callout-definition\.callout \{ ?border-left-color: ?#8A6D2B'        "$CALL"
expect "relevance colour"              'div\.callout-relevance-project\.callout \{ ?border-left-color: ?#0077C8' "$CALL"
expect "Font Awesome stylesheet"       'fontawesome\.css'                                            "$CALL"
expect "a console window"              '<div class="term">'                                          "$CALL"
n=$(grep -o 'class="callout callout-style-default callout-exercise' "$CALL" 2>/dev/null | wc -l | tr -d ' ')
if [ "${n:-0}" -ge 2 ]; then echo "ok   two exercises for the numbering"; else echo "FAIL two exercises for the numbering ($n)"; fail=1; fi
```

- [ ] **Step 2: Run it; watch it fail.** `make test`. Expected: `FAIL callouts page (_book/chapters/callouts.html missing)`.

- [ ] **Step 3: Write `chapters/callouts.qmd`:**

````markdown
---
title: Callouts
---

Every callout a book can use, so a change to the brand can be checked against all
of them at once, in light and dark mode.

## Quarto's built-in callouts

::: {.callout-note}
A note, with no title.
:::

::: {.callout-note title="A titled note"}
A note with a title of its own.
:::

::: {.callout-tip}
A tip, with no title.
:::

::: {.callout-tip title="A titled tip"}
A tip with a title of its own.
:::

::: {.callout-important}
Something important, with no title.
:::

::: {.callout-important title="A titled important"}
Something important, with a title of its own.
:::

::: {.callout-warning}
A warning, with no title.
:::

::: {.callout-warning title="A titled warning"}
A warning with a title of its own.
:::

::: {.callout-caution}
A caution, with no title.
:::

::: {.callout-caution title="A titled caution"}
A caution with a title of its own.
:::

## The brand's callouts

Activities and exercises number themselves on each page, in order,
so a book writes them with no title and no number.
These two exercises read "Exercise 1" and "Exercise 2":

:::{.exercise}
The first exercise on this page.
:::

:::{.exercise}
The second exercise on this page.
:::

:::{.activity}
An activity: something the class does together.
:::

:::{.definition}
A definition of a term.
:::

:::{.relevance-project}
How this connects to the course project.
:::

A book can recolour these types or add its own:
see [Using it in a book](using.qmd).

## A console window

A captured terminal session, shown as a window so a reader recognizes it as a screen
rather than a listing to copy:

::: {.term}
```{=html}
<pre><span class="tp">$ git switch -c add-callouts</span>
Switched to a new branch 'add-callouts'
<span class="tp">$ git status --short</span>
<span class="tr"> M README.md</span>
<span class="tg">A  chapters/callouts.qmd</span></pre>
```
:::
````

  The link to `using.qmd` would make Quarto warn until Task 5 writes that page, so this step also creates `chapters/using.qmd` as a placeholder, which Task 5 replaces:

```markdown
---
title: Using it in a book
---
```

- [ ] **Step 4: Add the chapters.** In `_quarto.yml`, add `chapters/callouts.qmd` and `chapters/using.qmd` to `project: render:`, and under the part "The brand", after `chapters/book-conventions.qmd`:

```yaml
        - chapters/callouts.qmd
        - chapters/using.qmd
```

- [ ] **Step 5: Run the checks; they pass.** `make check`. Expected: every `ok`, no `FAIL`, no Quarto `WARN`.

- [ ] **Step 6: Commit.** Write the message to a file:

```text
feat(book): 🤖 add the callouts gallery and a console window

Quarto's five built-in callouts, plain and titled, the brand's four
types, two exercises in a row for the numbering, and a .term console
window. The new checks first failed with: FAIL callouts page
(_book/chapters/callouts.html missing).

Plan: docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md Task 4
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

  `git add chapters/callouts.qmd chapters/using.qmd _quarto.yml tests/check-render.sh`, `git commit -F <file>`, `git log -1 --format='%(trailers)'`. Then `make leaks` and `git push origin main`.

- [ ] **Step 7: Review, look forward, close.** Tier 3: self-review under *Standards* and *Spec*, plus `make check`; check both modes by eye in `uv run quarto preview`. Close with the boxes ticked, **Now** `Task 5: The website check and the how-to, open.`, the spec's S03, S04 and S07 rows `built`, and the close message as in Task 3 with `Task 4: The callouts gallery`.

***

### Task 5: The website check and the how-to

**Tier:** 2 · **Scenarios:** S08, S09, S10, S15

**Files:**
- Create: `tests/website/_quarto.yml`, `tests/website/index.qmd`, `tests/website/extra.scss`
- Modify: `chapters/using.qmd` (the placeholder becomes the how-to), `Makefile` (`test`), `tests/check-render.sh`

**Interfaces:**
- Consumes: Task 2's extension; Task 1's `make test`.
- Produces: `tests/website/_site/index.html`, rendered from a copy of the extension at `tests/website/_extensions/UBC-MDS/ubc/`, the folder a GitHub install creates.

- [ ] **Step 0: Record the base:** `git rev-parse HEAD > .git/TASK_BASE`.

- [ ] **Step 1: Write the failing test.** Insert before `exit $fail` in `tests/check-render.sh`:

```bash
# --- Task 5: a website project using a GitHub-style install (S08, S09, S10, S15)
SITE=tests/website/_site
SLIGHT=$(ls "$SITE"/site_libs/bootstrap/bootstrap-*.min.css 2>/dev/null | grep -v -- '-dark-' | head -1 || true)
SDARK=$(ls "$SITE"/site_libs/bootstrap/bootstrap-dark-*.min.css 2>/dev/null | head -1 || true)
exists "website page"                  "$SITE/index.html"
expect "website: UBC blue"             '--brand-ubc-blue: ?#002145'                                  "$SLIGHT"
expect "website: dark-mode toggle"     'quarto-color-scheme-toggle'                                  "$SITE/index.html"
expect "website: MDS logo opted in"    'MDSlogo\.png'                                                "$SITE/index.html"
expect "website: Terminal label"       '<strong>Terminal</strong>'                                   "$SITE/index.html"
expect "website: a quiz"               '<div class="quizdown">'                                      "$SITE/index.html"
expect "website: the brand's exercise" 'div\.callout-exercise\.callout \{ ?border-left-color: ?#1C5F2E' "$SITE/index.html"
expect "website: its own callout type" 'div\.callout-lab\.callout \{ ?border-left-color: ?#A6192E'   "$SITE/index.html"
expect "website: its own layer, light" '\.website-check-marker\{color:#8a6d2b\}'                     "$SLIGHT"
expect "website: its own layer, dark"  '\.website-check-marker\{color:#8a6d2b\}'                     "$SDARK"
```

- [ ] **Step 2: Run it; watch it fail.** `make test`. Expected: `FAIL website page (tests/website/_site/index.html missing)`.

- [ ] **Step 3: Write the website.** `tests/website/_quarto.yml`:

```yaml
# A one-page website (DSCI 521's project type) using the extension the way a
# GitHub install leaves it, with everything a book may add: the MDS logo, its
# own theme layer and its own callout type. `make test` copies the extension in.
project:
  type: website

website:
  title: "Website check"
  sidebar:
    logo: _extensions/UBC-MDS/ubc/MDSlogo.png
    logo-alt: "MDS logo"
    contents:
      - index.qmd

format:
  ubc-html:
    theme:
      light: [extra.scss]
      dark: [extra.scss]

custom-callout:
  lab:
    title: "Lab"
    icon: true
    icon-symbol: "fa-flask"
    color: "#A6192E"
```

  `tests/website/extra.scss`:

```scss
/*-- scss:rules --*/

// A book's own layer: it comes after the extension's, and `$brand-*` names work in it.
.website-check-marker {
  color: $brand-ubc-gold-dark;
}
```

  `tests/website/index.qmd`:

````markdown
---
title: Website check
---

:::{.exercise}
The brand's exercise callout.
:::

:::{.lab}
This website's own callout type.
:::

```bash
quarto render
```

```quizdown
## Which command renders a Quarto project?

- [x] `quarto render`
- [ ] `quarto build`
```
````

- [ ] **Step 4: Render it in `make test`.** In the `Makefile`'s `test` recipe, insert before `tests/check-render.sh`:

```make
	rm -rf tests/website/_extensions tests/website/_site
	mkdir -p tests/website/_extensions/UBC-MDS
	cp -R _extensions/ubc tests/website/_extensions/UBC-MDS/ubc
	cd tests/website && uv run quarto render 2>&1 | tee ../../.render-website.log
	@if grep -E 'WARN|ERROR' .render-website.log; then echo "Quarto warned or failed: see .render-website.log"; exit 1; fi
```

- [ ] **Step 5: Write the how-to,** replacing the placeholder `chapters/using.qmd`:

````markdown
---
title: Using it in a book
---

## Install it

In your Quarto book or website project, install a tagged release:

```bash
quarto add UBC-MDS/ubc-quarto-brand@v0.1.0
```

Quarto copies the extension into `_extensions/UBC-MDS/ubc/`.
Commit that folder: your book keeps exactly this version until you update it.

## Use the format

In your `_quarto.yml`:

```yaml
format: ubc-html
```

That one line brings the theme, the listing labels, the callouts and the quizzes.
The brand's colours, fonts and dark mode apply to every page as soon as the extension
is installed, whatever format a page uses.

## Update it

```bash
quarto update UBC-MDS/ubc-quarto-brand@v0.2.0
```

Do it in a pull request of its own, so the preview shows what changed before you merge.
The [changelog](../CHANGELOG.md) lists what each release changed.

## Turn on the MDS logo

The MDS logo ships with the extension but is not shown unless you ask for it.
In a book:

```yaml
book:
  sidebar:
    logo: _extensions/UBC-MDS/ubc/MDSlogo.png
    logo-alt: "MDS logo"
```

In a website, the same two keys go under `website: sidebar:`.

## Add your own styles

Add a theme layer of your own. Give it to both modes, as two lists:

```yaml
format:
  ubc-html:
    theme:
      light: [extra.scss]
      dark: [extra.scss]
```

Your layer comes after the extension's, so its rules win,
and the brand's colours are available in it as `$brand-<name>`, for example `$brand-ubc-blue`.
A single list, `theme: [extra.scss]`, makes Quarto stop with an error.

## Add or recolour a callout type

Add `custom-callout:` keys to your `_quarto.yml`. They merge with the extension's:
a new type is added, and a type the extension already has takes your values.

```yaml
custom-callout:
  lab:
    title: "Lab"
    icon: true
    icon-symbol: "fa-flask"
    color: "#A6192E"
```

The colour must be a literal hex, because this YAML cannot read the brand's Sass.
Take it from the palette:

| Name | Hex |
|---|---|
| `ubc-blue` | `#002145` |
| `ubc-blue-deep` | `#0055B7` |
| `ubc-blue-mid` | `#0077C8` |
| `ubc-blue-bright` | `#00A7E1` |
| `ubc-gold-dark` | `#8A6D2B` |
| `mds-green` | `#1C5F2E` |
| `alert-red` | `#A6192E` |

The [Callouts](callouts.qmd) page shows every type the extension defines.

## What you cannot change

You cannot replace part of the brand.
A `_brand.yml` of your own is ignored, because the extension's brand takes its place.
A top-level `brand:` key replaces the whole brand,
so it would have to define every colour the extension's styles use, or the render fails.
To change how things look, add a theme layer instead.

## Executed code and quizzes

Executed R and Python cells need nothing from the extension.
Quizzes are written in a `quizdown` code block;
the [conventions page](book-conventions.qmd) shows each kind.
````

- [ ] **Step 6: Run the checks; they pass.** `make check`. Expected: every `ok`, no `FAIL`, no Quarto `WARN` in either log.

- [ ] **Step 7: Commit.** Write the message to a file:

```text
test(website): 🤖 check a website install and write the how-to

tests/website is a one-page website using the extension from the
folder a GitHub install creates, with the MDS logo, its own theme
layer and its own callout type; make test renders it after the book.
chapters/using.qmd explains installing, updating, the logo, extra
styles and callouts, and what a book cannot change. The new checks
first failed with: FAIL website page (tests/website/_site/index.html
missing).

Plan: docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md Task 5
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

  `git add tests/website/_quarto.yml tests/website/index.qmd tests/website/extra.scss chapters/using.qmd Makefile tests/check-render.sh`, `git commit -F <file>`, `git log -1 --format='%(trailers)'`. Then `make leaks` and `git push origin main`.

- [ ] **Step 8: Review, look forward, close.** Tier 2: Matt Pocock's `code-review` from `.git/TASK_BASE`, two axes in two subagents. Close with the boxes ticked, **Now** `Task 6: Where it comes from, open.`, the spec's S08, S09, S10 and S15 rows `built`, and the close message as in Task 2 with `Task 5: The website check and the how-to`.

***

### Task 6: Where it comes from

**Tier:** 3 · **Scenarios:** S12

**Files:**
- Create: `chapters/provenance.qmd`
- Modify: `_quarto.yml`, `tests/check-render.sh`, `README.md`

**Interfaces:**
- Consumes: Task 2's `scripts/fetch-521.sh` and `make fetch-521`; Task 3's conventions page.
- Produces: `_book/chapters/provenance.html`.

- [ ] **Step 0: Record the base:** `git rev-parse HEAD > .git/TASK_BASE`.

- [ ] **Step 1: Write the failing test.** Insert before `exit $fail` in `tests/check-render.sh`:

```bash
# --- Task 6: where it comes from (S12)
PROV="$BOOK/chapters/provenance.html"
exists "provenance page"               "$PROV"
expect "pinned to 521's commit"        '991bae89cba904ae2dd0753338c306333eb5ea2e'                    "$PROV"
for f in _brand.yml styles.scss styles-dark.scss code-labels.lua quizdown-theme.html MDSlogo.png \
         _extensions/coatless-quarto/custom-callout _extensions/quizdown lectures/0-conventions.qmd img/cheers.png; do
  expect "links 521's $f"              "DSCI_521_platforms-dsci_book/(blob|tree)/991bae89cba904ae2dd0753338c306333eb5ea2e/$f" "$PROV"
done
```

- [ ] **Step 2: Run it; watch it fail.** `make test`. Expected: `FAIL provenance page (_book/chapters/provenance.html missing)`.

- [ ] **Step 3: Write `chapters/provenance.qmd`:**

````markdown
---
title: Where it comes from
---

Every file in this extension comes from the
[DSCI 521 book](https://ubc-mds.github.io/DSCI_521_platforms-dsci_book/),
copied from one commit, `991bae89cba904ae2dd0753338c306333eb5ea2e`,
by `scripts/fetch-521.sh`.
The links below point at each original as it was at that commit.

| In this extension | From DSCI 521 | Changed |
|---|---|---|
| `_extensions/ubc/brand.yml` | [`_brand.yml`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/blob/991bae89cba904ae2dd0753338c306333eb5ea2e/_brand.yml) | its `meta:` block, DSCI 521's name and links, is removed |
| `_extensions/ubc/styles.scss` | [`styles.scss`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/blob/991bae89cba904ae2dd0753338c306333eb5ea2e/styles.scss) | nothing |
| `_extensions/ubc/styles-dark.scss` | [`styles-dark.scss`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/blob/991bae89cba904ae2dd0753338c306333eb5ea2e/styles-dark.scss) | nothing |
| `_extensions/ubc/code-labels.lua` | [`code-labels.lua`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/blob/991bae89cba904ae2dd0753338c306333eb5ea2e/code-labels.lua) | nothing |
| `_extensions/ubc/quizdown-theme.html` | [`quizdown-theme.html`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/blob/991bae89cba904ae2dd0753338c306333eb5ea2e/quizdown-theme.html) | nothing |
| `_extensions/ubc/MDSlogo.png` | [`MDSlogo.png`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/blob/991bae89cba904ae2dd0753338c306333eb5ea2e/MDSlogo.png) | shown only when a book opts in |
| `_extensions/ubc/_extensions/coatless-quarto/custom-callout/` | [`_extensions/coatless-quarto/custom-callout/`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/tree/991bae89cba904ae2dd0753338c306333eb5ea2e/_extensions/coatless-quarto/custom-callout) | embedded in this extension |
| `_extensions/ubc/_extensions/quizdown/` | [`_extensions/quizdown/`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/tree/991bae89cba904ae2dd0753338c306333eb5ea2e/_extensions/quizdown) | embedded in this extension |
| `_extensions/ubc/_extension.yml` | the `filters:`, `custom-callout:` and `format:` keys of [`_quarto.yml`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/blob/991bae89cba904ae2dd0753338c306333eb5ea2e/_quarto.yml) | becomes the `ubc-html` format; adds the definition and relevance-project callouts |
| `chapters/book-conventions.qmd` (this book) | [`lectures/0-conventions.qmd`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/blob/991bae89cba904ae2dd0753338c306333eb5ea2e/lectures/0-conventions.qmd) | its link to another 521 chapter points at this book's Home page |
| `chapters/img/cheers.png` (this book) | [`img/cheers.png`](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/blob/991bae89cba904ae2dd0753338c306333eb5ea2e/img/cheers.png) | nothing |

## Taking a later version from DSCI 521

```bash
make fetch-521 SHA=<a DSCI 521 commit>
git diff
```

The script re-fetches every file above from that commit.
Review the diff, update the commit on this page and in `scripts/fetch-521.sh`,
and release the change like any other.

Once DSCI 521 uses this extension itself
([DSCI 521 issue #35](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/issues/35)),
changes flow the other way: they are made here, and DSCI 521 updates to the new release.
````

- [ ] **Step 4: Add the chapter and point the README at it.** In `_quarto.yml`, add `chapters/provenance.qmd` to `project: render:` and, under the part "The brand", after `chapters/using.qmd`, `- chapters/provenance.qmd`. In `README.md`, after its first paragraph, add:

```markdown
Every file comes from the DSCI 521 book at one pinned commit;
the demo book's "Where it comes from" page lists each original and what changed.
```

- [ ] **Step 5: Run the checks; they pass.** `make check`. Expected: every `ok`, no `FAIL`, no Quarto `WARN`.

- [ ] **Step 6: Commit.** Write the message to a file:

```text
docs(book): 🤖 add where each file comes from in DSCI 521

chapters/provenance.qmd links every file's DSCI 521 original at
991bae89cba9, says what changed, and explains re-fetching with make
fetch-521; the README points at it (Q&A 21). The new checks first
failed with: FAIL provenance page (_book/chapters/provenance.html
missing).

Plan: docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md Task 6
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

  `git add chapters/provenance.qmd _quarto.yml tests/check-render.sh README.md`, `git commit -F <file>`, `git log -1 --format='%(trailers)'`. Then `make leaks` and `git push origin main`.

- [ ] **Step 7: Review, look forward, close.** Tier 3: self-review under *Standards* and *Spec*, plus `make check`. Close with the boxes ticked, **Now** `Phase end, step 1: The final whole-branch review.`, the spec's S12 row `built`, and the close message as in Task 3 with `Task 6: Where it comes from`.

***

### Task 7: Phase end

A small project's end (plan-driven-development's `references/phase-end.md`). Each box ends with
its commit, `docs(plan): 🤖 phase end step K: <what it did>`, trailer
`Plan: docs/superpowers/plans/2026-10-30-ubc-quarto-brand.md Phase end`, which ticks the box and
sets **Now** to the next step.

- [ ] **1. The final whole-branch review:** Matt Pocock's `code-review`, two axes, from `git merge-base main HEAD`; one fix round and one scoped re-review; a ruling on whatever is left. Each fix is its own commit.
- [ ] **2. The rest of the ledger copied into the plan:** whatever `.superpowers/sdd/2026-10-30-ubc-quarto-brand/progress.md` holds that no closing commit carries, under its task.
- [ ] **3. The docs check:** every doc the branch touched is true (the README, the spec's design and scenario rows, the how-to, the provenance page, `AGENTS.md`).
- [ ] **4. A dated `CHANGELOG.md` entry** for `v0.1.0` (the extension, the test book, CI and previews, from DSCI 521 at `991bae89cba9`), and the spec's status line set to `PR open (#N)`, its number filled in once step 5 opens the PR.
- [ ] **5. The push and the publish run** (Q&A 29: no PR here): `main` pushed, `publish.yml` green, S14 checked on the live site.
- [ ] **6. The live site and the release:** <https://ubc-mds.github.io/ubc-quarto-brand/> serves the book with `.nojekyll` intact (S14); then [Dan] tags `v0.1.0`, and the reproducible book adopts it in its own previewed PR (S16).
