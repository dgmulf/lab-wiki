# Research Wiki

Research notes authored in [Typst](https://typst.app/), published as a multi-page
HTML website at <https://dgmulf.github.io/lab-wiki/>.

## Preview any worktree

Install Docker Engine and Docker Compose v2. From any checkout or Git worktree:

```sh
./scripts/wiki dev
./scripts/wiki url
./scripts/wiki logs
./scripts/wiki stop
```

`dev` builds a small image based on the official
[`ghcr.io/typst/typst:0.15.1`](https://github.com/typst/typst/pkgs/container/typst)
image, mounts **that worktree** at `/work`, and starts Typst's live-reloading
server. Open the printed port at `http://localhost:PORT`. Edit a `.typ` file,
`references.bib`, or `assets/style.css`; Typst rebuilds and reloads the browser.
Compilation errors appear in `logs`; the last successful build remains served.
Output goes to that worktree's ignored `_site/` directory and uses your user ID.
No local Typst, Python, R, Node, or Pandoc installation is needed to preview/build.

Each worktree gets a Compose project name derived from its absolute path and a
Docker-assigned host port by default, so checkouts with identical directory names
can run simultaneously. The script works from any working directory, including
hidden worktree paths. No container names or shared output volumes are fixed.

To choose a port (use a different one for each running worktree):

```sh
WIKI_PORT=3987 ./scripts/wiki dev
```

On exe.dev, choose a port between 3000 and 9999 and open
`https://YOUR-VM.exe.xyz:3987/`; the documented proxy supports these alternate
ports for users with VM access. See [proxy documentation](https://exe.dev/docs/proxy.md).
The default bind address is `0.0.0.0` to support VM access. For local-only access,
use `WIKI_BIND=127.0.0.1 ./scripts/wiki dev`.

Typst binds its own server to container loopback. The image adds `socat` to
forward container port 8080 to it; Docker publishes that port on the host.
The compiler image is pinned by version and digest. Typst's HTML and bundle
exports are **experimental**; inspect the site when upgrading the compiler.

## Author and build

- `pages/*.typ` contains the wiki's research content in native Typst syntax.
- `wiki.typ` declares the output pages and the shared bibliography.
- `template.typ` and `assets/style.css` provide navigation and presentation.
- `references.bib` contains the cited literature; citations link to the shared
  References page. Page links are relative, so the site works under `/lab-wiki/`.

Add a page under `pages/`, register its `document` in `wiki.typ`, and add navigation
where appropriate. Use unique labels across the bundle. Native Typst equations
use `$...$` inline and whitespace inside the delimiters for display equations;
see the existing pages for examples.

```sh
./scripts/wiki build
```

The static website is written to `_site/`. It includes CSS, figures, and local
webfonts. Articles use Libertinus Serif, and native MathML equations use
Libertinus Math, with no external font or math-script dependency.
The WOFF2 files in `assets/fonts/` are from
[Libertinus v7.050](https://github.com/alerque/libertinus/releases/tag/v7.050)
and ship with the [SIL Open Font License](assets/fonts/OFL.txt). When updating
the fonts, check that the Math WOFF2 retains its OpenType `MATH` table.

## Reproduce the research figure

The rate–distortion figure is committed as SVG so ordinary builds need only
Docker. Its Python source retains the original finite-distribution assertions
at zero distortion, distortion 0.18, and zero information. To regenerate it with
[uv](https://docs.astral.sh/uv/):

```sh
MPLBACKEND=Agg uv run --locked scripts/rate-distortion-prior.py
```

Commit both the script and regenerated SVG when changing the example. Python's
locked NumPy/Matplotlib dependencies are only for this optional step.

## Continuous release and GitHub Pages

[Release wiki](.github/workflows/release-wiki.yml) builds on every push to `main`
and on manual dispatch, using the same Docker compiler as local builds. It
updates the `continuous` prerelease with `lab-wiki-html.tar.gz` and uploads the
exact site as a `pages-site` artifact. Extract the archive and open `index.html`;
`COMMIT.txt` identifies the source commit.

[Publish GitHub Pages](.github/workflows/publish-pages.yml) deploys that artifact
after a successful release build. Set the repository's **Settings → Pages →
Build and deployment → Source** to **GitHub Actions**. Pull requests also compile
the bundle through [Check wiki](.github/workflows/check.yml).
