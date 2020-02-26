############################################################
# Dockerfile to build jekyll run website
############################################################
## ruby version should be compliant with netlify and github-pages
## managed build nodes
FROM ruby:2.6.2

## For questions, visit https:
MAINTAINER "Samir B. Amin" <tweet:sbamin; sbamin.com/contact>

## Copy Gemfile
## This may differ based on gems and plugins used
COPY Gemfile /tmp/

RUN mkdir -p /scratch && \
    mv /tmp/Gemfile /scratch/ && \
    cd /scratch && \
    bundle install && \
    mkdir -p /web

## Install program to configure locales
## https://github.com/jekyll/jekyll/issues/4268
RUN apt-get update && \
    apt-get install -y locales && \
    dpkg-reconfigure --frontend noninteractive locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# Set default locale
ENV LC_ALL "C.UTF-8"
ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"

## empty dir where user volume should be mounted
## to run jekyll related commands
WORKDIR /web

ENV PATH /usr/local/bundle/bin:/usr/local/bundle/gems/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENTRYPOINT []
CMD []

## END ##
