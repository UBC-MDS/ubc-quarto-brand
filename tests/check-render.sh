#!/usr/bin/env bash
# Checks the rendered test book, and from Task 5 the website check, for every
# part of the brand. Run by `make test` after the renders.
set -euo pipefail
fail=0

expect() { # expect <description> <pattern> <file>: case-insensitive extended regex
  if grep -q -i -E -- "$2" "$3" 2>/dev/null; then echo "ok   $1"; else echo "FAIL $1 ($3)"; fail=1; fi
}
expect_flat() { # expect, across line breaks: the file's newlines read as spaces
  if tr '\n' ' ' < "$3" 2>/dev/null | grep -q -i -E -- "$2"; then echo "ok   $1"; else echo "FAIL $1 ($3)"; fail=1; fi
}
expect_last() { # expect_last <description> <pattern> <value> <file>: the last match ends in <value>, so it wins the cascade
  last=$(grep -o -i -E -- "$2" "$4" 2>/dev/null | tail -1 || true)
  case "$(printf '%s' "$last" | tr 'A-F' 'a-f')" in
    *"$3") echo "ok   $1" ;;
    *) echo "FAIL $1 ($4: ${last:-no match})"; fail=1 ;;
  esac
}
exists() { # exists <description> <path>
  if [ -e "$2" ]; then echo "ok   $1"; else echo "FAIL $1 ($2 missing)"; fail=1; fi
}

BOOK=_book

# --- Task 1: the book and the project docs render (S13, S14)
exists "home page"         "$BOOK/index.html"
expect "home titled in the sidebar" 'chapter-title">ubc-quarto-brand<' "$BOOK/index.html"
expect "overview diagram on Home" 'class="mermaid' "$BOOK/index.html"
expect "README sections stay h2 on Home" '<h2[^>]*>Use it in a book' "$BOOK/index.html"
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
expect "quiz chips, light"             '--mds-quiz-chip-bg:'                                         "$LIGHT"
expect "quiz chips, dark"              '--mds-quiz-chip-bg:'                                         "$DARK"
expect "quiz chip rule on every page"  'data-ubc-quiz-chips'                                         "$BOOK/index.html"

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

# --- Task 4: the callouts gallery (S03, S04, S07)
CALL="$BOOK/chapters/callouts.html"
exists "callouts page"                 "$CALL"
for t in note tip important warning caution; do
  expect "built-in callout: $t"        "class=\"callout callout-style-default callout-$t"            "$CALL"
