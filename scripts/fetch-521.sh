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
