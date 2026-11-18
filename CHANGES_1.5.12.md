# sitebuilder 1.5.12: changes

This file records the changes to the image build in version 1.5.12. It is a security release from Renovate pull requests.

Status: not built locally. CI build and Trivy scan pending.

## A. Security updates

1. **GitPython 3.1.62 -> 3.2.1** (alert 107, PR #19).
2. **Go 1.27.3 -> 1.27.4** (PR #23, PR #20 digest). PR #21 closed: #23 replaces it.
3. **ruby 3.3.13 base image digests** (builder and slim, PR #22).
4. **hugo 0.168.0 -> 0.170.0** (PR #24). Check if Trivy still reports CVE-2026-111943 (hugo 0.168.0 used Go 1.27.2).

## B. Python packages

5. mkdocs-material 9.7.7 -> 9.8.0 (PR #19). 9.8.0 removes `mkdocs-rss-plugin` from the `recommended` extra.
6. `mkdocs-rss-plugin` 1.20.0 is now in `requirements.in`, so the `rss` plugin stays in the image. 1.20.0 needs `GitPython>=3.2.1,<3.3`.
7. `mkdocs<2` in `requirements.in`, and a Renovate rule keeps mkdocs on 1.x. MkDocs 2.0 removes the plugin system.

## C. Known open alerts

- **rubyzip 2.4.1** (alert 67): no change, see CHANGES_1.5.11.md.
- **pip vendored packages**: see CHANGES_1.5.11.md. Check again after the CI Trivy scan.
