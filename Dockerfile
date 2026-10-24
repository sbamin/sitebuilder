# syntax=docker/dockerfile:1
############################################################
# Dockerfile for website build using jekyll, hugo, or mkdocs
############################################################

#### Versions: edit only this block for a new release ####
## Base images (ruby, golang) are pinned in FROM lines below.
## ruby should be compliant with github-pages, https://pages.github.com/versions/
ARG SITEBUILDER_VERSION=1.5.10
# renovate: datasource=github-releases depName=gohugoio/hugo
ARG HUGO_VERSION=0.167.0
# renovate: datasource=github-releases depName=sass/dart-sass
ARG DART_SASS_VERSION=1.105.1

#### Go toolchain (for hugo modules) ####
## https://go.dev/dl/
FROM golang:1.27.3-trixie@sha256:fbb7ae40b62ff8afe31662df570d39b4f5052ac32b90dae8e60d7657a20a74f4 AS go

#### Builder: gems, python venv, hugo, dart-sass ####
FROM ruby:3.3.12-trixie@sha256:a91b6ac1b9b18d33812480856e4bc39c5c492ff9c6cc810d916cc3f0cc1d0eab AS builder

ARG TARGETARCH
ARG HUGO_VERSION
ARG DART_SASS_VERSION

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked <<EOF
rm -f /etc/apt/apt.conf.d/docker-clean
apt-get update
apt-get install -y --no-install-recommends python3-venv
EOF

## jekyll and github-pages gems, versions from Gemfile.lock
COPY Gemfile Gemfile.lock /tmp/gems/
WORKDIR /tmp/gems
RUN --mount=type=cache,target=/usr/local/bundle/cache <<EOF
BUNDLE_FROZEN=true bundle install --jobs "$(nproc)"
find /usr/local/bundle/gems -path '*/ext/*' -name '*.o' -delete
EOF

## mkdocs, mkdocs-material, plugins, and pagefind, versions from requirements.txt
COPY requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip <<EOF
python3 -m venv /opt/venv
/opt/venv/bin/pip install --upgrade pip
/opt/venv/bin/pip install -r /tmp/requirements.txt
ln -s "$(echo /opt/venv/lib/python3*/site-packages/pagefind_bin_extended/pagefind_extended)" /opt/venv/bin/pagefind
EOF

## hugo extended and dart-sass, checksum verified
## optional secret github_token avoids GitHub API rate limit (CI)
WORKDIR /tmp/dl
RUN --mount=type=secret,id=github_token <<EOF
case "${TARGETARCH}" in
    amd64) SASS_ARCH="x64" ;;
    arm64) SASS_ARCH="arm64" ;;
    *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;;
esac

hugo_url="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}"
hugo_tgz="hugo_extended_withdeploy_${HUGO_VERSION}_linux-${TARGETARCH}.tar.gz"
curl -fsSLO "${hugo_url}/${hugo_tgz}"
curl -fsSL "${hugo_url}/hugo_${HUGO_VERSION}_checksums.txt" | grep " ${hugo_tgz}\$" | sha256sum -c -
mkdir -p /opt/hugo
tar -C /opt/hugo -xzf "${hugo_tgz}" hugo

## dart-sass has no checksum file; use the GitHub release asset digest
export SASS_TGZ="dart-sass-${DART_SASS_VERSION}-linux-${SASS_ARCH}.tar.gz"
curl -fsSLO "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/${SASS_TGZ}"
gh_auth=()
if [ -s /run/secrets/github_token ]; then
    gh_auth=(-H "Authorization: Bearer $(cat /run/secrets/github_token)")
fi
sass_sha=$(curl -fsSL "${gh_auth[@]}" "https://api.github.com/repos/sass/dart-sass/releases/tags/${DART_SASS_VERSION}" |
    python3 -c 'import json, os, sys; print(next(a["digest"] for a in json.load(sys.stdin)["assets"] if a["name"] == os.environ["SASS_TGZ"]).removeprefix("sha256:"))')
echo "${sass_sha}  ${SASS_TGZ}" | sha256sum -c -
tar -C /opt -xzf "${SASS_TGZ}"
mkdir -p /opt/dart
mv /opt/dart-sass /opt/dart/bin
EOF

#### Final image ####
FROM ruby:3.3.12-slim-trixie@sha256:47b93492bc6afc708dc4f2478c7f1867725c64b3bf43b94ea1bad2dac0314f02

ARG SITEBUILDER_VERSION

LABEL org.opencontainers.image.title="sitebuilder" \
    org.opencontainers.image.version="${SITEBUILDER_VERSION}" \
    org.opencontainers.image.authors="Samirkumar Amin" \
    org.opencontainers.image.description="docker image to build jekyll, hugo or mkdocs supported website" \
    org.opencontainers.image.url="https://github.com/sbamin/sitebuilder" \
    org.opencontainers.image.source="https://github.com/sbamin/sitebuilder" \
    org.opencontainers.image.licenses="MIT"

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

## git and openssh-client: hugo modules, mike, git plugins
## libcairo2: mkdocs-material imaging (social cards)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked <<EOF
rm -f /etc/apt/apt.conf.d/docker-clean
apt-get update
apt-get install -y --no-install-recommends \
    git \
    openssh-client \
    python3 \
    libcairo2 \
    libstdc++6
groupadd --gid 1000 sitebuilder
useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash sitebuilder
install -d -o sitebuilder -g sitebuilder /web /opt/go
git config --system --add safe.directory '*'
EOF

COPY --from=go /usr/local/go /usr/local/go
COPY --from=builder --chown=sitebuilder:sitebuilder /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=sitebuilder:sitebuilder /opt/venv /opt/venv
COPY --from=builder /opt/dart /opt/dart
COPY --from=builder /opt/hugo/hugo /usr/local/bin/hugo
COPY --chmod=755 sitebuilder-versions /usr/local/bin/sitebuilder-versions

## /opt/dart/bin must come before /usr/local/bundle/bin, so that
## sass is dart-sass and not ruby sass from github-pages gem.
## PYTHONPATH: intended path to python modules for mkdocstrings
ENV SITEBUILDER_VERSION="${SITEBUILDER_VERSION}" \
    LANG="C.UTF-8" \
    GOPATH="/opt/go" \
    PYTHONPATH="/web/api/py" \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PATH="/opt/venv/bin:/opt/dart/bin:/usr/local/bundle/bin:/usr/local/go/bin:/opt/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

USER 1000:1000

## empty dir where user volume should be mounted
## to run jekyll/mkdocs/hugo related commands
WORKDIR /web

#### expose ports for jekyll, mkdocs, and hugo serve command ####
EXPOSE 4000 8000 1313

CMD ["bash"]

## END ##
