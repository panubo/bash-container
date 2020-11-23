# Bash Container

[![CircleCI](https://circleci.com/gh/panubo/bash-container.svg?style=svg)](https://circleci.com/gh/panubo/bash-container)
[![Status](https://img.shields.io/badge/status-BETA-yellow.svg)]()

Common container Bash functions. All functions are tested and checked against [ShellCheck](https://github.com/koalaman/shellcheck).

## Install

The Panubo functions require bash, curl and coreutils, this takes about 10M of space.

### Debian

```
RUN set -x \
  && BASHCONTAINER_VERSION=0.6.0 \
  && if ! command -v wget > /dev/null; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && if ! command -v gpg > /dev/null; then \
      fetchDeps="${fetchDeps} gnupg dirmngr"; \
     fi \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz.asc \
  && GPG_KEYS="E51A4070A3FFBD68C65DDB9D8BECEF8DFFCC60DD" \
  && ( gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$GPG_KEYS" ) \
  && gpg --batch --verify panubo-functions.tar.gz.asc panubo-functions.tar.gz  \
  && tar -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;
```

### Alpine

```
RUN set -x \
  && BASHCONTAINER_VERSION=0.6.0 \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && if ! command -v gpg > /dev/null; then \
      fetchDeps="${fetchDeps} gnupg"; \
     fi \
  && apk add --no-cache ca-certificates bash curl coreutils ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz.asc \
  && GPG_KEYS="E51A4070A3FFBD68C65DDB9D8BECEF8DFFCC60DD" \
  && ( gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$GPG_KEYS" ) \
  && gpg --batch --verify panubo-functions.tar.gz.asc panubo-functions.tar.gz  \
  && tar -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apk del ${fetchDeps} \
  ;
```

## Bash Strict Mode

Although we like [Unofficial Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/) not all of these function currently work under strict mode.
