---
name: no-docker-without-asking
description: Never run docker commands or tests in sitebuilder without asking the user first, even in auto mode
metadata:
  type: feedback
---
Do not run any docker command (build, run, pull, buildx) or any test without asking the user first, even in auto mode.

**Why:** User said so explicitly when updating the sitebuilder image (2026-10-11); builds push multi-arch images and take time.

**How to apply:** Edit files and do read-only network lookups (registry digests, GitHub/PyPI metadata) freely; ask before any docker or test command.
