# ubc-quarto-brand: kickoff Q&A

Every question asked at kickoff, with Dan's answer and his reason in his words.

## Setup

1. **Small or large?** Small: one spec, one plan, no phases.
   Dan: "small, we can just use it in this book now. will update 521 later
   (already created issue to track https://github.com/UBC-MDS/DSCI_521_platforms-dsci_book/issues/35)".
2. **Public or private?** Public. Settled by the repository Dan created
   (`UBC-MDS/ubc-quarto-brand`, public).
3. **A live demo site?** Yes: the test book deploys to GitHub Pages from `main`,
   and the project docs (README, spec, plan, changelog) join it as pages,
   so they render under the brand too ("a demo that is itself a Quarto site").
   Dan chose option A, "Live test book + docs".
4. **Where does the repo live?** GitHub, `UBC-MDS/ubc-quarto-brand`,
   cloned to `~/git/mds/ubc-quarto-brand`. Settled by the repository Dan created.
5. **Mode?** Fully vibed: the agent rules on questions that would change the spec or a decision,
   logs each as "decided without Dan", and merges once CI is green.
   The stops that never relax still wait for Dan. Dan chose option B, "Fully vibed".

## Design decisions made before kickoff

These were settled while planning the same branding for the
reproducible-and-trustworthy-workflows book,
before Dan asked for it to become this extension:
"instead of moving all those brand elements into this repo as copy+paste,
can we clone https://github.com/UBC-MDS/ubc-quarto-brand into ~/git/mds/ and then
move all those brand elements into a quarto extension that gets used by this book?
i also like how we crfeated a convensions document in 521.
we can create and use that as a test book/site in the extension too to quickly fix things".

6. **Callout numbering.** Activity and exercise callouts are numbered automatically, per page,
   as in DSCI 521. In the consuming book, hand-written numbers come out of the titles.
   Dan chose "Auto-number, strip titles".
7. **Descriptive callout titles.** A descriptive title (for example "Get to know Quarto")
   becomes a bold first line in the callout's body, so every title reads "Exercise N".
   Dan chose "Bold first line (Recommended)".
8. **Callout icons and colours.** Font Awesome icons and UBC palette colours for all four
   callout types: activity `fa-person-chalkboard` in `ubc-blue-deep`,
   exercise `fa-dumbbell` in `mds-green`, definition `fa-book-open` in `ubc-gold-dark`,
   relevance-project `fa-diagram-project` in `ubc-blue-mid`.
   Dan chose "FA icons + brand colours (Recommended)".
9. **Listing labels.** DSCI 521's `code-labels.lua` comes along:
   every `bash` listing is labelled "Terminal" and every `out` listing "Output".
   Dan chose "Port it (Recommended)".

## Grilling

10. **Test site shape.** The deployed demo is a Quarto book:
    DSCI 521's conventions page, a gallery of every callout and listing,
    and the project docs as chapters.
    A one-page website project also renders in CI only,
    to catch website-specific breakage before DSCI 521 adopts the extension.
    Dan chose "A. Book demo + website check (Recommended)".

11. **Commits, PRs, merging, previews.** Dan, during grilling:
    "you may create commits and PRs, but don't merge,
    the GHA for pr-preview should be able to render the site for me to also review".
    So the agent commits, pushes the work branch and opens PRs, but never merges:
    every merge waits for Dan, overriding fully vibed's merge.
    Every PR gets a rendered preview of the test book through
    [pr-preview-action](https://github.com/rossjrw/pr-preview-action), as in the
    reproducible-and-trustworthy-workflows book, so the demo deploys from a `gh-pages` branch
    (pr-preview-action needs "Deploy from branch"),
    not from `actions/deploy-pages` as plan-driven-development's docs-site default gives.
    Asked whether this was meant only for the book's PR #37, Dan confirmed it applies here:
    "the dont' merge and we'll wait for PR previews for final check
    is for this current set of quarot ubc branding".

12. **DSCI 521's extra pieces.** The extension carries both:
    the quizdown quizzes (the quizdown extension embedded, its shadow-root theme include,
    and the quiz colour variables) and the `.term` console window,
    so DSCI 521 adopts the extension by deleting its local copies.
    Every consumer carries quizdown's JavaScript, used or not.
    Dan chose "A. Both in the extension" over the recommended
    "B. Console in, quizzes stay".

13. **Executed cells in the test book.** The test book keeps the executed `{r}` and `{python}`
    cells, so executed output is tested under the brand in every PR preview.
    CI installs a minimal environment: R with knitr, rmarkdown and reticulate through renv,
    and Python through uv.
    Dan chose "A. Run R + Python (Recommended)".

14. **Fonts.** Atkinson Hyperlegible Next and Mono load from Google Fonts (`source: google`),
    as in DSCI 521, so every reader's browser requests them from Google.
    Dan chose "B. Google Fonts" over the recommended "A. Bundled files",
    which would have shipped the OFL-licensed woff2 files in the extension
    so that no third party is contacted.
    Dan: "good fonts are not privacy concern".

15. **The conventions page.** The test book's conventions page mimics DSCI 521's
    `lectures/0-conventions.qmd` almost as-is, Quizzes section and executed cells included.
    Dan: "we should try to mimic that convensions file almost as-is
    it shows almost eveything that we use in a book."

16. **Identity and logo.** The extension ships no book name or links:
    each book keeps its title and links in its own `_quarto.yml`.
    It bundles DSCI 521's `MDSlogo.png` as an available asset, not applied by default;
    an MDS book turns it on with one line in its `_quarto.yml`.
    The UBC logo is not bundled.
    Dan chose "C. MDS logo, opt-in" over the recommended "A. Brand only, books add theirs".

17. **Versioning.** `_extension.yml` carries a semantic version, and Dan tags releases
    (`v0.1.0`, and on). A book installs a tag,
    `quarto add UBC-MDS/ubc-quarto-brand@v0.1.0`, and updates in its own PR with `quarto update`,
    where the PR preview shows the change. `CHANGELOG.md` lists each release.
    Tags are a stop that never relaxes, so each release is a step for Dan.
    Dan chose "A. Tagged releases (Recommended)".

18. **Packaging.** One extension, `ubc`, contributing the brand through
    `metadata: project: brand: brand.yml` and a `ubc-html` format
    (the light and dark theme layers, `code-labels.lua`, and the embedded custom-callout
    and quizdown extensions). A book runs `quarto add UBC-MDS/ubc-quarto-brand@v0.1.0`
    and sets `format: ubc-html`; it adds its own styles as an extra theme layer
    (`format: ubc-html: theme: light: [extra.scss] dark: [extra.scss]`).
    A prototype rendered this exact setup on Quarto 1.11.6 for a book and a website.
    Dan chose "A. One `ubc` extension (Recommended)".

19. **Callouts.** Dan: "we should have all callout examples, built-ins and new ones".
    Read as: the extension defines all four custom callout types
    (activity, exercise, definition, relevance-project), and the test book's gallery shows
    every callout, Quarto's five built-ins (note, tip, important, warning, caution)
    and the four custom ones, so each is checked under the brand.
    A book can still recolour a type or add its own in its `_quarto.yml`:
    the prototype showed a book's `custom-callout:` settings deep-merge over the extension's.

20. **Shared understanding.** Dan confirmed the grilling summary and moved kickoff on
    to the design: "Yes, go to the design (Recommended)".
21. **Provenance in the docs.** Dan: "when we document this new quarto extension
    we should document how it comes from 521". The docs explain, file by file,
    which DSCI 521 file each piece of the extension comes from and what changed on the way,
    linking to 521's originals.

## Design sections

22. **Section 1, layout and contents.** The test book lives at the repository root next to
    `_extensions/ubc/` (Quarto finds extensions only in a project's own `_extensions/`).
    The extension holds DSCI 521's files as of commit `991bae89cba9`, unchanged apart from
    `brand.yml` losing 521's name and links and the format gaining the definition and
    relevance-project callouts. The website check renders a git-ignored copy of the extension.
    Dan chose "A. Approve section 1 (Recommended)".
23. **Section 2, the test book.** Pages: Home (the README), Conventions (DSCI 521's page almost
    as-is), Callouts (the five built-ins, titled and plain, the four custom types, and two
    exercises in a row for numbering), Using it in a book (the how-to), Where it comes from
    (provenance, pinned to 521 at `991bae89cba9`), and the project docs as chapters rendered
    from where they live. `tests/website/` is one page rendered as a website in CI.
    Dan chose "A. Approve section 2 (Recommended)".
24. **Section 3, CI, delivery and adoption.** `pr.yml` runs `make check` and deploys a preview
    with pr-preview-action, cancelling a PR's in-flight run when a newer event arrives;
    `publish.yml` deploys `main` to `gh-pages` with github-pages-deploy-action
    (`clean-exclude: pr-preview`, `force: false`). `make check` renders the test book and the
    website check, runs lychee offline, actionlint and gitleaks. Rulings: Ubuntu runner,
    Quarto 1.11.6 pinned with `quarto-required: ">=1.11.0"`, Python 3.14, third-party actions
    pinned by SHA. Releases: a PR bumps the version and CHANGELOG, Dan tags after merging.
    The reproducible-and-trustworthy-workflows book adopts `v0.1.0` in its own PR afterwards.
    Dan chose "A. Approve section 3 (Recommended)".

## After the plan

25. **Other Quarto outputs, a stretch goal.** Dan: "if possible we should see if this will work
    for the quarto book/revealjs/site/document outputs. but that would be a stretch goal
    after this is all built". Books and websites are already in the plan (S01, S15);
    a single document and revealjs slides go to the spec's Later table as optional (S19, S20).

## Review before approval

The builder check (a fresh reviewer reading the spec as its builder) raised three questions;
each claim was checked against the code before Dan saw it.

26. **Callout styling.** custom-callout colours a callout's border and fill but never its icon,
    and DSCI 521's `styles.scss` colours only the activity and exercise icons. Quarto maps the
    built-ins to `$blue`, `$green`, `$red`, `$yellow` and `$orange`, and the brand defines no
    `orange` and nothing per mode. The extension completes the styling in its own layer after
    DSCI 521's files, which stay byte-identical: coloured, spaced icons with dark-mode variants
    for all four custom types, and the five built-ins in brand colours per mode, caution in a
    derived orange that clears AA (UBC publishes no orange). DSCI 521's built-in callouts change
    colour when it adopts the extension. Dan chose "A. Complete it, separate layer (Recommended)".
27. **Licence.** A split licence, as in the reproducible-and-trustworthy-workflows book:
    MIT for the code (Lua, SCSS, scripts, workflows) and CC BY-NC-SA 4.0 for the docs and the
    test book's text. Vendored code keeps its own terms: quizdown's MIT licence text goes beside
    its copy, and Font Awesome's terms stay in its CSS. The MDS logo is excluded as UBC's mark.
    custom-callout has no licence upstream (coatless-quarto/custom-callout), a redistribution gap
    DSCI 521 already has: [Dan] asks its author, James Balamuta, to add one.
    Dan chose "A. Split, like the book (Recommended)".
28. **Pages, approval and execution.** Asked when to switch Pages on, Dan answered:
    "no you do everything essentially make this a working and complete one-shot.
    create the github action for publication too.
    if you need me to check off boxes i will do that now".
    Read as: the spec and plan are approved, and the agent builds the whole project in one go,
    publish workflow included, choosing the execution method itself (inline,
    superpowers:executing-plans: the tasks are sequential and need this machine's R, Python
    and Quarto). The agent creates an empty `gh-pages` branch now so that Dan can switch Pages
    on before the PR opens, and the PR's own preview proves S13. Merging still waits for Dan
    (item 11).

29. **Work on `main`; review happens in the book.** Dan: "for the UBC-MDS/ubc-quarto-brand repo,
    you can just do everythign on main. there is no PR review there. the pr review is just testing
    and using the extension in this current repo for the book".
    So the agent commits and pushes to `main` here, with no PRs, and `publish.yml` deploys the demo
    on every push. Item 11's "no merging, PR previews" now applies to the
    reproducible-and-trustworthy-workflows book's adoption PR, where Dan reviews the extension in
    use. `pr.yml` stays, for anyone who opens a PR here later. The `build` branch stays as it is
    (deleting branches is a stop).

## Before the tag

30. **The docs licence.** Item 27 chose a split licence "like the book", with CC BY-NC-SA 4.0
    for the docs. At the phase end the agent found the reproducible book split with itself: its
    README says CC BY-NC-SA 4.0 and its `LICENSE.md` CC BY 4.0. Asked which covers this
    project's docs and the test book's text, Dan chose "B. CC BY 4.0", matching the book's
    `LICENSE.md`: anyone may reuse them, commercially too, with attribution. Code stays MIT.

31. **The MIT copyright holder.** `LICENSE.md` names "UBC Master of Data Science", the author
    in `_extension.yml`; DSCI 521, where most of the code was written, publishes no licence or
    holder. Asked before the tag, Dan chose "A. UBC Master of Data Science (Recommended)":
    the licence and the extension's author field agree, and nothing changes.

32. **The Quarto floor.** Item 24 pinned Quarto 1.11.6 with `quarto-required: ">=1.11.0"`,
    the version the prototype happened to run on. Adopting the extension in the reproducible
    book (its PR #38) showed that 1.11 is still a pre-release: that book's CI installs the
    stable 1.10.20, and the extension refused to render. With the floor lowered, `make test`
    on 1.10.20 passed all 113 checks without a warning. Asked before the tag, Dan chose
    "A. Lower to >=1.10.0 (Recommended)": `quarto-required: ">=1.10.0"`, and CI pins 1.10.20
    so it tests the floor.
33. **The outside extensions, installed by the user.** Asked why he should ask custom-callout's
    author for a licence, Dan asked why the extension could not install custom-callout as a
    dependency. Quarto has no dependencies: `_extension.yml` takes only `title`, `author`,
    `version`, `quarto-required` and `contributes`, and a filter named in an extension's format
    resolves only inside that extension's own folder (`Failed to resolve referenced filter
    custom-callout - path does not exist`, even with custom-callout installed in the project).
    Dan: "let's set up in the instructions on if we want to install the ubc-quarto-brand
    extension that we tell the user that thye need to install the other extensions first. i
    just want the ubc-quarto-brand provide mostly the css/scss that fixes and modfiies the
    existing extension pieces. let's not ship the other extensions if we can help it. unless
    this is the only way". It is not the only way, so the extension embeds neither
    custom-callout nor quizdown (from `UBC-MDS/quarto-quizdown-mds-ext`, the copy DSCI 521
    uses); it keeps their configuration and styling (the callout types, `quizdown-theme.html`,
    `ubc-quizdown.html`, the quiz colours). This replaces item 12's embedded quizdown, and moves
    item 27's licence gap out of this repository. How a project switches them on, asked as a
    scenario: Dan chose "A. filters: line (Recommended)": the project installs them first and
    lists them under `filters:` in its `_quarto.yml`, so each project takes only what it uses.
    Decided without Dan: the test book installs both at build time (`make deps`) into folders git
    ignores, because `quarto add` installs every extension a repository commits under
    `_extensions/` (a copy of this one with both beside it: "Found 3 extensions"); and the change
    goes into v0.1.0, which is not tagged yet.
34. **The outside extensions' versions.** `quarto add` takes a repository's `main`, a tag or a
    branch, never a commit, and neither extension has a tag at the version tested: custom-callout's
    only tag, `0.0.1`, holds 0.0.0-dev.1 (`main` is 0.0.1-dev.3), and quizdown-mds's `v1.2.0`
    is older than `main`'s 1.3.2. Asked as a scenario, Dan chose "A. Main now, tags later
    (Recommended)": the instructions install from `main` and name the versions tested; once tags
    exist ([Dan] tags `UBC-MDS/quarto-quizdown-mds-ext` `v1.3.2`, and the note to custom-callout's
    author asks for a tag beside the licence), they install by tag.
