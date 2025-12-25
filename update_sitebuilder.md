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

*   Define docker image tag, e.g., `1.5.6` typically a level up than [the current version](https://hub.docker.com/r/sbamin/sitebuilder/tags). You need to manually update several of commands below to reflect an updated tag.

*   Update `Dockerfile` as per your custom changes. At minimum, update LABEL version and mode to reflect an updated tag. You can also update `hugo extended` to the [current release](https://github.com/gohugoio/hugo/releases) by updating *myhugo* ENV variable in `Dockerfile`. Optionally, [update related go version](https://go.dev/dl/) with *mygo* ENV variable.

*   If you need to update [jekyll](https://jekyllrb.com/) related gems, update `Gemfile` while ensuring gem [version requirements](https://pages.github.com/versions/) for [github-pages](https://github.com/github/pages-gem) gem.

*   If you need to update mkdocs-material theme, please make related changes to mkdocs installation in Dockerfile as per [author's instructions from mkdocs-material website](https://squidfunk.github.io/mkdocs-material/upgrade/).

### build and push multi-arch images

Here, I am using `docker buildx build` from [Docker Desktop v4.22.0 on mac os 15.3 M2](https://www.docker.com/products/docker-desktop/) to build both, amd64 and arm64/v8 images. [See this guide for multi-arch builds](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/).

*   Start building a docker image. You need to replace `sbamin/sitebuilder` with your respective [docker hub user id](https://hub.docker.com) and image name you like to rename.

```sh
## platform variable will be parsed in Dockerfile as TARGETPLATFORM
## to download platform specific hugo and go packages

## requires login to docker hub from Docker Desktop app
## replace --push with --load to load arch specific image locally
docker buildx build \
	--platform linux/arm64/v8,linux/amd64 \
	--tag sbamin/sitebuilder:1.5.7 \
	--tag sbamin/sitebuilder:latest \
	--push \
	--file Dockerfile .
```

### update Gemfile.lock

*   Once image is successfully built, copy `Gemfile.lock` back to host, so that we can update it with the most recent versions of gems.

```sh
## start container in an interactive session and mount local (host) directory
## to an empty location in the docker container.
docker run --rm -it -v "$(pwd)":/hostspace sbamin/sitebuilder:1.5.7 /bin/bash

## copy (overwrite) local Gemfile.lock with an updated version from 
## the container
cp /scratch/Gemfile.lock /hostspace/

## exit container
exit
```

*   Check installed or updated package versions

```sh
## we already pushed both, updated version and latest tag to docker
docker run --rm sbamin/sitebuilder /bin/bash -c "jekyll --version && hugo version && git version && go version && pip list | grep mkdocs"

## for non-os compliant OS, e.g., amd64 if using macos M2
docker run --platform linux/amd64 --rm sbamin/sitebuilder /bin/bash -c "jekyll --version && hugo version && git version && go version && pip list | grep mkdocs"
```

### Update github releases

```sh
git add Dockerfile Dockerfile_arm64 Gemfile Gemfile.lock update_sitebuilder.md README.md

## write a multiline git commit message
## -s requires a valid gpg key for signing a message
git commit -s -F- <<EOF
Updated sitebuilder
v1.5.7

## amd64

jekyll 3.10.0
hugo v0.145.0-666444f0a52132f9fec9f71cf25b441cc6a4f355+extended linux/amd64 BuildDate=2025-02-26T15:41:25Z VendorInfo=gohugoio
git version 2.39.5
go version go1.24.1 linux/amd64
mkdocs                                    1.6.1
mkdocs-autorefs                           1.4.1
mkdocs-get-deps                           0.2.0
mkdocs-git-authors-plugin                 0.9.4
mkdocs-git-committers-plugin-2            2.5.0
mkdocs-git-revision-date-localized-plugin 1.4.5
mkdocs-git-revision-date-plugin           0.3.2
mkdocs-glightbox                          0.4.0
mkdocs-macros-plugin                      1.3.7
mkdocs-material                           9.6.9
mkdocs-material-extensions                1.3.1
mkdocs-minify-plugin                      0.8.0
mkdocs-redirects                          1.2.2
mkdocs-rss-plugin                         1.17.1
mkdocstrings                              0.29.0
mkdocstrings-python                       1.16.8
mkdocstrings-shell                        1.0.1

## arm64

jekyll 3.10.0
hugo v0.145.0-666444f0a52132f9fec9f71cf25b441cc6a4f355+extended linux/arm64 BuildDate=2025-02-26T15:41:25Z VendorInfo=gohugoio
git version 2.39.5
go version go1.24.1 linux/arm64
mkdocs                                    1.6.1
mkdocs-autorefs                           1.4.1
mkdocs-get-deps                           0.2.0
mkdocs-git-authors-plugin                 0.9.4
mkdocs-git-committers-plugin-2            2.5.0
mkdocs-git-revision-date-localized-plugin 1.4.5
mkdocs-git-revision-date-plugin           0.3.2
mkdocs-glightbox                          0.4.0
mkdocs-macros-plugin                      1.3.7
mkdocs-material                           9.6.9
mkdocs-material-extensions                1.3.1
mkdocs-minify-plugin                      0.8.0
mkdocs-redirects                          1.2.2
mkdocs-rss-plugin                         1.17.1
mkdocstrings                              0.29.0
mkdocstrings-python                       1.16.8
mkdocstrings-shell                        1.0.1

EOF

git push
```

### Update docker image

With buildx command and `--push` argument above, we already have uploaded images to docker hub, include `latest` alias.

*   Confirm using `docker images` that IMAGE ID of a built image, `sbamin/sitebuilder:1.5.x` matches with aliases created above. If all good, remove previous version of sitebuilder, `docker rmi sbamin/sitebuilder:1.5.4`

Besides updating Docker Hub, if you are updating image also to github packages, update respective aliases. **I have stopped updating github container repo past v[1.5.6](https://github.com/sbamin/sitebuilder/releases)**

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
