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

*   Define docker image tag, e.g., `1.4.3` typically a level up than [the current version](https://hub.docker.com/r/sbamin/sitebuilder/tags). You need to manually update several of commands below to reflect an updated tag.

*   Update `Dockerfile` as per your custom changes. At minimum, update LABEL version and mode to reflect an updated tag. You can also update `hugo extended` to the [current release](https://github.com/gohugoio/hugo/releases) by updating respective occurrences of `hugo_extended_0.101.0_Linux-64bit.deb` in `Dockerfile`.

*   If you need to update [jekyll](https://jekyllrb.com/) related gems, update `Gemfile` while ensuring gem [version requirements](https://pages.github.com/versions/) for [github-pages](https://github.com/github/pages-gem) gem.

*   Start building a docker image. You need to replace `foo/sitebuilder` with your respective [docker hub user id](https://hub.docker.com) and image name you like to rename. Read [manpage for docker build](https://docs.docker.com/engine/reference/commandline/build/).

```sh
docker build -t foo/sitebuilder:1.4.3 .
```

*   Once image is successfully built, copy `Gemfile.lock` back to host, so that we can update it with the most recent versions of gems.

```sh
## start container in an interactive session and mount local (host) directory
## to an empty location in the docker container.
docker run -it -v "$(pwd)":/hostspace foo/sitebuilder:1.4.3 /bin/bash

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
docker run --rm foo/sitebuilder:1.4.3 /bin/bash -c "jekyll --version"
docker run --rm foo/sitebuilder:1.4.3 /bin/bash -c "hugo version"
docker run --rm foo/sitebuilder:1.4.3 /bin/bash -c "pip list | grep mkdocs"
```

*   Commit and push those to github.

```sh
git add Dockerfile Gemfile Gemfile.lock

## write a multiline git commit message
## -s requires a valid gpg key for signing a message
git commit -s -F- <<EOF
Updated sitebuilder

jekyll 3.9.2
hugo 0.101.0 extended
mkdocs 1.3.0 with mkdocs-material 8.3.6
EOF

git push
```

### Update docker image

Upload your docker image to [docker hub](https://www.docker.com), [github packages](https://github.com/features/packages), or your preferred container hub.

*   Tag or alias updated image to `latest`. This will overwrite existing alias to `latest` which is typically an older image, e.g., 1.4.1

```sh
docker tag foo/sitebuilder:1.4.3 foo/sitebuilder:latest
```

*   Besides updating Docker Hub, if you are updating image also to github packages, update respective aliases.

```sh
docker tag foo/sitebuilder:1.4.3  ghcr.io/foo/sitebuilder:1.4.3
docker tag foo/sitebuilder:1.4.3  ghcr.io/foo/sitebuilder:latest
```

*   Confirm using `docker images` that IMAGE ID of a built image, `foo/sitebuilder:1.4.3` matches with aliases created above.

*   Push images to docker hub and/or github packages. For github container registry, see [this guide](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) on authentication.

```sh
docker push foo/sitebuilder:1.4.3
docker push foo/sitebuilder:latest

docker push ghcr.io/foo/sitebuilder:1.4.3
docker push ghcr.io/foo/sitebuilder:latest
```

### Get singularity SIF image

If you prefer using [singularity](https://docs.sylabs.io/guides/3.5/user-guide/singularity_and_docker.html) SIF image, run following command to get an updated SIF image.

```sh
singularity run docker://sbamin/sitebuilder:latest
```
Done!