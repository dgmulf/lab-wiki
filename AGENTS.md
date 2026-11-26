## Purpose

This site is intended to serve as a reference for any potential contributors, human or agent, to the ongoing research detailed within.

## Supporting materials

`references` is a symlink to a directory which may optionally contain markdown copies of the literature referenced by the user or cited in the wiki.

If the user cites a new reference in a query, or if you include a new reference in your edit, offer to add it to the references directory. Prefer Marker for document conversion.

## Before editing

Before making any edits, check the factual claims and reasoning in the user's request against the relevant wiki material and its cited sources. If you find an apparent factual conflict or logical inconsistency, stop before editing. Explain the conflict to the user, point to the passage or source that raised it, and ask whether to proceed. Wait for explicit approval before making the edit.

## User instructions

Treat user corrections as instructions about what the article should say, not as points the article should make. Put explanations of what changed in the edit summary, not the article.

## Code conventions

Number every displayed equation in `.qmd` files by appending a unique, descriptive Quarto label to its closing `$$`, for example `$$ {#eq-coding-cost}`. Leave inline math unnumbered. When referring to an equation in the same document, use its cross-reference (e.g., `@eq-coding-cost`) rather than hard-coding the number.

## After editing copy

After making material changes to the rendered site, start a Quarto preview from
the repository root in a Delta background terminal:

```sh
uv run --locked quarto preview --render html --no-browser
```

Do not pass `--port`; let Quarto choose an available port so previews can run in
parallel. The preview exits after 15 minutes with no active clients.

Wait for Quarto to print the preview URL and verify that the affected pages load.
In your final reply, leave the preview running and include clickable links to the
relevant rendered pages, using the actual preview URL and section anchors where
helpful. Link directly to the changed pages rather than only the home page.
