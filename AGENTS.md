## Purpose

This site is intended to serve as a reference for any potential contributors, human or agent, to the ongoing research detailed within.

## Supporting materials

`references/` may optionally contain markdown copies of the literature referenced by the user or cited in the wiki.

If the user cites a new reference in a query, or if you include a new reference in your edit, offer to add it to the references directory. Prefer Marker for document conversion.

## Code conventions

Do not hard-wrap lines in wiki source files (.qmd).

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
