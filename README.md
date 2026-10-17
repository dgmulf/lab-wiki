# Research wiki host

Private HTTPS endpoint: https://clamber.exe.xyz:8080/

The exe.dev edge supplies certificates, TLS termination, and VM access authentication.
NGINX serves static files on host port 8080. Existing services and the primary proxy
target are unchanged. See https://exe.dev/docs/proxy.md for sharing/custom routing.

## Publishing

The canonical bare repository is `/srv/wiki/source.git`, with default branch `main`.
Host checkouts can use `git clone /srv/wiki/source.git research-wiki`.
Authorized SSH clients can use `git clone exedev@clamber.exe.xyz:/srv/wiki/source.git`.
SSH access must already be configured; no agent credentials or container mounts are
installed by this setup. Agent image and transport integration are deferred.

Authors edit `.qmd` files and `_quarto.yml`, commit, and push `main`. Concurrent
authors must pull/rebase when Git rejects a non-fast-forward push. Force pushes and
branch deletion are disabled. Other branches do not trigger publishing.

`post-receive` signals a systemd path unit. A serialized root-owned worker archives
the latest `main`, runs Quarto 1.10.19 in an image-ID-pinned disposable container, and
switches the live symlink only after a successful render. A five-minute timer
reconciles missed updates and retries failures. Push success means Git accepted
the change, not that publication succeeded. Rapid pushes may be coalesced.

## Renderer boundaries

The renderer has no network, credentials, Docker socket, or live-site mount. It
runs as UID 1000 with dropped capabilities, a read-only root filesystem, 2 GiB
memory, two CPUs, and a PID limit. Only its disposable workspace is writable.
Python and R code executes during rendering. Python includes Jupyter/ipykernel,
NumPy, pandas, SciPy, Matplotlib, and seaborn. R includes knitr, rmarkdown, ggplot2,
dplyr, tidyr, readr, and reticulate (configured to use the same Python environment).
Each page can use the Python/Jupyter engine or the R/knitr engine. For Python within
an R page, use reticulate. Use `eval: false` on individual code cells to skip them.
The worker passes `--execute`, so it also enables execution for older commits with
project-level execution disabled. Rendering does not provide network access;
commit input data/local assets, and install dependencies when building the image.
Externally referenced browser assets can still require network access for readers.

Only normal files/directories are published; symlinks and special files cause a
failed deployment. Five releases are retained under `/srv/wiki/www/releases`.
The active release is `/srv/wiki/www/current`; its source commit is recorded in
`/srv/wiki/deployed` outside the web root; `/srv/wiki/deployed-image` records the
renderer image ID. An image change triggers re-rendering even at the same commit.
Failed renders leave the previous site
available. Publication is atomic per request; browsers loading assets across a
deployment can still need a refresh.

## Operations

```sh
sudo systemctl status wiki-build.path wiki-build.timer wiki-nginx.service
sudo journalctl -u wiki-build.service -n 100 --no-pager
sudo systemctl start wiki-build.service
cat /srv/wiki/deployed
curl -I http://127.0.0.1:8080/
```

To force re-rendering of the same commit, remove `/srv/wiki/deployed`, then start
`wiki-build.service`. To roll back durably, revert the source commit and push main.
Back up `/srv/wiki/source.git`, `/etc/wiki`, and the deployment files here; releases
are reproducible output. This setup does not configure off-host backups.

`deploy/install` installs host configuration with sudo; Docker and NGINX must
already exist. It builds `deploy/renderer/Dockerfile` and saves the immutable local
image ID in `/etc/wiki/renderer-image`. The base Quarto image is pinned by digest;
Ubuntu packages are resolved at image build time. The installed package versions
are recorded inside the image at `/opt/renderer-packages.txt`. Preserve/export the
image for exact reproduction; rebuilding against updated apt repositories can
resolve different dependency versions. Installed configuration is root-owned.

To add packages, edit the Dockerfile, then build and test before publishing:

```sh
sudo bash deploy/build-renderer
sudo systemctl start wiki-build.service
```

The build validates the new image before activating it. To repeat validation of
the active image, run `sudo bash deploy/check-renderer`. The check renders Python
and R pages, checks computed output, creates plots in both
languages, and tests reticulate under the production container restrictions. Builds
require network access for downloading dependencies; rendering remains offline.

The bare repo currently belongs to the existing `exedev` host account. Future
agent integration should use restricted Git-only SSH credentials, not expose the
Docker socket or grant agents general host shell/sudo access.
