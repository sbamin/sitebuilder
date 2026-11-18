# Progress

## 2026-10-11 - Review of Dockerfile and Gemfile for sitebuilder v1.6.0
- User prompt: examine Dockerfile and Gemfile changes; suggest changes for easier future edits, security, smaller image, and new features. Do not run docker or tests without asking.
- Done: read-only review of Dockerfile, Gemfile, Gemfile.lock, CI workflow, update_sitebuilder.md. No docker commands run.
- Key findings: Ruby Sass (gem sass 3.7.4) shadows dart-sass in PATH; git PPA has no effect on Debian (git stays 2.39.5); Gemfile.lock is not used during build; tool versions are ENV (leak to runtime) not ARG; no checksum checks on downloads; image runs as root; full ruby base image.
- Status: suggestions reported; waiting for user to choose which changes to apply.

## 2026-10-11 - Implement review items A to E (except E20 Zensical)
- User prompt: implement A-E; mkquartodocs works (keep it); skip Zensical; record all changes in a markdown file.
- Decisions: Debian trixie base (ruby 3.3.12, digest pinned); multi-stage slim image; non-root uid 1000; pagefind 1.5.2 from PyPI (symlink, PyPI has no CLI); Renovate (not Dependabot) because it also updates ARG tool versions; requirements.txt compiled with uv; Gemfile.lock DEPENDENCIES hand-edited (host ruby too old); .dockerignore as allowlist; Trivy report-only.
- Done: Dockerfile, Gemfile, Gemfile.lock, CI workflow, renovate.json, requirements.in/.txt, sitebuilder-versions, .dockerignore, README, update_sitebuilder.md, CHANGES_1.6.0.md. JSON/YAML syntax checked.
- Not done: no docker build or test (user must approve). User must add DOCKERHUB_TOKEN secret and install Renovate app.

## 2026-10-11 - Commit
- User: commit; Renovate app not used now, keep renovate.json.
- Done: docs say Renovate app is not installed; signed commit c1bb507 on dev. .claude/ not committed. Not pushed.
- Local arm64 build (user approved): OK, image sitebuilder:test. Hugo and dart-sass checksums OK; 99 gems installed frozen; pip install OK. Runtime checks not run yet (need user approval).
- Checks (user approved): found musl dart-sass broken (no musl loader; old images too, hidden by ruby sass). Fixed to glibc tarball. arm64 (subagent) and amd64 rebuilds pass: versions, sass --embedded, hugo dartsass smoke test as non-root. Size 929MB arm64 / 906MB amd64 vs 1.79GB old. Fix not committed.
- Commit: dart-sass fix + tag 1.5.10 (renamed CHANGES file). Not pushed.
- Rebuilt with cache (user choice): sitebuilder:1.5.10 (arm64), sitebuilder:1.5.10-amd64; label/env 1.5.10; removed test tags.
- Workflow items 1-5 done (GITHUB_TOKEN build secret for dart-sass API call, version check, concurrency, persist-credentials false, timeouts). YAML ok. Not built, not committed.
- Rebuilt arm64 sitebuilder:1.5.10 with secret-mount Dockerfile (no secret): OK, checksums OK, same image ID. Removed amd64 image; pruned dangling images. User asked what hadolint is.
- hadolint v2.15.1 (Docker Hub; ghcr denied): 0 errors; warnings DL3008 x2, DL3003+SC2164 (cd /tmp/gems), info DL3066 (USER name). CI threshold error -> passes.
- hadolint fixes (WORKDIR, USER 1000:1000, .hadolint.yaml DL3008) -> hadolint clean; arm64 rebuilt. README tested and rewritten (removed -P which exposed 8000/1313 on 0.0.0.0; 127.0.0.1 preview; generic jekyll; pagefind; github-pages repository note; Docker Desktop file sharing; singularity pull/exec untested). Tests in ~/Desktop/tmp (only shared dir), cleaned.
- Commit: CI hardening + hadolint + README. Not pushed.
- Tag 1.5.10 (signed) at 430e2e4 (CI-built commit per image revision label); pushed; GitHub release 1.5.10 created. d1eab19 (.claude files) stays local.

## 2026-10-23 - Security release 1.5.11 (SSL and others), enable Renovate
- User prompt: update sitebuilder for recent SSL security issues and others; enable Renovate; check Dependabot alerts page.
- Findings: Debian DSA-6531-1 (openssl 3.5.7-1~deb13u3); eMudhra/emSign CA key compromise (DSA-6572-1 ca-certificates deb13u1 drops G3 only; Mozilla/certifi also drop C1, C3); ruby 3.3.13 security release; go 1.27.3; 72 open Dependabot alerts (pillow, certifi, filelock, gitpython, gems).
- Decisions: apt-get upgrade in final stage; disable emSign C1/C3 in /etc/ca-certificates.conf with grep assert; Renovate on master (default) with OSV alerts, security PRs any time, weekly lockFileMaintenance. GitPython kept 3.1.62 (mkdocs-rss-plugin <3.2) and rubyzip 2.4.1 (github-pages -> jekyll-remote-theme 0.4.3 <3.0): documented as known open alerts.
- Done (user approved docker): Gemfile.lock via bundle lock --update in ruby:3.3.13 (~/Desktop/tmp mount); requirements.txt via uv --upgrade; arm64 build sitebuilder:1.5.11 OK; checksums OK; libssl3t64 deb13u3, ca-certificates deb13u1, certifi 2026.10.23; HTTPS from ruby, python, git OK; hugo dartsass, mkdocs, jekyll smoke OK; pip check OK; hadolint clean; Renovate validator OK. CHANGES_1.5.11.md added.
- Not done: amd64 build, Trivy scan, commit, Renovate app install (user action on GitHub).
- PR #17 merged (web UI; merge title had no buildimg, so build skipped). Alerts 107, 67 dismissed (tolerable_risk). Renovate auto-closed #14, #15. Build dispatched manually: run 40050181406.
- User note: ubuntu-latest moves to Ubuntu 26 from 2026-10-19; saved as memory for next release.
- Renovate schedule set to 1st and 15th (before 6am America/New_York) for all updates incl. security and lock file maintenance; updateNotScheduled false. Not committed.
- Fixed Renovate "pip-compile error": header needs --python-version=3.13 and --output-file= (equals forms); local renovate extract OK. Not committed.
- Build run 40050181406 OK: sbamin/sitebuilder:1.5.11 + latest, amd64+arm64, revision 30b43c5. Trivy HIGH 7, CRITICAL 0: GitPython 3.1.62, rubyzip 2.4.1 (known); pip 26.2.2 (latest) vendors urllib3 2.7.0, msgpack 1.1.2, setuptools 70.3.0; hugo 0.168.0 built with go 1.27.2 (CVE-2026-111943 crypto/x509). No fix upstream yet. Tag and release not done.
- User: all three -> CHANGES_1.5.11.md known items updated; push dev; signed tag 1.5.11 at 30b43c5; GitHub release.
- User: never force-push without a prompt right before it (saved as memory). Rebuild run 40052170692 on d9d73f0 in progress; tag move waits for user confirmation.
- Rebuild run 40052170692 OK (revision d9d73f0, amd64+arm64, Trivy same 7 HIGH, 0 CRITICAL). New signed tag 1.5.11 at d9d73f0 made locally; user force-pushed it manually (prefers to do force pushes).
- User: guard against MkDocs 2.0. Added mkdocs<2 to requirements.in, Renovate allowedVersions <2 for mkdocs, recompiled requirements.txt (no version change; mkdocs 1.6.1, material 9.7.7 already caps <2). Not committed.
