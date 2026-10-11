# sitebuilder 1.5.10: changes

This file records the changes to the image build in version 1.5.10.

Status: the files are changed. The image is not built and not tested yet.

## A. Bug fixes

1. **dart-sass is now the `sass` command.** The `github-pages` gem installs Ruby Sass 3.7.4. Before, `/usr/local/bundle/bin` came before `/opt/dart/bin` in `PATH`, so `sass` ran Ruby Sass. Hugo needs dart-sass (`sass --embedded`). Now `/opt/dart/bin` comes first in `PATH`.
2. **The git PPA is removed.** `ppa:git-core/ppa` is for Ubuntu only and had no effect on Debian. `software-properties-common` and `python3-launchpadlib` are removed too. git now comes from Debian trixie (2.47 line, before 2.39).

2b. **dart-sass uses the glibc build.** The `-musl` build needs `/lib/ld-musl-*.so.1`, which Debian does not have, so dart-sass did not start. Earlier images had the same fault, hidden because `sass` ran Ruby Sass. A local build of 1.5.10 found it.

## B. Easier future edits

3. **One version block.** `SITEBUILDER_VERSION`, `HUGO_VERSION` and `DART_SASS_VERSION` are `ARG` lines at the top of `Dockerfile`. They do not stay in the runtime environment (except `SITEBUILDER_VERSION`, on purpose). `LABEL` uses OCI keys and `SITEBUILDER_VERSION`. CI and `update_sitebuilder.md` read the tag from `Dockerfile`.
4. **`TARGETARCH`** replaces the parse of `TARGETPLATFORM`.
5. **Go comes from the official image:** `COPY --from=golang:1.27.2-trixie@sha256:...`. The Go download and arch logic are removed.
6. **`Gemfile.lock` is used in the build** with `BUNDLE_FROZEN=true`. The build fails if `Gemfile` and `Gemfile.lock` do not agree. `/scratch` is removed.
7. **`Gemfile` is smaller.** It keeps only `github-pages` and `jekyll-twitter-plugin`. `github-pages` 232 already sets `jekyll`, `jekyll-mentions`, `jekyll-redirect-from`, `nokogiri`, `ffi` and `webrick`. The `DEPENDENCIES` block in `Gemfile.lock` is changed to agree. The gem versions do not change.
8. **Python packages are in files.**
   - `requirements.in`: top-level packages.
   - `requirements.txt`: all packages with fixed versions. `uv pip compile` makes this file.
   - Removed: `singledispatch`, `six`, `nltk`, `fontawesome_markdown`, `mkdocs-git-revision-date-plugin`, and the duplicate `markdown`, `pygments`, `pymdown-extensions`, `mkdocs`, `mkdocs-material` entries (`mkdocs-material` extras install them).
   - Kept: `mkquartodocs`.
9. **Renovate config** (`renovate.json`, kept for later; the Renovate app is not installed now). When installed, it updates:
   - The base images (tag and digest).
   - GitHub Actions (pinned by commit SHA).
   - `Gemfile.lock`.
   - `requirements.txt` (pip-compile).
   - The hugo and dart-sass `ARG` lines (comment `# renovate:` above each line).
   - Ruby stays on 3.3.x for github-pages.
10. **Dockerfile syntax 1** with `RUN <<EOF` blocks and `--mount=type=cache` for apt, pip and gem downloads. The shell is `bash -euo pipefail`.

## C. Security

11. **Downloads are checked.** Hugo is checked against `hugo_<version>_checksums.txt`. dart-sass is checked against the SHA-256 digest of the GitHub release asset (from the GitHub API). `curl -fsSL` stops on HTTP errors. The hugo `.tar.gz` replaces the `.deb`, so `apt install ./file.deb` is removed.
12. **Base images are pinned by digest:** `ruby:3.3.12-trixie`, `ruby:3.3.12-slim-trixie`, `golang:1.27.2-trixie`. The patch line is 3.3.12 (before 3.3.7).
13. **Non-root user.** The image runs as `sitebuilder` (uid 1000, gid 1000). `/usr/local/bundle`, `/opt/venv`, `/opt/go` and `/web` belong to this user. `git config --system --add safe.directory '*'` replaces the `--global` setting for root. `README.md` tells Linux users with another uid to add `--user "$(id -u):$(id -g)" -e HOME=/tmp`.
14. **CI** (`.github/workflows/docker_build.yml`):
    - All actions are on the latest major versions and pinned by commit SHA.
    - `permissions: contents: read`.
    - hadolint lints `Dockerfile` on pushes and pull requests.
    - The build job runs on manual dispatch, or on a push with `buildimg` in the commit message.
    - `docker/metadata-action` pushes the version tag and `latest`. Before, CI pushed only `latest`.
    - Provenance (`mode=max`) and SBOM are on.
    - Trivy scans the pushed image for CRITICAL and HIGH problems. It only reports and does not fail the job.
    - The build gets `GITHUB_TOKEN` as the BuildKit secret `github_token`. The dart-sass step uses it for the GitHub API call, so the shared runner IP does not hit the rate limit. Local builds work without it.
    - The job stops if `ARG SITEBUILDER_VERSION` is not found in `Dockerfile`.
    - `concurrency` stops two builds of the same branch from running at the same time.
    - Checkout does not keep the git token (`persist-credentials: false`).
    - Time limits: 10 minutes for lint, 90 minutes for build.
    - The secret is now `DOCKERHUB_TOKEN` (a Docker Hub access token). Before, it was `DOCKERHUB_PASSWORD`.
