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
expect "home titled in the sidebar" 'chapter-title">ubc-quarto-brand<' "$BOOK/index.html"
expect "overview diagram on Home" 'class="mermaid' "$BOOK/index.html"
exists "spec page"         "$BOOK/docs/superpowers/specs/2026-10-30-ubc-quarto-brand-design.html"
exists "kickoff Q&A page"  "$BOOK/docs/superpowers/specs/2026-10-30-ubc-quarto-brand-qa.html"
exists "plan page"         "$BOOK/docs/superpowers/plans/2026-10-30-ubc-quarto-brand.html"
exists "changelog page"    "$BOOK/CHANGELOG.html"
exists "how we work page"  "$BOOK/AGENTS.html"
exists "architecture page" "$BOOK/docs/architecture.html"
expect "architecture diagram" 'class="mermaid' "$BOOK/docs/architecture.html"

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
expect "diagram subgraph fill, light"  '--mermaid-fg-color--lightest: ?#F2F7FB'                     "$LIGHT"
expect "diagram subgraph fill, dark"   '--mermaid-fg-color--lightest: ?#0B2540'                     "$DARK"
expect "dark-mode toggle on Home"      'quarto-color-scheme-toggle'                                  "$BOOK/index.html"
expect "dark stylesheet linked"        'bootstrap-dark-[0-9a-f]+\.min\.css'                          "$BOOK/index.html"
expect "quizdown scripts on Home"      'quarto-contrib/quizdown-[0-9.]+/quizdown\.js'                "$BOOK/index.html"
expect "quiz theme include on Home"    'data-mds-quiz-theme'                                         "$BOOK/index.html"

exit $fail
