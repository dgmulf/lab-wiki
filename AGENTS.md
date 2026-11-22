## Purpose

This site is intended to serve as a reference for any potential contributors, human or agent, to the ongoing research detailed within.

## Editing workflow

### Clarify intent

Maintain a bullet list of key ideas in a callout box at the top of every page. Before making any changes, ensure that the key ideas accurately reflect the user intent.

### Proofread

After making an edit, read back the entire page and score it on a scale of 1 to 5 for how well it delivers a tightly focused narrative around the key ideas. If it scores below a 5, make an adjustment and return to the proofreading step.

### Demonstrate site changes

After making material changes to the rendered site, start a Quarto preview from
the repository root in a Delta background terminal:

```sh
uv run --locked quarto preview --render html --no-browser --timeout 900
```

Do not pass `--port`; let Quarto choose an available port so previews can run in
parallel. The preview exits after 15 minutes with no active clients.

Wait for Quarto to print the preview URL and verify that the affected pages load.
In your final reply, leave the preview running and include clickable links to the
relevant rendered pages, using the actual preview URL and section anchors where
helpful. Link directly to the changed pages rather than only the home page.
