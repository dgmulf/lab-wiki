This site is intended to serve as a reference for any potential contributors, human or agent, to the ongoing research detailed within. It shouldn't assume any prior knowledge beyond a general background in cognitive science and RL.

## Demonstrate site changes

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