done
expect "custom callout: activity"      'callout-activity'                                            "$CALL"
expect "custom callout: definition"    'callout-definition'                                          "$CALL"
expect "custom callout: relevance"     'Relevance to course project'                                 "$CALL"
expect_flat "activity colour"               'div\.callout-activity\.callout \{ *border-left-color: ?#0055B7'          "$CALL"
expect_flat "exercise colour"               'div\.callout-exercise\.callout \{ *border-left-color: ?#1C5F2E'          "$CALL"
expect_flat "definition colour"             'div\.callout-definition\.callout \{ *border-left-color: ?#8A6D2B'        "$CALL"
expect_flat "relevance colour"              'div\.callout-relevance-project\.callout \{ *border-left-color: ?#0077C8' "$CALL"
expect "Font Awesome stylesheet"       'fontawesome\.css'                                            "$CALL"
expect "a console window"              '<div class="term">'                                          "$CALL"
n=$(grep -o 'class="callout callout-style-default callout-exercise' "$CALL" 2>/dev/null | wc -l | tr -d ' ' || true)
if [ "${n:-0}" -ge 2 ]; then echo "ok   two exercises for the numbering"; else echo "FAIL two exercises for the numbering ($n)"; fail=1; fi
# Q&A 26: the extension's layer colours every icon, and the built-ins, in each mode
expect "definition icon"               'div\.callout-definition \.callout-icon::before\{color:#8A6D2B'                          "$LIGHT"
expect "relevance icon"                'div\.callout-relevance-project \.callout-icon::before\{color:#0077C8'                   "$LIGHT"
expect "definition border, dark"       'body\.quarto-dark div\.callout-definition\.callout\{border-left-color:#A89565'        "$LIGHT"
expect "relevance border, dark"        'body\.quarto-dark div\.callout-relevance-project\.callout\{border-left-color:#00A7E1' "$LIGHT"
expect "warning in dark gold"          'div\.callout-warning\.callout\{border-left-color:#8A6D2B'                              "$LIGHT"
expect "caution in derived orange"     'div\.callout-caution\.callout\{border-left-color:#B85B0A'                              "$LIGHT"
expect "note, dark"                    'div\.callout-note\.callout\{border-left-color:#40B4E5'                                 "$DARK"
expect "tip, dark"                     'div\.callout-tip\.callout\{border-left-color:#88D4AB'                                  "$DARK"
expect "important, dark"               'div\.callout-important\.callout\{border-left-color:#F08080'                            "$DARK"
expect "warning, dark"                 'div\.callout-warning\.callout\{border-left-color:#A89565'                              "$DARK"
expect "caution, dark"                 'div\.callout-caution\.callout\{border-left-color:#F48525'                              "$DARK"

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
expect_flat "website: the brand's exercise" 'div\.callout-exercise\.callout \{ *border-left-color: ?#1C5F2E' "$SITE/index.html"
expect_flat "website: its own callout type" 'div\.callout-lab\.callout \{ *border-left-color: ?#A6192E'   "$SITE/index.html"
expect "website: its own layer, light" '\.website-check-marker\{color:#8a6d2b\}'                     "$SLIGHT"
expect "website: its own layer, dark"  '\.website-check-marker\{color:#8a6d2b\}'                     "$SDARK"
# S10: a recolour, and the rules custom-callout leaves to a book's layer (icons, dark mode)
expect_flat "website: a recoloured callout" 'div\.callout-activity\.callout \{ *border-left-color: ?#0077C8' "$SITE/index.html"
expect_last "website: recoloured icon"      '\}div\.callout-activity \.callout-icon::before\{color:#[0-9a-f]{6}'                   '#0077c8' "$SLIGHT"
expect_last "website: recoloured, dark"     'body\.quarto-dark div\.callout-activity\.callout\{border-left-color:#[0-9a-f]{6}'    '#00a7e1' "$SDARK"
expect_last "website: own type's icon"      '\}div\.callout-lab \.callout-icon::before\{[^}]*color:#[0-9a-f]{6}'                   '#a6192e' "$SLIGHT"
expect_last "website: own type, dark"       'body\.quarto-dark div\.callout-lab\.callout\{border-left-color:#[0-9a-f]{6}'         '#f08080' "$SDARK"

# --- Task 6: where it comes from (S12)
PROV="$BOOK/chapters/provenance.html"
exists "provenance page"               "$PROV"
expect "pinned to 521's commit"        '991bae89cba904ae2dd0753338c306333eb5ea2e'                    "$PROV"
for f in _brand.yml styles.scss styles-dark.scss code-labels.lua quizdown-theme.html MDSlogo.png \
         _extensions/coatless-quarto/custom-callout _extensions/quizdown lectures/0-conventions.qmd lectures/img/cheers.png; do
  expect "links 521's $f"              "DSCI_521_platforms-dsci_book/(blob|tree)/991bae89cba904ae2dd0753338c306333eb5ea2e/$f" "$PROV"
done
expect "names the extension's own layer" 'ubc-dark\.scss'                                             "$PROV"
expect "says where 521's settings went"  'keep DSCI 521.{1,3}s comments'                                   "$PROV"
expect "links quizdown's licence"       'parmsam/quarto-quizdown/blob/98fd96d0c396cb631708ec76ffcb6446534a7aa5/LICENSE' "$PROV"
exists "the licence"                    LICENSE.md
exists "quizdown's licence beside it"   _extensions/ubc/_extensions/quizdown/LICENSE

exit $fail
