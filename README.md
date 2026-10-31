# ubc-quarto-brand

A [Quarto](https://quarto.org) extension that gives a UBC course book the brand
the [DSCI 521 book](https://ubc-mds.github.io/DSCI_521_platforms-dsci_book/) was built with:
the UBC colour palette, Atkinson Hyperlegible fonts, light and dark modes,
callouts with icons, labelled code listings, a console window, and themed quizzes.

**See it:** the demo book at <https://ubc-mds.github.io/ubc-quarto-brand/>
renders every part of the brand.

## Use it in a book

In your Quarto book or website project:

```bash
quarto add UBC-MDS/ubc-quarto-brand@v0.1.0
```

then, in its `_quarto.yml`:

```yaml
format: ubc-html
```

The demo book's "Using it in a book" page covers the MDS logo, adding your own styles,
and adding callout types.

## Work on it

The repository is itself the demo book, next to the extension in `_extensions/ubc/`.
`make help` lists the commands. How the project is run is in `AGENTS.md`,
and its design in `docs/superpowers/specs/2026-10-30-ubc-quarto-brand-design.md`.
