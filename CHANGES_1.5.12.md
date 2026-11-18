# sitebuilder 1.5.12: changes

This file records the changes to the image build in version 1.5.12. It is a security release from Renovate pull requests.

Status: local arm64 build OK (890MB). Checksums OK; pip check OK; non-root; hugo dartsass, mkdocs with rss plugin, jekyll with jekyll-feed, ruby and python HTTPS smoke tests OK. CI build and Trivy scan pending.

Note: mkdocs-material 9.8.1 prints that Material for MkDocs reaches end of life on 2027-05-05 (Zensical is the successor). Set `NO_MKDOCS_2_WARNING=1` to hide the notice.

## A. Security updates

1. **GitPython 3.1.62 -> 3.2.1** (alert 107, PR #19).
2. **Go 1.27.3 -> 1.27.4** (PR #23, digests PR #20, #26). PR #21 closed: #23 replaces it.
3. **ruby 3.3.13 base image digests** (PR #22, #27).
4. **hugo 0.168.0 -> 0.170.1** (PR #24, #28). Hugo 0.170.0 removes the extended edition and the `extended_withdeploy` archives, so the Dockerfile now downloads `hugo_withdeploy_*`. LibSass is gone; the image uses dart-sass. `hugo.IsExtended` is now always false. Check if Trivy still reports CVE-2026-111943 (hugo 0.168.0 used Go 1.27.2).
5. **dart-sass 1.106.1 -> 1.108.2** (PR #29), **docker/login-action v4.6.0 -> v4.8.0** (PR #30).
6. **rubyzip 2.4.1 -> 3.7.0** (alert 67). github-pages 232 -> 233 changes jekyll-remote-theme 0.4.3 -> 0.6.2, which accepts `rubyzip < 4.0`. Renovate could not update `Gemfile.lock` (artifact update failed), so `bundle lock --update` ran in ruby:3.3.13-trixie: nokogiri 1.19.7, openssl gem 4.0.2 (new, from jekyll-remote-theme), prism 2.1.0, jekyll-seo-tag 2.9.1, jekyll-feed 0.18.0. jekyll stays 3.10.0.

## B. Python packages

7. mkdocs-material 9.7.7 -> 9.8.1 (PR #19 and refresh). 9.8.0 removes `mkdocs-rss-plugin` from the `recommended` extra.
8. `mkdocs-rss-plugin` 1.20.0 is now in `requirements.in`, so the `rss` plugin stays in the image. 1.20.0 needs `GitPython>=3.2.1,<3.3`.
9. `mkdocs<2` in `requirements.in`, and a Renovate rule keeps mkdocs on 1.x. MkDocs 2.0 removes the plugin system.
10. `requirements.txt` recompiled with `uv pip compile --upgrade` (replaces PR #31, which did not have items 8 and 9): pagefind 1.6.0, pymdown-extensions 13.1, python-dateutil 4.0.0, watchdog 7.1.0, tzdata 2026.6, and others.

## C. Known open alerts

- **pip vendored packages**: see CHANGES_1.5.11.md. Check again after the CI Trivy scan.
