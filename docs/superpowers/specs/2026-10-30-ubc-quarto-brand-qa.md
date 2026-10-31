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
