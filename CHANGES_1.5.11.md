# sitebuilder 1.5.11: changes

This file records the changes to the image build in version 1.5.11. It is a security release.

Status: local arm64 build and checks pass. CI built and pushed amd64 and arm64 (run 40050181406, revision 30b43c5). Trivy: 0 critical, 7 high (see D).

## A. SSL and TLS

1. **OpenSSL.** `apt-get upgrade` in the final stage installs Debian security fixes that are newer than the base image digest. The image has `libssl3t64` 3.5.7-1~deb13u3, which fixes [DSA-6531-1](https://security-tracker.debian.org/tracker/DSA-6531-1) (13 CVEs).
2. **eMudhra (emSign) CA key compromise, 2026-10.** `ca-certificates` 20250419+deb13u1 (DSA-6572-1) removes emSign ECC Root CA - G3. Mozilla also removed emSign Root CA - C1 and emSign ECC Root CA - C3, but Debian still ships them. The final stage disables these two roots in `/etc/ca-certificates.conf`. The build fails if Debian removes them; then remove the loop.
3. **certifi 2026.10.23** (used by `requests`) has the Mozilla trust store without the compromised roots (Dependabot alert 68).

## B. Version updates

4. ruby 3.3.12 -> 3.3.13 (resolv CVE-2026-80212, CVE-2026-80213; Onigmo regexp fixes). Base image digests updated.
5. Go 1.27.2 -> 1.27.3, hugo 0.167.0 -> 0.168.0, dart-sass 1.105.1 -> 1.106.1.
6. `Gemfile.lock` refreshed with `bundle lock --update` in ruby:3.3.13: nokogiri 1.19.4, json 3.1.0, faraday 2.15.0, activesupport 8.1.4, addressable 2.9.0, concurrent-ruby 1.3.8.
7. `requirements.txt` recompiled with `uv pip compile --upgrade`: pillow 13.0.0, filelock 4.2.4, certifi 2026.10.23, and others.

## C. Renovate

8. `renovate.json` adds OSV vulnerability alerts, security pull requests at any time with the `security` label, and weekly lock file maintenance.

## D. Known open alerts

- **GitPython 3.1.62** (alert 107, fixed in 3.2.1). `mkdocs-rss-plugin` 1.19.0, installed by `mkdocs-material[recommended]`, needs `GitPython<3.2`. The fault is in `create_submodule()`, which the mkdocs git plugins do not call.
- **rubyzip 2.4.1** (alert 67, fixed in 3.4.0). `github-pages` 232 pins `jekyll-remote-theme` 0.4.3, which needs `rubyzip < 3.0`. The fault is in archive extraction. It applies only to a remote theme from an untrusted source.
- **pip 26.2.2** (the latest) bundles urllib3 2.7.0, msgpack 1.1.2 and setuptools 70.3.0 (pkg_resources) in `pip/_vendor`. Trivy reports them as high. The venv itself has urllib3 2.8.0 and msgpack 1.2.3. The bundled copies run only when you run `pip` in the image.
- **hugo 0.168.0** (the latest) is compiled with Go 1.27.2, so it has CVE-2026-111943 (crypto/x509, man-in-the-middle). This applies when hugo itself fetches over HTTPS, e.g. `resources.GetRemote` or `hugo deploy`. Hugo modules use the image Go 1.27.3. Take the next hugo release.
