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
