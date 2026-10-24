## sitebuilder

![GitHub Tag](https://img.shields.io/github/v/tag/sbamin/sitebuilder?label=sbamin%2Fsitebuilder) | [![Docker Image Version](https://img.shields.io/docker/v/sbamin/sitebuilder?arch=amd64)](https://hub.docker.com/r/sbamin/sitebuilder)

Docker image: [sbamin/sitebuilder](https://hub.docker.com/r/sbamin/sitebuilder)

>NOTE: Since sitebuilder tag: 1.5.5, future updates will always be pushed to [docker hub](https://hub.docker.com/r/sbamin/sitebuilder) but occasionally to github repo.

Docker image to build static websites managed via [Jekyll](https://jekyllrb.com), [Hugo](https://gohugo.io) or [MkDocs](https://www.mkdocs.org) framework. The image also has [dart-sass](https://sass-lang.com/dart-sass/) (for Hugo) and [pagefind](https://pagefind.app) (static search). Images are available for linux/amd64 and linux/arm64 (Apple silicon).

For Jekyll framework, your site's Gemfile should match version requirements given in [Gemfile](Gemfile). Also, avoid putting [Gemfile.lock](Gemfile.lock) in the build repository as it will be generated at the time of build. Sites that use the `github-pages` gem need `repository: <user>/<repo>` in `_config.yml` (or `-e PAGES_REPO_NWO=<user>/<repo>`), else the build stops with "No repo name found".

For MkDocs, docker image is using [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) theme developed by [Martin Donath](https://github.com/squidfunk).

**NOTE:** docker image with a `latest` tag may have breaking changes and may not work with one or more of static site engines if your code is not compatible with the latest version. Please check [Release page](https://github.com/sbamin/sitebuilder/releases) for breaking changes, if any. If so, you may try using previous version of a docker image, e.g., `sbamin/sitebuilder:1.5.10`.

**NOTE:** Since sitebuilder 1.5.10, the container runs as a non-root user, `sitebuilder` (uid 1000, gid 1000). On a Linux host where your uid is not 1000, add `--user "$(id -u):$(id -g)" -e HOME=/tmp` to the `docker run` commands below, so that files in `/web` stay writable by you. On macOS, Docker Desktop must share the site directory (Settings > Resources > File sharing), else `docker run` fails with "mounts denied".

Run `docker run --rm sbamin/sitebuilder sitebuilder-versions` to see tool versions in the image.

### Serve local for testing

>WARN: Only for testing purpose. Commands below publish port 4000 only on the local host (`127.0.0.1`). Do not add `-P` or `-p 4000:4000` without `127.0.0.1`: these publish ports on all network interfaces and may expose website contents to intranet or public, depending on firewall settings. Stop server immediately after testing.

```sh
## First go to root directory containing respective website repository.
## Preview at http://127.0.0.1:4000 and stop with Ctrl+C.

## mkdocs
docker run -it -v "$(pwd):/web" --rm -p 127.0.0.1:4000:4000 sbamin/sitebuilder mkdocs serve -a 0.0.0.0:4000

## jekyll
## add other options as required, e.g., -c _config.yml,_devconfig.yml -d _sitelocal
## if file changes are not detected, add --force_polling
docker run -it -v "$(pwd):/web" --rm -p 127.0.0.1:4000:4000 sbamin/sitebuilder jekyll serve --watch --host 0.0.0.0 --port 4000

## hugo
docker run -it -v "$(pwd):/web" --rm -p 127.0.0.1:4000:4000 sbamin/sitebuilder hugo server --bind 0.0.0.0 --port 4000
```

### Build local

>Build website will be under **<root_directory>/site**.

```sh
## mkdocs
docker run -v "$(pwd):/web" --rm sbamin/sitebuilder mkdocs build --clean --site-dir site

## jekyll
docker run -v "$(pwd):/web" --rm sbamin/sitebuilder jekyll build -c _config.yml --destination site

## hugo
docker run -v "$(pwd):/web" --rm sbamin/sitebuilder hugo --cleanDestinationDir --destination site

## optional: add pagefind search index to a built site (writes site/pagefind)
docker run -v "$(pwd):/web" --rm sbamin/sitebuilder pagefind --site site
```

### Get singularity SIF image

If you prefer using [singularity/apptainer](https://docs.sylabs.io/guides/latest/user-guide/singularity_and_docker.html), get a SIF image and run commands from the site root directory. Singularity runs as your own user and mounts the current directory, so `--user` is not needed.

```sh
## writes sitebuilder_1.5.11.sif in the current directory
singularity pull docker://sbamin/sitebuilder:1.5.11

## e.g., build mkdocs site
singularity exec sitebuilder_1.5.11.sif mkdocs build --clean --site-dir site
```

END

