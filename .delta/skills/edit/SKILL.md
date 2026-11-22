---
name: edit
description: Add or revise wiki pages around their stated key ideas and obtain a passing review. Use when changing page content.
---

# Edit wiki pages

1. For each affected page, check the bulleted key-ideas callout at the top against the user's intent. Add or amend it if needed before revising the body. If the intended claim is unclear, ask rather than guessing.
2. Revise the body to support those ideas. Keep the callout faithful to the user's intent; don't broaden it just to accommodate an unrelated passage.
3. Spawn a Reviewer subagent (`profile: reviewer`). In its prompt, invoke `/proofread` with the repository-relative paths of all affected pages as arguments, for example `/proofread index.qmd rate-distortion-prior.qmd`. Include the user's intended change so the reviewer can check the callouts against it.
4. Report each round's verdict and brief rationale. On `fail`, address the substantive findings and repeat step 3 with a fresh Reviewer so it reads the revised pages. Report final results only after the current pages receive `pass`.

## Report final results

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
