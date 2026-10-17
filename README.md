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
the latest `main`, runs Quarto 1.10.19 in a digest-pinned disposable container, and
switches the live symlink only after a successful render. A five-minute timer
reconciles missed updates and retries failures. Push success means Git accepted
the change, not that publication succeeded. Rapid pushes may be coalesced.

## Renderer boundaries

The renderer has no network, credentials, Docker socket, or live-site mount. It
runs as UID 1000 with dropped capabilities, a read-only root filesystem, 2 GiB
memory, two CPUs, and a PID limit. Only its disposable workspace is writable.
Document execution is disabled; Quarto extensions and project scripts still run
inside the container. Python/R experiment environments are intentionally absent.
Commit precomputed results and local assets; externally referenced browser assets
can still require network access when readers view a page.

Only normal files/directories are published; symlinks and special files cause a
failed deployment. Five releases are retained under `/srv/wiki/www/releases`.
The active release is `/srv/wiki/www/current`; its source commit is recorded in
`/srv/wiki/deployed` outside the web root. Failed renders leave the previous site
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
already exist and the pinned image must be pulled first. Installed copies are
root-owned. Review any changes here before rerunning the installer. For renderer
upgrades, pull/test a new image and update the digest in the installer and
`/etc/wiki/renderer-image`, then force a render.

The bare repo currently belongs to the existing `exedev` host account. Future
agent integration should use restricted Git-only SSH credentials, not expose the
Docker socket or grant agents general host shell/sudo access.
