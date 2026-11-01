# Changelog

## v0.1.0 (2026-10-31)

The first release: the DSCI 521 book's UBC brand as a Quarto extension, `ubc`.
It needs Quarto 1.10 or later.

- **The brand,** for any project with the extension installed: the UBC palette, Atkinson
  Hyperlegible fonts from Google Fonts, and light and dark modes, from DSCI 521's `_brand.yml`.
- **The `ubc-html` format:** DSCI 521's styles, its "Terminal" and "Output" listing labels,
  four callout types with Font Awesome icons (activity and exercise, numbered on each page;
  definition; relevance-project), quizdown quizzes themed for both modes, and a console window.
- **The extension's own layer** completes what DSCI 521 leaves out: coloured, spaced icons and
  dark variants for every custom callout, the five built-in callouts in brand colours in each
  mode, readable Mermaid subgraphs, and readable quiz answer chips in dark mode.
- **Copied from DSCI 521 at `991bae89cba9`** by `scripts/fetch-521.sh`; the demo book's
  "Where it comes from" page lists each original and what changed.
- **The demo book** renders DSCI 521's conventions page, every callout, a how-to for adopting
  the extension, and the project's docs; `tests/website/` checks a GitHub-style install.
- **CI:** `make check` on every push and pull request; pull requests get a preview, and `main`
  deploys the demo to <https://ubc-mds.github.io/ubc-quarto-brand/>.
- **Licence:** MIT for code, CC BY 4.0 for docs, the MDS logo excluded; quizdown's and
  Font Awesome's licences ship beside their files.

- 2026-10-30: kickoff. The design spec, the kickoff Q&A, and the project's rules
  (`AGENTS.md`). The extension packages the brand from the DSCI 521 book at `991bae89cba9`.
