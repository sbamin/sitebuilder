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

*   Define docker image tag, e.g., `1.5.5` typically a level up than [the current version](https://hub.docker.com/r/sbamin/sitebuilder/tags). You need to manually update several of commands below to reflect an updated tag.

*   Update `Dockerfile` as per your custom changes. At minimum, update LABEL version and mode to reflect an updated tag. You can also update `hugo extended` to the [current release](https://github.com/gohugoio/hugo/releases) by updating *myhugo* ENV variable in `Dockerfile`. Optionally, [update related go version](https://go.dev/doc/install) with *mygo* ENV variable.

*   If you need to update [jekyll](https://jekyllrb.com/) related gems, update `Gemfile` while ensuring gem [version requirements](https://pages.github.com/versions/) for [github-pages](https://github.com/github/pages-gem) gem.

*   If you need to update mkdocs-material theme, please make related changes to mkdocs installation in Dockerfile as per [author's instructions from mkdocs-material website](https://squidfunk.github.io/mkdocs-material/upgrade/).

*   Start building a docker image. You need to replace `sbamin/sitebuilder` with your respective [docker hub user id](https://hub.docker.com) and image name you like to rename. Read [manpage for docker build](https://docs.docker.com/engine/reference/commandline/build/).

```sh
## build amd64 version first
docker build --platform linux/amd64 -f Dockerfile -t sbamin/sitebuilder:1.5.5 .
```

>NOTE: If using docker on Mac M1/M2, you should add `--platform linux/amd64` given sitebuilder docker image is configured for amd64 and not arm64 architecture. To use arm64 architecture, you need to update `Dockerfile` to replace `amd64` packages with `arm64` ones, if available from a respective developer. [See relevant details here](https://stackoverflow.com/a/68004485/1243763).

*	Optional: To build arm64 docker image, use a separate Dockerfile that installs arm64 packages of hugo and go.

```sh
docker build --platform linux/arm64 -f Dockerfile_arm64 -t sbamin/sitebuilder:1.5.5_arm64 .
```

PS: Rest of steps are implied for amd64 image, and can be followed for arm64 image too with applicable changes to docker image name.

*   Once image is successfully built, copy `Gemfile.lock` back to host, so that we can update it with the most recent versions of gems.

```sh
## start container in an interactive session and mount local (host) directory
## to an empty location in the docker container.
docker run --platform linux/amd64 --rm -it -v "$(pwd)":/hostspace sbamin/sitebuilder:1.5.5 /bin/bash

## copy (overwrite) local Gemfile.lock with an updated version from 
## the container
cp /scratch/Gemfile.lock /hostspace/

## exit container
exit
```

*   Check installed or updated package versions

```sh
docker run --platform linux/amd64 --rm sbamin/sitebuilder:1.5.5 /bin/bash -c "jekyll --version && hugo version && git version && go version && pip list | grep mkdocs"

docker run --platform linux/arm64 --rm sbamin/sitebuilder:1.5.5_arm64 /bin/bash -c "jekyll --version && hugo version && git version && go version && pip list | grep mkdocs"
```

*   Commit and push those to github.

```sh
git add Dockerfile Dockerfile_arm64 Gemfile Gemfile.lock update_sitebuilder.md README.md

## write a multiline git commit message
## -s requires a valid gpg key for signing a message
git commit -s -F- <<EOF
Updated sitebuilder
v1.5.5

## amd64

jekyll 3.10.0
hugo v0.141.0-e7bd51698e5c3778a86003018702b1a7dcb9559a+extended linux/amd64 BuildDate=2025-01-16T13:11:18Z VendorInfo=gohugoio
git version 2.39.5
go version go1.23.5 linux/amd64
mkdocs                                    1.6.1
mkdocs-get-deps                           0.2.0
mkdocs-git-authors-plugin                 0.9.2
mkdocs-git-committers-plugin-2            2.4.1
mkdocs-git-revision-date-localized-plugin 1.3.0
mkdocs-git-revision-date-plugin           0.3.2
mkdocs-glightbox                          0.4.0
mkdocs-macros-plugin                      1.3.7
mkdocs-material                           9.5.50
mkdocs-material-extensions                1.3.1
mkdocs-minify-plugin                      0.8.0
mkdocs-redirects                          1.2.2
mkdocs-rss-plugin                         1.17.1

## arm64

jekyll 3.10.0
hugo v0.141.0-e7bd51698e5c3778a86003018702b1a7dcb9559a+extended linux/arm64 BuildDate=2025-01-16T13:11:18Z VendorInfo=gohugoio
git version 2.39.5
go version go1.23.5 linux/arm64
mkdocs                                    1.6.1
mkdocs-get-deps                           0.2.0
mkdocs-git-authors-plugin                 0.9.2
mkdocs-git-committers-plugin-2            2.4.1
mkdocs-git-revision-date-localized-plugin 1.3.0
mkdocs-git-revision-date-plugin           0.3.2
mkdocs-glightbox                          0.4.0
mkdocs-macros-plugin                      1.3.7
mkdocs-material                           9.5.50
mkdocs-material-extensions                1.3.1
mkdocs-minify-plugin                      0.8.0
mkdocs-redirects                          1.2.2
mkdocs-rss-plugin                         1.17.1

EOF

git push
```

### Update docker image

Upload your docker image to [docker hub](https://www.docker.com), [github packages](https://github.com/features/packages), or your preferred container hub.

*   Tag or alias updated image to `latest`. This will overwrite existing alias to `latest` which is typically an older image, e.g., 1.5.1

```sh
## unless beta version, remove older docker image tagged as latest, if any on local computer.
docker rmi sbamin/sitebuilder:latest
docker tag sbamin/sitebuilder:1.5.5 sbamin/sitebuilder:latest
```

*   Besides updating Docker Hub, if you are updating image also to github packages, update respective aliases.

```sh
## unless beta version, remove older versions
docker rmi ghcr.io/sbamin/sitebuilder:latest
docker tag sbamin/sitebuilder:1.5.5  ghcr.io/sbamin/sitebuilder:1.5.5
docker tag ghcr.io/sbamin/sitebuilder:1.5.5  ghcr.io/sbamin/sitebuilder:latest
```

*   Confirm using `docker images` that IMAGE ID of a built image, `sbamin/sitebuilder:1.5.x` matches with aliases created above. If all good, remove previous version of sitebuilder, `docker rmi sbamin/sitebuilder:1.5.4`

*   Before pushing images, worth doing a test build and preview run as per [README.md](README.md)

*   Push images to docker hub and/or github packages. For github container registry, see [this guide](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) on authentication.

```sh
docker push sbamin/sitebuilder:1.5.5
docker push sbamin/sitebuilder:latest
docker push sbamin/sitebuilder:1.5.5_arm64
```

* If using github container repo, this should work.

>NOTE: Since sitebuilder tag: 1.5.5, future updates will always be pushed to [docker hub](https://hub.docker.com/r/sbamin/sitebuilder) but occasionally to github repo.

```sh
## avoid echo raw password!
## echo $(<decrypt pwd>) | docker login ghcr.io -u USERNAME --password-stdin

docker push ghcr.io/sbamin/sitebuilder:1.5.5
docker push ghcr.io/sbamin/sitebuilder:latest
docker push ghcr.io/sbamin/sitebuilder:1.5.5_arm64
```

### Get singularity SIF image

If you prefer using [singularity](https://docs.sylabs.io/guides/3.5/user-guide/singularity_and_docker.html) SIF image, run following command to get an updated SIF image.

```sh
## assuming running on linux/amd64 architecture.
singularity run docker://sbamin/sitebuilder:latest
## or beta version
singularity run docker://sbamin/sitebuilder:1.5.5
```

Done!
