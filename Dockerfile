############################################################
# Dockerfile for website build using jekyll, hugo, or mkdocs
############################################################
## ruby version should be compliant with netlify and github-pages
## managed build nodes, https://pages.github.com/versions/
FROM ruby:3.3.7

## pull docker buildx platform arg
ARG TARGETPLATFORM

## NOTE: installing beta version of mkdocs-material with blog support.
LABEL version="1.5.7" \
	mode="sitebuilder-1.5.7" \
	author="Samirkumar Amin; tweet:sbamin; sbamin.com/contact" \
	description="docker image to build jekyll, hugo or mkdocs supported website" \
	website="https://github.com/sbamin/sitebuilder" \
	LICENSE="MIT License, https://github.com/sbamin/sitebuilder/blob/master/LICENSE" \
	issues="https://github.com/sbamin/sitebuilder/issues"

## run apt-get non-interactive
## https://stackoverflow.com/a/56569081/1243763
ARG DEBIAN_FRONTEND=noninteractive

#### Configure locales ####
## https://github.com/jekyll/jekyll/issues/4268
RUN apt-get update && \
    apt-get install -y locales python3 python3-venv python3-distutils && \
    apt-get install -y software-properties-common && \
    dpkg-reconfigure --frontend noninteractive locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    apt-get clean

## Set default locale
ENV LC_ALL="C.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"
ENV myhugo="0.145.0"
ENV mygo="1.24.1"

#### Python 3 venv ####
# Create and activate a Python virtual environment
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel

ENV PATH="/opt/venv/bin:$PATH"

#### Jekyll ####
## Copy Gemfile ##
## This may differ based on gems and plugins used
COPY Gemfile /tmp/

RUN mkdir -p /scratch && \
    mv /tmp/Gemfile /scratch/ && \
    cd /scratch && \
    bundle install && \
    mkdir -p /web

#### git ####
RUN apt-get install -y python3-launchpadlib && \
	add-apt-repository ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y python3-launchpadlib git && \
    git --version

#### Hugo, MkDocs, and theme-mkdocs-material ####
## https://github.com/squidfunk/mkdocs-material
## issue with Hash Sum mismatch
RUN	rm -rf /var/lib/apt/lists/partial && \
	apt-get update -o Acquire::CompressionTypes::Order::=gz && \
	pip3 install --upgrade singledispatch nltk six && \
	## force update packages if failed earlier
	pip3 install --upgrade singledispatch nltk six && \
	pip3 install markdown pygments fontawesome_markdown pymdown-extensions && \
	pip3 install "mkdocs-material[imaging,recommended,git]" && \
	pip3 install mkdocs mkdocs-material mkdocs-git-revision-date-plugin  mkdocs-git-revision-date-localized-plugin mkdocs-minify-plugin mkdocs-redirects pymdown-extensions mkdocs-macros-plugin mike mkdocs-git-authors-plugin mkdocs-glightbox && \
	## force update mkdocs env
	pip3 install --upgrade "mkdocs-material[imaging,recommended,git]" && \
	pip3 install --upgrade markdown pygments fontawesome_markdown pymdown-extensions && \
	pip3 install --upgrade mkdocs mkdocs-material mkdocs-git-revision-date-plugin  mkdocs-git-revision-date-localized-plugin mkdocs-minify-plugin mkdocs-redirects pymdown-extensions mkdocs-macros-plugin mike mkdocs-git-authors-plugin mkdocs-glightbox mkdocstrings mkdocstrings-python mkdocstrings-shell && \
	git config --global --add safe.directory /web

## install latest hugo extended, including GO
## requires OS arch variable
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") ARCH="amd64" ;; \
        "linux/arm64") ARCH="arm64" ;; \
        *) echo "Unsupported architecture: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    echo "Building for ARCH=$ARCH" && \
	wget https://github.com/gohugoio/hugo/releases/download/v${myhugo}/hugo_extended_${myhugo}_linux-${ARCH}.deb && \
	apt install ./hugo_extended_${myhugo}_linux-${ARCH}.deb -y && \
	rm -f hugo_extended_${myhugo}_linux-${ARCH}.deb && \
	wget https://go.dev/dl/go${mygo}.linux-${ARCH}.tar.gz && \
	tar -C /usr/local -xvzf go${mygo}.linux-${ARCH}.tar.gz && \
	mkdir -p /opt/go/bin && \
	chmod 775 /opt/go && \
	chmod 775 /opt/go/bin && \
	apt-get clean && \
	rm -f go${mygo}.linux-${ARCH}.tar.gz && \
	rm -rf /var/lib/apt/lists/*

ENV GOPATH="/opt/go"

## empty dir where user volume should be mounted
## to run jekyll/mkdocs/hugo related commands
WORKDIR /web

## for mkdocstrings, set an intended path to python modules
ENV PYTHONPATH="/web/api/py"

ENV PATH="/opt/venv/bin:/usr/local/bundle/bin:/usr/local/bundle/gems/bin:/usr/local/go/bin:/opt/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

#### expose ports for jekyll, mkdocs, and hugo serve command ####
EXPOSE 4000
EXPOSE 8000
EXPOSE 1313

ENTRYPOINT []
CMD []

## END ##
