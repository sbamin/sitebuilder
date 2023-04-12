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

*   Define docker image tag, e.g., `1.5.1` typically a level up than [the current version](https://hub.docker.com/r/sbamin/sitebuilder/tags). You need to manually update several of commands below to reflect an updated tag.

*   Update `Dockerfile` as per your custom changes. At minimum, update LABEL version and mode to reflect an updated tag. You can also update `hugo extended` to the [current release](https://github.com/gohugoio/hugo/releases) by updating respective occurrences of `hugo_extended_0.111.3_linux-amd64.deb` in `Dockerfile`.

*   If you need to update [jekyll](https://jekyllrb.com/) related gems, update `Gemfile` while ensuring gem [version requirements](https://pages.github.com/versions/) for [github-pages](https://github.com/github/pages-gem) gem.

*   If you need to update mkdocs-material theme, please make related changes to mkdocs installation in Dockerfile as per [author's instructions from mkdocs-material website](https://squidfunk.github.io/mkdocs-material/upgrade/).

*   Start building a docker image. You need to replace `foo/sitebuilder` with your respective [docker hub user id](https://hub.docker.com) and image name you like to rename. Read [manpage for docker build](https://docs.docker.com/engine/reference/commandline/build/).

```sh
docker build -t foo/sitebuilder:1.5.1 .
```

*   Once image is successfully built, copy `Gemfile.lock` back to host, so that we can update it with the most recent versions of gems.

```sh
## start container in an interactive session and mount local (host) directory
## to an empty location in the docker container.
docker run --rm -it -v "$(pwd)":/hostspace foo/sitebuilder:1.5.1 /bin/bash

## copy (overwrite) local Gemfile.lock with an updated version from 
## the container
cp /scratch/Gemfile.lock /hostspace/

## exit container
exit
```

*   Check installed or updated package versions

```sh
docker run --rm sbamin/sitebuilder:1.5.1 /bin/bash -c "jekyll --version && hugo version && git version && go version && pip list | grep mkdocs"
```

*   Commit and push those to github.

```sh
git add Dockerfile Gemfile.lock update_sitebuilder.md

## write a multiline git commit message
## -s requires a valid gpg key for signing a message
git commit -s -F- <<EOF
Updated sitebuilder

* jekyll 3.9.3
* hugo v0.111.3-5d4eb5154e1fed125ca8e9b5a0315c4180dab192+extended linux/amd64 BuildDate=2023-03-12T11:40:50Z VendorInfo=gohugoio
* git version 2.30.2
* go version go1.19.5 linux/amd64
* mkdocs                                    1.4.2
* mkdocs-git-authors-plugin                 0.7.0
* mkdocs-git-revision-date-localized-plugin 1.2.0
* mkdocs-git-revision-date-plugin           0.3.2
* mkdocs-macros-plugin                      0.7.0
* mkdocs-material                           9.1.6
* mkdocs-material-extensions                1.1.1
* mkdocs-minify-plugin                      0.6.4
* mkdocs-redirects                          1.2.0

EOF

git push
```

### Update docker image

Upload your docker image to [docker hub](https://www.docker.com), [github packages](https://github.com/features/packages), or your preferred container hub.

*   Tag or alias updated image to `latest`. This will overwrite existing alias to `latest` which is typically an older image, e.g., 1.5.1

```sh
## remove older docker image tagged as latest, if any on local computer.
docker rmi sbamin/sitebuilder:latest
docker tag sbamin/sitebuilder:1.5.1 sbamin/sitebuilder:latest
```

*   Besides updating Docker Hub, if you are updating image also to github packages, update respective aliases.

```sh
docker rmi ghcr.io/sbamin/sitebuilder:latest
docker rmi ghcr.io/sbamin/sitebuilder:1.5.0
docker tag sbamin/sitebuilder:1.5.1  ghcr.io/sbamin/sitebuilder:1.5.1
docker tag sbamin/sitebuilder:1.5.1  ghcr.io/sbamin/sitebuilder:latest
```

*   Confirm using `docker images` that IMAGE ID of a built image, `sbamin/sitebuilder:1.5.1` matches with aliases created above. If all good, remove previous version of sitebuilder, `docker rmi sbamin/sitebuilder:1.5.0`

*   Before pushing images, worth doing a test build and preview run as per [README.md](README.md)

*   Push images to docker hub and/or github packages. For github container registry, see [this guide](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) on authentication.

```sh
docker push sbamin/sitebuilder:1.5.1
docker push sbamin/sitebuilder:latest

## avoid echo raw password!
## echo $(<decrypt pwd>) | docker login ghcr.io -u USERNAME --password-stdin

docker push ghcr.io/sbamin/sitebuilder:1.5.1
docker push ghcr.io/sbamin/sitebuilder:latest
```

### Get singularity SIF image

If you prefer using [singularity](https://docs.sylabs.io/guides/3.5/user-guide/singularity_and_docker.html) SIF image, run following command to get an updated SIF image.

```sh
singularity run docker://sbamin/sitebuilder:latest
```

Done!
