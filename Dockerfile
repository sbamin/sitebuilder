############################################################
# Dockerfile to build jekyll run website
############################################################
## ruby version should be compliant with netlify and github-pages
## managed build nodes
FROM ruby:2.6.2

## For questions, visit https:
MAINTAINER "Samir B. Amin" <tweet:sbamin; sbamin.com/contact>

## run apt-get non-interactive
## https://stackoverflow.com/a/56569081/1243763
ARG DEBIAN_FRONTEND=noninteractive

#### Configure locales ####
## https://github.com/jekyll/jekyll/issues/4268
RUN apt-get update && \
    apt-get install -y locales && \
    dpkg-reconfigure --frontend noninteractive locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

## Set default locale
ENV LC_ALL="C.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

#### Jekyll ####
## Copy Gemfile ##
## This may differ based on gems and plugins used
COPY Gemfile /tmp/

RUN mkdir -p /scratch && \
    mv /tmp/Gemfile /scratch/ && \
    cd /scratch && \
    bundle install && \
    mkdir -p /web

#### MkDocs and theme-mkdocs-material ####
## https://github.com/sbamin/theme-mkdocs-material/
RUN apt-get update && \
	apt-get install -y python3-pip && \
	python3 -m pip install --upgrade pip && \
	pip3 install --upgrade singledispatch nltk six && \
	pip3 install mkdocs mkdocs-material && \
	## force update packages if failed earlier
	pip3 install --upgrade singledispatch nltk six && \
	pip3 install markdown pygments fontawesome_markdown pymdown-extensions && \
	pip3 install mkdocs-git-revision-date-plugin mkdocs-git-revision-date-localized-plugin mkdocs-minify-plugin && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

## empty dir where user volume should be mounted
## to run jekyll related commands
WORKDIR /web

ENV PATH /usr/local/bundle/bin:/usr/local/bundle/gems/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#### expose ports for jekyll and mkdocs serve command ####
EXPOSE 4000
EXPOSE 8000

ENTRYPOINT []
CMD []

## END ##
