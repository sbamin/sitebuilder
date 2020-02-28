## sitebuilder

Docker image: [sbamin/sitebuilder:1.2.1](https://hub.docker.com/r/sbamin/sitebuilder)

Docker image to build static websites managed via either [jekyll](https://jekyllrb.com/) or [MkDocs](https://www.mkdocs.org) framework.

For Jekyll, using jekyll 3.8.5, github-pages 201, and other gems. View [Gemfile](Gemfile) for required Gemfile under jekyll root dir, and [Gemfile.lock.bkup](Gemfile.lock.bkup) for specific versions of gems. Example sites using this framework are: [sbamin.com](https://sbamin.com) and [verhaaklab.com](https://verhaaklab.com).

For MkDocs, using MkDocs v1.1 and plugins required to run a [variant of mkdocs-material](https://github.com/sbamin/theme-mkdocs-material/) theme by [Martin Donath](https://github.com/squidfunk). Example site using this framework is: [canineglioma.verhaaklab.com](https://canineglioma.verhaaklab.com).

### Serve local for testing

MkDocs framework in the docker image is optimized for a [variant of mkdocs-material](https://github.com/sbamin/theme-mkdocs-material/) and may not work with other themes.

>PS: Only for testing purpose. Container by default will expose port 4000 and 8000. Depending on firewall settings in the host machine, this may expose website contents to intranet or public at the exposed port(s).

```sh
cd /scratch/sandbox
git clone <website_sourcecode>

## jekyll framework
docker run -v "/scratch/sandbox/website_sourcecode:/web" --rm -P -p 127.0.0.1:4000:4000 sbamin/sitebuilder:1.2.1 jekyll serve -c _devconfig.yml -d _sitelocal

## mkdocs framework
docker run -v "/scratch/sandbox/website_sourcecode:/web" --rm -P -p 127.0.0.1:8000:8000 sbamin/sitebuilder:1.2.1 mkdocs -q serve -a 0.0.0.0:8000
```

### Build local

>To build static website contents under `site` directory:

```sh
cd /scratch/sandbox
git clone <website_sourcecode> && \
## prefer clean build directory
rm -rf site && \
mkdir -p site

## jekyll framework
docker run -v "/scratch/sandbox/website_sourcecode:/web" --rm sbamin/sitebuilder:1.2.1 jekyll build -c _config.yml -d site

## mkdocs framework
docker run -v "/scratch/sandbox/website_sourcecode:/web" --rm sbamin/sitebuilder:1.2.1 mkdocs build --clean -d site
```

END

