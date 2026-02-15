############################################################
# Dockerfile for website build using jekyll, hugo, or mkdocs
############################################################
## ruby version should be compliant with github-pages
## managed build nodes, https://pages.github.com/versions/ or
## Dockerfile at https://github.com/github/pages-gem
FROM ruby:3.3.7

## pull docker buildx platform arg
ARG TARGETPLATFORM

## NOTE: installing beta version of mkdocs-material with blog support.
LABEL version="1.5.9" \
	mode="sitebuilder-1.5.9" \
	author="Samirkumar Amin" \
	description="docker image to build jekyll, hugo or mkdocs supported website" \
	website="https://github.com/sbamin/sitebuilder" \
	LICENSE="MIT License, https://github.com/sbamin/sitebuilder/blob/master/LICENSE" \
	issues="https://github.com/sbamin/sitebuilder/issues"

## run apt-get non-interactive
## https://stackoverflow.com/a/56569081/1243763
ARG DEBIAN_FRONTEND=noninteractive

#### Configure locales, python3, git (via PPA) ####
## https://github.com/jekyll/jekyll/issues/4268
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        locales \
        python3 \
        python3-venv \
        python3-distutils \
        python3-launchpadlib \
        software-properties-common && \
    add-apt-repository ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends git && \
    dpkg-reconfigure --frontend noninteractive locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Set default locale
ENV LC_ALL="C.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"
ENV myhugo="0.155.3"
ENV mygo="1.26.0"
ENV mydartsass="1.97.3"
ENV mypagefind="v1.5.0-beta.1"

#### Python 3 venv ####
# Create and activate a Python virtual environment
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel

ENV PATH="/opt/venv/bin:$PATH"

#### Jekyll ####
## Copy Gemfile ##
## This may differ based on gems and plugins used
COPY Gemfile /tmp/

## jekyll setup
RUN mkdir -p /scratch && \
    mv /tmp/Gemfile /scratch/ && \
    cd /scratch && \
    bundle install && \
    mkdir -p /web

#### MkDocs, mkdocs-material, and plugins ####
## https://github.com/squidfunk/mkdocs-material
RUN pip3 install --no-cache-dir \
	singledispatch nltk six \
	markdown pygments fontawesome_markdown pymdown-extensions \
	"mkdocs-material[imaging,recommended,git]" \
	mkdocs mkdocs-material \
	mkdocs-git-revision-date-plugin \
	mkdocs-git-revision-date-localized-plugin \
	mkdocs-minify-plugin \
	mkdocs-redirects \
	mkdocs-macros-plugin \
	mike \
	mkdocs-git-authors-plugin \
	mkdocs-glightbox \
	mkdocstrings mkdocstrings-python mkdocstrings-shell \
	mkquartodocs && \
	git config --global --add safe.directory /web

## install latest hugo extended, including GO, dart-sass, and pagefind
## requires OS arch variable
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") ARCH="amd64"; ARCH2="x64"; ARCH3="x86_64" ;; \
        "linux/arm64") ARCH="arm64"; ARCH2="arm64"; ARCH3="aarch64" ;; \
        *) echo "Unsupported architecture: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    echo "Building for ARCH=$ARCH" && \
	wget -q https://github.com/gohugoio/hugo/releases/download/v${myhugo}/hugo_extended_${myhugo}_linux-${ARCH}.deb && \
	apt install ./hugo_extended_${myhugo}_linux-${ARCH}.deb -y && \
	rm -f hugo_extended_${myhugo}_linux-${ARCH}.deb && \
	wget -q https://go.dev/dl/go${mygo}.linux-${ARCH}.tar.gz && \
	tar -C /usr/local -xzf go${mygo}.linux-${ARCH}.tar.gz && \
	mkdir -p /opt/go/bin && \
	chmod 775 /opt/go && \
	chmod 775 /opt/go/bin && \
	wget -q https://github.com/sass/dart-sass/releases/download/${mydartsass}/dart-sass-${mydartsass}-linux-${ARCH2}-musl.tar.gz && \
	mkdir -p /opt/dart && \
	chmod 775 /opt/dart && \
	tar -C /opt/dart -xzf dart-sass-${mydartsass}-linux-${ARCH2}-musl.tar.gz && \
	mv -f /opt/dart/dart-sass /opt/dart/bin && \
	## install pagefind
	curl -sL https://github.com/Pagefind/pagefind/releases/download/${mypagefind}/pagefind-${mypagefind}-${ARCH3}-unknown-linux-musl.tar.gz | tar xz -C /usr/local/bin && \
	chmod 755 /usr/local/bin/pagefind && \
	apt-get clean && \
	rm -f go${mygo}.linux-${ARCH}.tar.gz && \
	rm -f dart-sass-${mydartsass}-linux-${ARCH2}-musl.tar.gz && \
	rm -rf /var/lib/apt/lists/*

ENV GOPATH="/opt/go"

## empty dir where user volume should be mounted
## to run jekyll/mkdocs/hugo related commands
WORKDIR /web

## for mkdocstrings, set an intended path to python modules
ENV PYTHONPATH="/web/api/py"

ENV PATH="/opt/venv/bin:/usr/local/bundle/bin:/usr/local/bundle/gems/bin:/usr/local/go/bin:/opt/go/bin:/opt/dart/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

#### expose ports for jekyll, mkdocs, and hugo serve command ####
EXPOSE 4000
EXPOSE 8000
EXPOSE 1313

ENTRYPOINT []
CMD []

## END ##
