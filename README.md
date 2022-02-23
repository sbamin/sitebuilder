## sitebuilder

Docker image: [sbamin/sitebuilder](https://hub.docker.com/r/sbamin/sitebuilder)

Docker image to build static websites managed via [Jekyll](https://jekyllrb.com), Hugo(https://gohugo.io) or [MkDocs](https://www.mkdocs.org) framework.

For Jekyll framework, your site's Gemfile should match version requirements given in [Gemfile](Gemfile). Also, avoid putting [Gemfile.lock](Gemfile.lock) in the build repository as it will be generated at the time of build.

For MkDocs, docker image is using [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) theme developed by [Martin Donath](https://github.com/squidfunk).

### Serve local for testing

>PS: Only for testing purpose. Container by default will expose ports 4000, 8000, and 1313. Depending on firewall settings in the host machine, this may expose website contents to intranet or public at the exposed port(s).  

>Access website at **127.0.0.1:4000** 

```sh
## First go to root directory containing respective website repository.

## mkdocs
docker run -v "$(pwd):/web" --rm -P -p 127.0.0.1:4000:8000 sbamin/sitebuilder mkdocs serve -a 0.0.0.0:8000

## jekyll
docker run -v "$(pwd):/web" --rm -P -p 127.0.0.1:4000:4000 sbamin/sitebuilder jekyll serve --watch --host=0.0.0.0 -c _devconfig.yml -d _sitelocal

## hugo
docker run -v "$(pwd):/web" --rm -P -p 127.0.0.1:4000:8000 sbamin/sitebuilder hugo server --bind 0.0.0.0 --port 8000
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

END

