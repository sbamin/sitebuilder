## sitebuilder

![GitHub Tag](https://img.shields.io/github/v/tag/sbamin/sitebuilder?label=sbamin%2Fsitebuilder) | [![Docker Image Version](https://img.shields.io/docker/v/sbamin/sitebuilder?arch=amd64)](https://hub.docker.com/r/sbamin/sitebuilder)

Docker image: [sbamin/sitebuilder](https://hub.docker.com/r/sbamin/sitebuilder)

>NOTE: Since sitebuilder tag: 1.5.5, future updates will always be pushed to [docker hub](https://hub.docker.com/r/sbamin/sitebuilder) but occasionally to github repo.

Docker image to build static websites managed via [Jekyll](https://jekyllrb.com), Hugo(https://gohugo.io) or [MkDocs](https://www.mkdocs.org) framework.

For Jekyll framework, your site's Gemfile should match version requirements given in [Gemfile](Gemfile). Also, avoid putting [Gemfile.lock](Gemfile.lock) in the build repository as it will be generated at the time of build.

For MkDocs, docker image is using [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) theme developed by [Martin Donath](https://github.com/squidfunk).

**NOTE:** docker image with a `latest` tag may have breaking changes and may not work with one or more of static site engines if your code is not compatible with the latest version. Please check [Release page](https://github.com/sbamin/sitebuilder/releases) for breaking changes, if any. If so, you may try using previous version of a docker image.

### Serve local for testing

>WARN: Only for testing purpose. Container by default will expose ports 4000, 8000, and 1313. Depending on firewall settings in the host machine, this may expose website contents to intranet or public at the exposed port(s). Make sure that firewall is secure enough and stop server immediately after testing.

```sh
## First go to root directory containing respective website repository.

## mkdocs, preview at http://0.0.0.0:4000
docker run -v "$(pwd):/web" --rm -P -p 127.0.0.1:4000:4000 sbamin/sitebuilder mkdocs serve -a 0.0.0.0:4000

## jekyll, preview at http://0.0.0.0:4000
## PS: For jekyll serve, --no-watch may be needed on apple silicon
## with an open issue with rb-notify gem.
docker run -v "$(pwd):/web" --rm -P -p 127.0.0.1:4000:4000 sbamin/sitebuilder jekyll serve --watch --host=0.0.0.0 -c _devconfig.yml -d _sitelocal

## hugo, preview at http://0.0.0.0:4000
docker run -v "$(pwd):/web" --rm -P -p 127.0.0.1:4000:4000 sbamin/sitebuilder hugo server --bind 0.0.0.0 --port 4000
```

### Build local

>Build website will be under **<root_directory>/site**.

```sh
## mkdocs
docker run -v "$(pwd):/web" --rm sbamin/sitebuilder mkdocs build --clean --site-dir site

## jekyll
docker run -v "$(pwd):/web" --rm sbamin/sitebuilder jekyll build -c _config.yml --destination site

## hugo
docker run -v "$(pwd):/web" sbamin/sitebuilder hugo --cleanDestinationDir --destination site
```

### Get singularity SIF image

If you prefer using [singularity](https://docs.sylabs.io/guides/3.5/user-guide/singularity_and_docker.html) SIF image, run following command to get an updated SIF image.

```sh
singularity run docker://sbamin/sitebuilder:latest
```

END

