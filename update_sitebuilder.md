## Building your own sitebuilder container

Requires [Docker](https://www.docker.com) and [git](https://git-scm.com)

*   Clone sitebuilder repo

```sh
mkdir -p ~/tmp
cd tmp
git clone https://github.com/sbamin/sitebuilder.git
cd sitebuilder
git pull
git status
```

>status should be up-to-date and point to `main` git branch.

### Update packages

All versions live in version-controlled files. The [Renovate app](https://github.com/apps/renovate) reads `renovate.json` and opens pull requests against `master` for base image digests, `ARG` tool versions, gems, Python packages and GitHub Actions. Security fixes (GitHub and OSV alerts) get a pull request at once, with the `security` label. Each Monday, lock file maintenance refreshes the indirect dependencies in `Gemfile.lock` and `requirements.txt`. You can also update the files by hand.

| What | Where |
|---|---|
| sitebuilder image tag | `ARG SITEBUILDER_VERSION` in `Dockerfile` |
| [hugo extended](https://github.com/gohugoio/hugo/releases), [dart-sass](https://github.com/sass/dart-sass/releases) | `ARG HUGO_VERSION`, `ARG DART_SASS_VERSION` in `Dockerfile` |
| ruby and [go](https://go.dev/dl/) | `FROM ruby:...` and `FROM golang:...` lines (tag and digest) in `Dockerfile` |
| jekyll gems | `Gemfile` and `Gemfile.lock` |
| mkdocs, plugins, pagefind | `requirements.in` (top-level) and `requirements.txt` (pinned) |

*   Set a new image tag, e.g., `1.5.10`, typically a level up than [the current version](https://hub.docker.com/r/sbamin/sitebuilder/tags), in `ARG SITEBUILDER_VERSION`. The commands below read the tag from `Dockerfile`.

*   Keep ruby on the version line used by [github-pages](https://pages.github.com/versions/). To get a new digest for a base image tag:

```sh
docker buildx imagetools inspect ruby:3.3.12-slim-trixie --format '{{json .Manifest.Digest}}'
```

*   Update python packages. Edit `requirements.in` if you add or remove a package. Then compile pinned versions with [uv](https://docs.astral.sh/uv/). See [mkdocs-material upgrade notes](https://squidfunk.github.io/mkdocs-material/upgrade/).

```sh
uv pip compile requirements.in --universal --python-version 3.13 --upgrade -o requirements.txt
```

*   Update jekyll gems. `Gemfile` keeps only `github-pages` and plugins that `github-pages` does not include. The build uses `Gemfile.lock` as is (frozen). To update the lock file, use the current sitebuilder image (host ruby is too old):

```sh
docker run --rm -v "$(pwd)":/hostspace -w /hostspace sbamin/sitebuilder bundle lock --update
```

### build and push multi-arch images

Here, I am using `docker buildx build` from [Docker Desktop v4.22.0 on mac os 15.3 M2](https://www.docker.com/products/docker-desktop/) to build both, amd64 and arm64 images. [See this guide for multi-arch builds](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/).

GitHub Actions can also build and push: run the workflow manually, or push to `master` with `buildimg` in the commit message. The workflow needs repository secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` (a [Docker Hub access token](https://docs.docker.com/security/access-tokens/), not the password).

*   Start building a docker image. You need to replace `sbamin/sitebuilder` with your respective [docker hub user id](https://hub.docker.com) and image name you like to rename.

```sh
## buildx sets TARGETARCH (amd64 or arm64) in Dockerfile
## to download platform specific hugo and dart-sass

## requires login to docker hub from Docker Desktop app
## replace --push with --load to load arch specific image locally
SB_VERSION="$(sed -n 's/^ARG SITEBUILDER_VERSION=//p' Dockerfile)"
docker buildx build \
	--platform linux/arm64,linux/amd64 \
	--tag "sbamin/sitebuilder:${SB_VERSION}" \
	--tag sbamin/sitebuilder:latest \
	--provenance=mode=max \
	--sbom=true \
	--push \
	--file Dockerfile .
```

Check [docker hub: sbamin/sitebuilder](https://hub.docker.com/r/sbamin/sitebuilder/tags) and should show an updated tag. If so, update local image using `docker images` and then `docker pull sbamin/sitebuilder` to get a latest tag.

*   Check installed or updated package versions

```sh
docker run --rm sbamin/sitebuilder sitebuilder-versions

## for non-os compliant OS, e.g., amd64 if using macos M2
docker run --platform linux/amd64 --rm sbamin/sitebuilder sitebuilder-versions
```

### Update github releases

```sh
git add Dockerfile Gemfile Gemfile.lock requirements.in requirements.txt sitebuilder-versions .dockerignore renovate.json .github/workflows/docker_build.yml update_sitebuilder.md README.md CHANGES_1.5.11.md

## write a multiline git commit message
## -s requires a valid gpg key for signing a message
git commit -s -F- <<EOF
Updated sitebuilder
v1.5.10

- ✨ added pagefind search
- 🙅‍♂️ mkquartodocs plugin is not functional
  - prefer running quarto docs locally and copy generated md or html to sitebuilder

## amd64

jekyll 3.10.0
hugo v0.155.3-8a858213b73907e823e2be2b5640a0ce4c04d295+extended linux/amd64 BuildDate=2026-02-08T16:40:42Z VendorInfo=gohugoio
git version 2.39.5
go version go1.26.0 linux/amd64
mkdocs                                    1.6.1
mkdocs-autorefs                           1.4.4
mkdocs-get-deps                           0.2.0
mkdocs-git-authors-plugin                 0.10.0
mkdocs-git-committers-plugin-2            2.5.0
mkdocs-git-revision-date-localized-plugin 1.5.1
mkdocs-git-revision-date-plugin           0.3.2
mkdocs-glightbox                          0.5.2
mkdocs-macros-plugin                      1.5.0
mkdocs-material                           9.7.1
mkdocs-material-extensions                1.3.1
mkdocs-minify-plugin                      0.8.0
mkdocs-redirects                          1.2.2
mkdocs-rss-plugin                         1.17.9
mkdocstrings                              1.0.3
mkdocstrings-python                       2.0.2
mkdocstrings-shell                        1.0.4
mkquartodocs                              0.7.0
pagefind 1.5.0-beta.1
Ruby Sass 3.7.4

## arm64

jekyll 3.10.0
hugo v0.155.3-8a858213b73907e823e2be2b5640a0ce4c04d295+extended linux/arm64 BuildDate=2026-02-08T16:40:42Z VendorInfo=gohugoio
git version 2.39.5
go version go1.26.0 linux/arm64
mkdocs                                    1.6.1
mkdocs-autorefs                           1.4.4
mkdocs-get-deps                           0.2.0
mkdocs-git-authors-plugin                 0.10.0
mkdocs-git-committers-plugin-2            2.5.0
mkdocs-git-revision-date-localized-plugin 1.5.1
mkdocs-git-revision-date-plugin           0.3.2
mkdocs-glightbox                          0.5.2
mkdocs-macros-plugin                      1.5.0
mkdocs-material                           9.7.1
mkdocs-material-extensions                1.3.1
mkdocs-minify-plugin                      0.8.0
mkdocs-redirects                          1.2.2
mkdocs-rss-plugin                         1.17.9
mkdocstrings                              1.0.3
mkdocstrings-python                       2.0.2
mkdocstrings-shell                        1.0.4
mkquartodocs                              0.7.0
pagefind 1.5.0-beta.1
Ruby Sass 3.7.4

EOF

git push
```

### Update docker image

With buildx command and `--push` argument above, we already have uploaded images to docker hub, include `latest` alias.

*   Confirm using `docker images` that IMAGE ID of a built image, `sbamin/sitebuilder:1.5.x` matches with aliases created above. If all good, remove previous version of sitebuilder, `docker rmi sbamin/sitebuilder:1.5.*`

Besides updating Docker Hub, if you are updating image also to github packages, update respective aliases. 

* If using github container repo, this should work.

>NOTE: Since sitebuilder tag: 1.5.5, future updates will always be pushed to [docker hub](https://hub.docker.com/r/sbamin/sitebuilder) but occasionally to github repo.

```sh
## avoid echo raw password!
## echo $(<decrypt pwd>) | docker login ghcr.io -u USERNAME --password-stdin

docker push ghcr.io/sbamin/sitebuilder:1.5.6
docker push ghcr.io/sbamin/sitebuilder:latest
docker push ghcr.io/sbamin/sitebuilder:1.5.6_arm64
```

### Get singularity SIF image

If you prefer using [singularity/apptainer](https://docs.sylabs.io/guides/3.5/user-guide/singularity_and_docker.html) SIF image, run following command to get an updated SIF image.

```sh
## assuming running on linux/amd64 architecture.
singularity run docker://sbamin/sitebuilder:latest
## or a specific version
singularity run docker://sbamin/sitebuilder:1.5.6
```

Done!
