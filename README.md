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

To render the GitHub Pages website locally:

```sh
uv run --locked quarto render --profile pages --to html
```

## GitHub Pages

The website is published at <https://dgmulf.github.io/lab-wiki/>.
The [Publish GitHub Pages workflow](.github/workflows/publish-pages.yml) restores
the locked Python and R dependencies and renders the website on every push to
`main`. A separate job deploys the resulting Pages artifact. To rebuild and
redeploy manually, run **Publish GitHub Pages** from the Actions tab on `main`.

The repository's **Settings → Pages → Build and deployment → Source** must be
**GitHub Actions**. The `pages` profile sets the GitHub Pages URL for the sitemap;
the default profile retains the existing website URL.
