## Purpose

This site is intended to serve as a reference for any potential contributors, human or agent, to the ongoing research detailed within.

## Audience

Assume the audience has a general background in cognitive science and reinforcement learning, but has zero visibility into any context surrounding the project outside of the content of the current wiki itself. Specifically, the audience should not be assumed to know about the contents of any user-agent conversations or previous iterations of the wiki.

## Supporting materials

`references/` may optionally contain markdown copies of the literature referenced by the user or cited in the wiki.

If the user cites a new reference in a query, or if you include a new reference in your edit, offer to add it to the references directory. Prefer Marker for document conversion.

## Before editing

Before making any edits, check the factual claims and reasoning in the user's request against the relevant wiki material and its cited sources. If you find an apparent factual conflict or logical inconsistency, stop before editing. Explain the conflict to the user, point to the passage or source that raised it, and ask whether to proceed. Wait for explicit approval before making the edit.

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
