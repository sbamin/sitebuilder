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
