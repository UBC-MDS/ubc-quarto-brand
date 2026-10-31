# ubc-quarto-brand: design spec

**Status:** spec approved 2026-10-30 · small project, building on `main` (Q&A 29)

Kickoff's questions and Dan's answers are in
[`2026-10-30-ubc-quarto-brand-qa.md`](2026-10-30-ubc-quarto-brand-qa.md);
each decision below cites its item there as (Q&A N).

## Goal

A Quarto extension that gives any UBC course book the brand DSCI 521's book was built with,
so books stop copying styles from one another (Q&A 1, 18).
A book adopts it with `quarto add UBC-MDS/ubc-quarto-brand@vX.Y.Z` and one line,
`format: ubc-html`.
The repository also holds a test book that renders every part of the brand,
deployed as the live demo with the project docs (Q&A 3, 10).

The first book to adopt it is reproducible-and-trustworthy-workflows-for-data-science,
in its own PR after `v0.1.0` (Q&A 1, 24).
DSCI 521 follows later, tracked in
[UBC-MDS/DSCI_521_platforms-dsci_book#35](https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/issues/35).

## Outline

| Phase | Goal | Done means |
|---|---|---|
| (small project, one plan) | the extension, the test book, CI with PR previews, and the docs, ready for Dan to tag `v0.1.0` | every scenario below `built`; `make check` and CI green on `main`; the demo live; `v0.1.0` ready for Dan to tag |

## Design

### The extension

One extension, `ubc`, in `_extensions/ubc/` (Q&A 18). It contributes two things:

- **The brand,** through `metadata: project: brand: brand.yml`.
  Quarto merges it into any project with the extension installed, whatever its format,
  so colours, fonts and dark mode apply even to a plain `format: html` page.
- **A `ubc-html` format** with the theme layers
  (`light: [brand, styles.scss]`, `dark: [brand, styles.scss, styles-dark.scss]`),
  the filters (`code-labels.lua`, `custom-callout`, `quizdown`),
  `include-after-body: quizdown-theme.html`, and the four custom callout types.

A format cannot carry the brand on its own: its `brand` theme layer means the project's brand,
and 521's `styles.scss` needs the `$brand-*` variables that only the brand defines.
A prototype rendered exactly this setup on Quarto 1.11.6, for a book and for a website (Q&A 18).

| Extension file | From DSCI 521 at `991bae89cba9` | Changed |
|---|---|---|
| `brand.yml` | `_brand.yml` | its `meta` (DSCI 521's name and links) removed (Q&A 16) |
| `styles.scss`, `styles-dark.scss` | the same names | nothing |
| `code-labels.lua` | the same name | nothing (Q&A 9) |
| `quizdown-theme.html` | the same name | nothing (Q&A 12) |
| `MDSlogo.png` | the same name | applied only when a book opts in (Q&A 16) |
| `_extensions/coatless-quarto/custom-callout/` | its vendored 0.0.1-dev.3 | embedded |
| `_extensions/quizdown/` | its vendored copy | embedded (Q&A 12) |
| `_extension.yml`'s `custom-callout:` | `_quarto.yml`'s two types | plus definition and relevance-project (Q&A 8, 19) |

The callout types, with literal hex because the extension's YAML cannot read Sass (Q&A 8):

| Type | Icon | Colour |
|---|---|---|
| activity | `fa-person-chalkboard` | `#0055B7` (`ubc-blue-deep`) |
| exercise | `fa-dumbbell` | `#1C5F2E` (`mds-green`) |
| definition | `fa-book-open` | `#8A6D2B` (`ubc-gold-dark`) |
| relevance-project, titled "Relevance to course project" | `fa-diagram-project` | `#0077C8` (`ubc-blue-mid`) |

Activity and exercise callouts number themselves per page, from 521's `styles.scss` (Q&A 6).
Fonts load from Google Fonts, as in 521 (Q&A 14).

### What a book can change

From the prototype (Q&A 18):

- **Add styles** with an extra theme layer, light and dark as separate lists:
  `format: ubc-html: theme: light: [extra.scss] dark: [extra.scss]`.
  The layer comes after the extension's, and `$brand-*` names work in it.
  A plain list (`theme: [extra.scss]`) crashes Quarto.
- **Add or recolour callout types** with its own `custom-callout:` keys,
  which deep-merge over the extension's (Q&A 19).
- **Turn on the MDS logo** by pointing its sidebar or navbar logo at the bundled file (Q&A 16).
- **Not** replace the brand piecemeal: a book's own `_brand.yml` is silently ignored, and a
  top-level `brand:` replaces the whole brand, so it must define every colour the styles use.

### The test book

The repository root is a Quarto book that renders with `format: ubc-html`,
next to `_extensions/ubc/` (Q&A 22, 23):

- **Home:** the README.
- **Conventions:** DSCI 521's `lectures/0-conventions.qmd` almost as-is (Q&A 15):
  text, every listing kind, executed R and Python cells (Q&A 13), callouts, quizzes, tables,
  math, figures and tabsets. Only its links into other 521 chapters change.
- **Callouts:** Quarto's five built-ins (note, tip, important, warning, caution), plain and
  titled, the four custom types, and two exercises in a row for the numbering (Q&A 19).
- **Using it in a book:** installing, the format line, the logo, extra styles, extra callouts,
  and the limits above.
- **Where it comes from:** every file's DSCI 521 original, linked at `991bae89cba9`,
  and what changed (Q&A 21).
- **The project:** the spec, the plan, the Q&A pages, the changelog and `AGENTS.md`,
  rendered from where they live.

`tests/website/` is a one-page website project: a callout, a `bash` listing and a quiz.
`make` copies the extension into it, git-ignored, before rendering it in CI (Q&A 10, 22).

Executed cells run through knitr, with Python through reticulate from the uv venv, as in 521.
R needs `knitr`, `rmarkdown` and `reticulate` (renv); Python needs `matplotlib` (uv).

### CI and delivery

- **`pr.yml`,** on every pull request event: `make check`, then pr-preview-action deploys the
  rendered book to `gh-pages` under `pr-preview/pr-<N>/` and comments the link,
  or removes the preview when the PR closes. Runs are grouped per PR and a newer event
  cancels an older run, so a merge mid-build leaves no stray preview (Q&A 11, 24).
- **`publish.yml`,** on a push to `main`: the same build, then github-pages-deploy-action deploys
  the book to `gh-pages` with `clean-exclude: pr-preview` and `force: false`, so previews and the
  branch's `.nojekyll` survive (Q&A 24).
- **`make check`:** renders the test book and the website check, failing on any Quarto warning
  or unresolved link; runs `tests/check-render.sh` over the rendered HTML (the brand's colours,
  both stylesheets, the labels, the callouts' glyphs and colours, the counters, the quiz assets);
  runs lychee offline, actionlint and gitleaks.
- **Rulings:** Ubuntu runner, Quarto 1.11.6 pinned and `quarto-required: ">=1.11.0"`,
  Python 3.14, every third-party action pinned by commit SHA (Q&A 24).
- **Releases:** a PR bumps `version:` in `_extension.yml` and adds a `CHANGELOG.md` entry;
  Dan tags `vX.Y.Z` after merging it (Q&A 17).
- **Straight to `main`:** the agent commits and pushes to `main`; Dan reviews the extension in the adopting book's PR, with its preview (Q&A 29). `pr.yml` serves anyone who opens a PR here later.

## Scenarios

| ID | Situation | Expected | Phase and task | Proof | Status |
|---|---|---|---|---|---|
| S01 | a book installs the extension and sets `format: ubc-html` | UBC colours, Atkinson Hyperlegible fonts and a light/dark toggle | Task 2 | `tests/check-render.sh` on the book and the website check | planned |
| S02 | a reader switches to dark mode | navy page, readable code, lightened callout borders, readable tab titles | Task 2 | `tests/check-render.sh`; the PR preview, checked by eye | planned |
| S03 | an author writes `:::{.exercise}` twice on a page | "Exercise 1" and "Exercise 2", each with the dumbbell in MDS green | Tasks 2, 4 | `tests/check-render.sh`; the Callouts page in the preview | planned |
| S04 | an author writes any of Quarto's five built-in callouts | each renders in the brand's colours | Task 4 | the Callouts page in the preview | planned |
| S05 | an author writes a `bash`, an `out` and a `filename=` listing | labels "Terminal", "Output" and the filename | Tasks 2, 3 | `tests/check-render.sh` | planned |
| S06 | an author adds a quizdown quiz | the quiz renders in the brand's colours in both modes | Tasks 2, 3 | `tests/check-render.sh` (assets and theme); the preview, by eye | planned |
| S07 | an author writes a `.term` console window | a dark terminal window with coloured spans | Tasks 3, 4 | the Callouts or Conventions page in the preview | planned |
| S08 | an MDS book turns on the logo with one line | the MDS logo in its sidebar | Task 5 | the website check uses it; `tests/check-render.sh` | planned |
| S09 | a book adds its own SCSS layer | its rules apply after the extension's, in both modes | Task 5 | the website check uses one; `tests/check-render.sh` | planned |
| S10 | a book recolours a callout or adds a type | its keys merge over the extension's | Task 5 | the website check adds one; `tests/check-render.sh` | planned |
| S11 | an author executes R and Python cells | output renders under the brand | Task 3 | the Conventions page renders in `make check` | planned |
| S12 | someone asks where a file came from | the provenance page links its 521 original at `991bae89cba9` and says what changed | Task 6 | the Where it comes from page | planned |
| S13 | a PR is opened, updated, merged mid-build or closed | a preview link is commented; it updates; the merge leaves no stray preview; closing removes it | Task 1 | `pr.yml` is the book's proven workflow plus per-PR cancel; proven when a PR is first opened here (Q&A 29) | planned |
| S14 | a push lands on `main` | the demo deploys to `gh-pages`, keeping `pr-preview/` and `.nojekyll` | Task 1 | every publish run on `main` | planned |
| S15 | a website project (521's shape) uses the extension | it renders with the same brand and components | Task 5 | `tests/website/` in `make check` | planned |

### Later

| ID | Situation | Expected | Kind | Why it waits |
|---|---|---|---|---|
| S16 | the reproducible-and-trustworthy-workflows book adopts `v0.1.0` | its pages use the brand; its titles follow Q&A 6 and 7 | end | it needs Dan's `v0.1.0` tag, and happens in that repo's own PR |
| S17 | DSCI 521 adopts the extension | it deletes its local copies | end | tracked in DSCI_521#35 |
| S18 | Dependabot bumps the pinned action SHAs | a monthly PR | optional | plan-driven-development's `dependabot.yml` template isn't built yet |
| S19 | a single Quarto document, with no project, uses the extension | the brand, labels, callouts and quizzes as in a book | optional | a stretch goal after the build (Q&A 25); the prototype saw the brand reach a standalone `.qmd`, the format is untested |
| S20 | a revealjs deck in a branded project | slides in the brand's colours and fonts | optional | a stretch goal after the build (Q&A 25); likely needs a `ubc-revealjs` format, since `ubc-html`'s styles target Bootstrap pages |

## Open items and risks

- **Vendored dependencies:** custom-callout (0.0.1-dev.3) and quizdown are copies;
  updating them is a manual PR.
- **Quizdown loads on every page,** quiz or not, as in DSCI 521 (Q&A 12).
- **A partial brand override isn't possible** (see *What a book can change*);
  the how-to page says so.
- **Fork PRs get no preview:** their token can't write to the repository.
- **[Dan] settings:** Pages from the `gh-pages` branch (after the first publish creates it),
  read and write workflow permissions, a ruleset on `main`.
- **plan-driven-development's hooks and leak check aren't built yet:**
  every push of `build` follows `make leaks`.

## Revisions

- 2026-10-30: small, public, live test book with the docs, GitHub, fully vibed (`ac75784`).
- 2026-10-30: merging waits for Dan; PRs get previews (`1027692`, `fd5ebe4`).
- 2026-10-30: test site, quizzes, executed cells, fonts, logo, versioning, packaging, callouts
  (`47e684a`, `d126ab8`, `a5fc3e2`, `09f595d`, `c90002b`, `750f91d`, `fd5ebe4`, `50f7bf3`).
- 2026-10-30: approved for a one-shot build (Q&A 28); work goes straight to `main`, review happens in the adopting book (Q&A 29).
- 2026-10-30: the conventions page as-is, provenance docs, design sections 1 to 3
  (`00a0f5b`, `0489284`, `fd8ff72`, `70fa211`, `6447ee8`).