14b. **hadolint fixes.** `WORKDIR /tmp/gems` replaces `cd` in `RUN` (DL3003, SC2164). `USER 1000:1000` replaces `USER sitebuilder`, so tools can see that the user is not root (DL3066). `.hadolint.yaml` ignores DL3008 (fixed apt versions), because the base image digest fixes the package set. hadolint v2.15.1 gives no findings.
15. **`.dockerignore`** is an allowlist. Only `Gemfile`, `Gemfile.lock`, `requirements.txt` and `sitebuilder-versions` go to the build context.

## D. Smaller image

16. **No locale packages.** `C.UTF-8` is built into Debian glibc. Only `LANG=C.UTF-8` is set. The `LC_ALL` and `LANG` conflict is removed.
17. **Multi-stage build on `ruby:3.3.12-slim-trixie`.** The builder stage installs gems (it has a compiler for `commonmarker`) and the Python venv, and downloads hugo and dart-sass. The final stage gets only the results. Gem `.gem` files stay in a build cache and are not in the image. Object files (`*.o`) of compiled gems are deleted. The final stage installs `git`, `openssh-client`, `python3`, `libcairo2` (mkdocs-material imaging) and `libstdc++6` (hugo extended).
18. **One `ENV` block** with one `PATH`, and `PYTHONDONTWRITEBYTECODE=1` and `PIP_DISABLE_PIP_VERSION_CHECK=1`.
19. **No `python3-distutils`.** Debian trixie does not have it. Python is now 3.13.

## E. New features

20. Zensical: not done (user decision).
21. **pagefind from PyPI:** `pagefind[extended]==1.5.2` (stable; before `v1.5.0-beta.1`, not extended). The PyPI package has no `pagefind` command, so the build links the binary to `/opt/venv/bin/pagefind`. `python3 -m pagefind` also works.
22. **Default command** is `CMD ["bash"]`. `ENTRYPOINT []` is removed.
23. **`sitebuilder-versions` script** shows all tool versions: `docker run --rm sbamin/sitebuilder sitebuilder-versions`. A `HEALTHCHECK` was not added, because the image is a build tool and not a service.
24. The old comment about the mkdocs-material beta is removed.

## README

- `-P` is removed from the serve commands. It published ports 8000 and 1313 on all network interfaces (`0.0.0.0`). Now only `127.0.0.1:4000` is published.
- Preview address is `http://127.0.0.1:4000`, not `http://0.0.0.0:4000`. Serve commands use `-it`, so Ctrl+C stops the server.
- The jekyll serve command is generic (no site-specific `-c _devconfig.yml -d _sitelocal`). The old note about rb-inotify on Apple silicon is removed: `--watch` works in a local test. `--force_polling` is given as a fallback.
- The hugo build command has `--rm`. A pagefind command is added.
- New notes: `repository:` for `github-pages` sites, Docker Desktop file sharing on macOS, and arm64 images.
- Singularity: `singularity pull` and `singularity exec` replace `singularity run` (not tested).
- The broken Hugo link is fixed.
- Local tests on arm64 (Docker Desktop, macOS): all build and serve commands in `README.md` work for mkdocs, jekyll (with and without a `github-pages` Gemfile) and hugo, and pagefind works.

## Changes for users

- The container user is not root. On a Linux host with a uid other than 1000, use `--user` (see `README.md`).
- The final image has no C compiler. If a site `Gemfile` needs a gem that has native code and is not in the image, `bundle install` in the container fails.
- `pagefind` is the extended build (adds Chinese and Japanese word splitting).

## Steps for the maintainer

1. Build and test the image. These steps were not done.
2. In GitHub repository secrets, add `DOCKERHUB_TOKEN` and remove `DOCKERHUB_PASSWORD`.
3. The Renovate app is not installed now. `renovate.json` is kept for later use. Until then, update versions by hand (see `update_sitebuilder.md`).
4. After the first build, look at the hadolint and Trivy output in CI.

## Files

- Changed: `Dockerfile`, `Gemfile`, `Gemfile.lock` (`DEPENDENCIES` block only), `.github/workflows/docker_build.yml`, `update_sitebuilder.md`, `README.md`.
- New: `.hadolint.yaml`, `requirements.in`, `requirements.txt`, `sitebuilder-versions`, `.dockerignore`, `renovate.json`, `CHANGES_1.5.10.md`.
