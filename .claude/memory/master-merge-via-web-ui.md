---
name: master-merge-via-web-ui
description: sitebuilder master needs 1 review + signed commits; user merges PRs in GitHub web UI, not gh --admin
metadata:
  type: feedback
---
Since 2026-11-18 the ruleset `protect_master` (not classic branch protection) on sbamin/sitebuilder master requires 1 approving review, code owner review, signed commits, resolved threads, no force push or deletion, so `gh pr merge` fails. On 2026-11-18 the user chose to approve and merge in the GitHub web UI instead of `gh pr merge --admin`.

**Why:** user keeps control of merges to master; no admin bypass.
**How to apply:** prepare PRs, then ask the user to merge in the web UI. Do not use `--admin`. Related: [[confirm-before-force-push]].
