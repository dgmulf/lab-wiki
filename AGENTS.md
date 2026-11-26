## Purpose

This site is intended to serve as a reference for any potential contributors,
human or agent, to the ongoing research detailed within.

## Supporting materials

`references` is a symlink to a directory which may optionally contain markdown
copies of the literature referenced by the user or cited in the wiki.

If the user cites a new reference in a query, or if you include a new reference
in your edit, offer to add it to the references directory. Prefer Marker for
document conversion.

## Before editing

Before making any edits, check the factual claims and reasoning in the user's
request against the relevant wiki material and its cited sources. If you find an
apparent factual conflict or logical inconsistency, stop before editing. Explain
the conflict to the user, point to the passage or source that raised it, and ask
whether to proceed. Wait for explicit approval before making the edit.

## User instructions

Treat user corrections as instructions about what the article should say, not as
points the article should make. Put explanations of what changed in the edit
summary, not the article.

## Code conventions

Number every displayed equation in `.qmd` files by appending a unique,
descriptive Quarto label to its closing `$$`, for example
`$$ {#eq-coding-cost}`. Leave inline math unnumbered. When referring to an
equation in the same document, use its cross-reference (e.g.,
`@eq-coding-cost`) rather than hard-coding the number.

## After editing copy

After making material changes to the rendered site, check whether a Quarto
preview is already running or starting in the current worktree. Check the
background terminals first. A preview started in another terminal may also
have a PID in `.quarto/preview/lock`; verify that the PID belongs to a live
Quarto preview for this worktree, since the lock can be stale.

Reuse the existing preview and verify that it serves the updated pages. Do not
start a second preview in the same worktree: Quarto shuts down the first one
even if the second uses a different port. If no preview is running or starting,
start one from the repository root in a background terminal:

```sh
uv run --locked quarto preview --render html --no-browser
```

Do not pass `--port`; let Quarto choose an available port so previews in
different worktrees can run in parallel.

Use the running server’s URL and verify that the affected pages load. In your
final reply, leave the preview running and include clickable links to the
relevant rendered pages, using section anchors where helpful. Link directly
to the changed pages rather than only the home page.
