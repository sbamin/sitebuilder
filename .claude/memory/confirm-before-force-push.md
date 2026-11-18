---
name: confirm-before-force-push
description: Always ask the user right before any force push (branch or tag), even if an earlier request implies it
metadata:
  type: feedback
---

Prompt the user for explicit confirmation immediately before any force push (`git push --force`, `--force-with-lease`, `+ref`, moving a pushed tag). An earlier request such as "update the tag" does not count as approval for the force push itself.

**Why:** 2026-10-24, while rebuilding sitebuilder 1.5.11, I planned to force-push the moved tag `1.5.11` because the user had asked to "update tag accordingly". The user corrected: do not force-push just because they asked; prompt first.

**How to apply:** prepare the change locally, show what the force push replaces (old ref -> new ref), then ask and wait. The user prefers to run force pushes manually (2026-10-24, tag 1.5.11), so offer the exact command for them to run instead of running it. Related: [[no-docker-without-asking]].
