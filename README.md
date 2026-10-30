# Research Wiki

Research notes built with [Quarto](https://quarto.org/).

## Render locally

Install Python 3.14, R 4.6, [uv](https://docs.astral.sh/uv/), and
[rv](https://a2-ai.github.io/rv-docs/), then restore dependencies:

```sh
uv sync --locked
rv sync --locked
```

Quarto and Jupyter are included in the locked Python environment. Use rv's R
library when rendering:

```sh
export R_LIBS_USER="$PWD/$(rv library)"
uv run --locked quarto render
```

To generate GitHub Flavored Markdown and figures in `_release/gfm/`:

```sh
uv run --locked quarto render --profile gfm --to gfm
```

The GFM profile uses a document project instead of the website layout and rewrites
links between `.qmd` pages to `.md`, preserving anchors.

## Continuous release

[Release GFM](.github/workflows/release-gfm.yml) renders on every push to `main`
and can also be run manually from the repository's Actions tab on `main`.
It restores both lockfiles, executes the Python and R plots, and updates the
[`continuous` prerelease](https://github.com/dgmulf/lab-wiki/releases/tag/continuous).
The workflow uses GitHub's built-in token with `contents: write`; no additional
secret is required. The rolling release requires mutable releases in the repository.

Download **lab-wiki-gfm.tar.gz** from that release and extract it. Start at
`index.md`; keep the figure directories beside the Markdown files. `COMMIT.txt`
identifies the source commit. The release's automatically generated source
archives contain the original project; the attached tarball contains the rendered
wiki.
