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

*   Define docker image tag, e.g., `1.5.0` typically a level up than [the current version](https://hub.docker.com/r/sbamin/sitebuilder/tags). You need to manually update several of commands below to reflect an updated tag.

*   Update `Dockerfile` as per your custom changes. At minimum, update LABEL version and mode to reflect an updated tag. You can also update `hugo extended` to the [current release](https://github.com/gohugoio/hugo/releases) by updating respective occurrences of `hugo_extended_0.105.0_linux-arm64.deb` in `Dockerfile`.

*   If you need to update [jekyll](https://jekyllrb.com/) related gems, update `Gemfile` while ensuring gem [version requirements](https://pages.github.com/versions/) for [github-pages](https://github.com/github/pages-gem) gem.

*   If you need to update mkdocs-material theme, please make related changes to mkdocs installation in Dockerfile as per [author's instructions from mkdocs-material website](https://squidfunk.github.io/mkdocs-material/upgrade/).

*   Start building a docker image. You need to replace `foo/sitebuilder` with your respective [docker hub user id](https://hub.docker.com) and image name you like to rename. Read [manpage for docker build](https://docs.docker.com/engine/reference/commandline/build/).

```sh
docker build -t foo/sitebuilder:1.5.0 .
```

*   Once image is successfully built, copy `Gemfile.lock` back to host, so that we can update it with the most recent versions of gems.

```sh
## start container in an interactive session and mount local (host) directory
## to an empty location in the docker container.
docker run --rm -it -v "$(pwd)":/hostspace foo/sitebuilder:1.5.0 /bin/bash

## copy (overwrite) local Gemfile.lock with an updated version from 
## the container
cp /scratch/Gemfile.lock /hostspace/

## exit container
exit
```

*   Check updated files on the host within the sitebuilder repo.

```sh
git status
```

*   Check installed or updated package versions

```sh
docker run --rm foo/sitebuilder:1.5.0 /bin/bash -c "jekyll --version && hugo version && git version && go version && pip list | grep mkdocs"
```

*   Commit and push those to github.

```sh
git add Dockerfile Gemfile.lock update_sitebuilder.md

## write a multiline git commit message
## -s requires a valid gpg key for signing a message
git commit -s -F- <<EOF
Updated sitebuilder

* jekyll 3.9.2 with github-pages 227
* hugo v0.110.0 extended with go 1.19.5 and git 2.30.2
* mkdocs 1.4.2 with mkdocs-material 9.0.6
EOF

git push
```

### Update docker image

Upload your docker image to [docker hub](https://www.docker.com), [github packages](https://github.com/features/packages), or your preferred container hub.

*   Tag or alias updated image to `latest`. This will overwrite existing alias to `latest` which is typically an older image, e.g., 1.5.0

```sh
## remove older docker image tagged as latest, if any on local computer.
docker rmi foo/sitebuilder:latest
docker tag foo/sitebuilder:1.5.0 foo/sitebuilder:latest
```

*   Besides updating Docker Hub, if you are updating image also to github packages, update respective aliases.

```sh
docker rmi ghcr.io/foo/sitebuilder:latest
docker rmi ghcr.io/foo/sitebuilder:1.4.5
docker tag foo/sitebuilder:1.5.0  ghcr.io/foo/sitebuilder:1.5.0
docker tag foo/sitebuilder:1.5.0  ghcr.io/foo/sitebuilder:latest
```

*   Confirm using `docker images` that IMAGE ID of a built image, `foo/sitebuilder:1.5.0` matches with aliases created above. If all good, remove previous version of sitebuilder, `docker rmi foo/sitebuilder:1.4.5`

*   Before pushing images, worth doing a test build and preview run as per [README.md](README.md)

*   Push images to docker hub and/or github packages. For github container registry, see [this guide](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) on authentication.

```sh
docker push foo/sitebuilder:1.5.0
docker push foo/sitebuilder:latest

## avoid echo raw password!
## echo $(<decrypt pwd>) | docker login ghcr.io -u USERNAME --password-stdin

docker push ghcr.io/foo/sitebuilder:1.5.0
docker push ghcr.io/foo/sitebuilder:latest
```

### Get singularity SIF image

If you prefer using [singularity](https://docs.sylabs.io/guides/3.5/user-guide/singularity_and_docker.html) SIF image, run following command to get an updated SIF image.

```sh
singularity run docker://sbamin/sitebuilder:latest
```

Done!
