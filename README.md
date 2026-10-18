# Research wiki host

NGINX serves the rendered wiki and Git smart HTTP on port 8080 of an isolated
exe.dev VM. exe.dev's HTTPS proxy provides TLS and authenticates browser sessions
and VM tokens. No hostname is embedded in the server configuration.

## Deploy to exe.dev

Use a dedicated Debian/Ubuntu VM with systemd and enough memory/disk for the
renderer image (renders are limited to 2 GiB; allow additional memory for the host
and image builds). Do not run authoring agents on this VM or give them shell,
sudo, Docker, or filesystem access to it.

On your administrator workstation, select the VM and configure its proxy:

```sh
WIKI_VM=mulfordlab                  # change for another deployment
WIKI_HOST="$WIKI_VM.exe.xyz"
ssh exe.dev share set-private "$WIKI_VM"
ssh exe.dev share port "$WIKI_VM" 8080
```

Keep the proxy private. Every user granted web access to this VM is a trusted wiki
author with read/write Git access. Use exe.dev web shares for those authors, rather
than root shares. Requests to Git without `X-ExeDev-UserID` are rejected even if
the site is accidentally made public, but this header is trusted proxy input,
not a signature verified by this server. Port 8080 must only be reachable through
exe.dev's proxy or by trusted VM administrators; do not expose it through another
forwarder or untrusted private network. See [exe.dev proxy configuration](https://www.exe.dev/docs/proxy)
and [identity headers](https://www.exe.dev/docs/login-with-exe).

Copy this checkout to a directory on the VM readable by `wiki-git` (for example,
`/opt/lab-wiki-host`) with your administrator connection, then run there:

```sh
sudo apt-get update
sudo apt-get install -y git nginx fcgiwrap docker.io
sudo systemctl enable --now docker
sudo bash deploy/install
```

`deploy/install` creates a `wiki-git` system account with no login shell, installs
the services, builds and validates the renderer, and initializes the empty bare
repository. It can be rerun to update installed configuration; older repositories
owned by `exedev` are migrated to `wiki-git`. It does not push source content or
change exe.dev sharing settings. The package's default NGINX/fcgiwrap services are
not used; this project has its own NGINX instance and FastCGI socket.

From this checkout on the VM, seed the site once after installing:

```sh
sudo -u wiki-git git -c safe.directory="$PWD" push /srv/wiki/source.git main
sudo systemctl start wiki-build.service
curl --fail http://127.0.0.1:8080/ >/dev/null
```

Then open `https://$WIKI_HOST/` in a browser with web access to the VM. Later wiki
edits use the canonical repository below. Host tooling updates still require an
administrator to rerun the installer; pushing `deploy/` files does not install them.

## Publishing

The canonical bare repository is `/srv/wiki/source.git`, with default branch `main`.
Agents on other VMs clone `https://$WIKI_HOST/source.git` and authenticate with an
[exe.dev HTTPS VM token](https://www.exe.dev/docs/https-tokens-for-vms#using-with-git),
using the token as the Basic-auth password. exe.dev validates it before forwarding
the request and supplies the identity used by Git. Tokens are scoped to the
**destination wiki VM**, not the agent VM. No SSH access to the wiki VM is needed.

An administrator with access to the destination VM mints a token from their
workstation (use a separate label/token for each agent):

```sh
ssh exe.dev ssh-key generate-api-key --vm="$WIKI_VM" --label=wiki-agent
```

Securely provision the returned token onto the agent VM as
`~/.config/wiki-tokens/$WIKI_HOST` (only the token, with an optional trailing newline).
Keep it out of Git, remote URLs, command history, and logs. Make the directory mode
0700 and the token file mode 0600. Copy `deploy/git-credential-wiki` onto the agent,
then configure Git there, setting `WIKI_HOST` to the destination hostname:

```sh
install -d -m 0700 "$HOME/.config/wiki-tokens"
chmod 0600 "$HOME/.config/wiki-tokens/$WIKI_HOST"
install -d "$HOME/.local/bin"
install -m 0755 deploy/git-credential-wiki "$HOME/.local/bin/git-credential-wiki"
git config --global "credential.https://$WIKI_HOST.username" token
# Clear inherited helpers for this host, then add the read-only token helper.
git config --global --replace-all "credential.https://$WIKI_HOST.helper" ''
git config --global --add "credential.https://$WIKI_HOST.helper" \
    '!"$HOME/.local/bin/git-credential-wiki"'
GIT_TERMINAL_PROMPT=0 git clone "https://$WIKI_HOST/source.git" research-wiki
```

The helper only returns credentials for HTTPS and reads the file matching the
requested host, so tokens for different deployments remain separate. It does not
store passwords. Provision/rotate tokens outside the server and renderer; no token
or account SSH key belongs in the rendered wiki or renderer image.

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
sudo systemctl status wiki-git.socket wiki-git.service
sudo journalctl -u wiki-build.service -n 100 --no-pager
sudo journalctl -u wiki-git.service -n 100 --no-pager
sudo systemctl start wiki-build.service
cat /srv/wiki/deployed
curl -I http://127.0.0.1:8080/
```

To force re-rendering of the same commit, remove `/srv/wiki/deployed`, then start
`wiki-build.service`. To roll back durably, revert the source commit and push main.
Back up `/srv/wiki/source.git`, `/etc/wiki`, and the deployment files here; releases
are reproducible output. This setup does not configure off-host backups.

`deploy/install` installs host configuration with sudo; Git, Docker, NGINX, and
fcgiwrap must already exist. It builds `deploy/renderer/Dockerfile` and saves the
immutable local image ID in `/etc/wiki/renderer-image`. The base Quarto image is pinned by digest;
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

Git runs through a dedicated systemd-activated fcgiwrap socket as `wiki-git`, with
write access limited to the bare repository and build queue. NGINX does not run
Git as `www-data` or `exedev`. Only `/source.git/` is forwarded to Git's HTTP
backend; dumb HTTP file access is disabled. The root-owned receive hook lives
outside the writable repository. Authenticated requests set `REMOTE_USER`, which
enables Git's authenticated push service; anonymous receive-pack is not enabled.
Push bodies are limited to 100 MiB by NGINX. exe.dev may impose additional limits.
All branches are readable by authorized authors; only `main` publishes.

To test the HTTP transport without installing the services, run
`bash deploy/test-http` as an unprivileged user on a machine with NGINX, fcgiwrap,
Git, and curl. It uses temporary repositories and a loopback listener on port 18080
(`WIKI_TEST_PORT` overrides it), and simulates the proxy's identity headers. It
checks clone/fetch/push, anonymous rejection, protocol v2, a push over 1 MiB, the
publish hook, force-push/deletion rejection, and credential helper scoping. This
does not validate exe.dev's proxy or Linux systemd confinement. After deployment,
repeat a clone and a push from an agent VM with a real token, confirm an
unauthenticated HTTPS request cannot read Git, and check the build journal and
published page. An unauthorized request may redirect to exe.dev login rather than
returning a Git response.
