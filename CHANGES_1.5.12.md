# sitebuilder 1.5.12: changes

This file records the changes to the image build in version 1.5.12. It is a security release from Renovate pull requests.

Status: not built locally. CI build and Trivy scan pending.

## A. Security updates

1. **GitPython 3.1.62 -> 3.2.1** (alert 107, PR #19).
2. **Go 1.27.3 -> 1.27.4** (PR #23, digests PR #20, #26). PR #21 closed: #23 replaces it.
3. **ruby 3.3.13 base image digests** (PR #22, #27).
4. **hugo 0.168.0 -> 0.170.1** (PR #24, #28). Check if Trivy still reports CVE-2026-111943 (hugo 0.168.0 used Go 1.27.2).
5. **dart-sass 1.106.1 -> 1.108.2** (PR #29), **docker/login-action v4.6.0 -> v4.8.0** (PR #30).

## B. Python packages

6. mkdocs-material 9.7.7 -> 9.8.1 (PR #19 and refresh). 9.8.0 removes `mkdocs-rss-plugin` from the `recommended` extra.
7. `mkdocs-rss-plugin` 1.20.0 is now in `requirements.in`, so the `rss` plugin stays in the image. 1.20.0 needs `GitPython>=3.2.1,<3.3`.
8. `mkdocs<2` in `requirements.in`, and a Renovate rule keeps mkdocs on 1.x. MkDocs 2.0 removes the plugin system.
9. `requirements.txt` recompiled with `uv pip compile --upgrade` (replaces PR #31, which did not have items 7 and 8): pagefind 1.6.0, pymdown-extensions 13.1, python-dateutil 4.0.0, watchdog 7.1.0, tzdata 2026.6, and others.

## C. Known open alerts

- **rubyzip 2.4.1** (alert 67): no change, see CHANGES_1.5.11.md.
- **pip vendored packages**: see CHANGES_1.5.11.md. Check again after the CI Trivy scan.
