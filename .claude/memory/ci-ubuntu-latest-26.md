---
name: ci-ubuntu-latest-26
description: GitHub ubuntu-latest moves to Ubuntu 26 from 2026-10-19; check CI on next sitebuilder release
metadata:
  type: project
---

GitHub Actions warned (lint job, 2026-10-24) that `ubuntu-latest` migrates to Ubuntu 26 beginning 2026-10-19 (https://github.com/actions/runner-images/issues/14748). `.github/workflows/docker_build.yml` uses `runs-on: ubuntu-latest` for both jobs (hadolint, QEMU + buildx multi-arch build, Trivy).

**Why:** user asked to keep it in mind for the next release; a runner image change can break QEMU/buildx or docker-based actions without any repo change.

**How to apply:** on the next release, check which image the jobs ran on and whether the build still passes; if it breaks, pin `runs-on: ubuntu-24.04` or fix for 26. Related: [[docker-shared-dir]].
