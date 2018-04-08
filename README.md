# Bash Container

[![Build Status](https://travis-ci.org/panubo/bash-container.svg?branch=master)](https://travis-ci.org/panubo/bash-container)
[![Status](https://img.shields.io/badge/status-BETA-yellow.svg)]()

Common container Bash functions. All functions are tested and checked against [ShellCheck](https://github.com/koalaman/shellcheck).

## Install

### Debian

```
RUN set -x \
  && if ! command -v wget > /dev/null; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && if ! command -v gpg > /dev/null; then \
      fetchDeps="${fetchDeps} gnupg dirmngr"; \
     fi \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v0.1.2/panubo-functions.tar.gz \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v0.1.2/panubo-functions.tar.gz.asc \
  && GPG_KEYS="E51A4070A3FFBD68C65DDB9D8BECEF8DFFCC60DD" \
  && ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
      || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEYS" \
      || gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEYS" ) \
  && gpg --batch --verify panubo-functions.tar.gz.asc panubo-functions.tar.gz  \
  && tar -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;
```

### Alpine

The Panubo functions require bash and coreutils, this takes about 10M of space.

```
RUN set -x \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && if ! command -v gpg > /dev/null; then \
      fetchDeps="${fetchDeps} gnupg"; \
     fi \
  && apk add --no-cache ca-certificates bash coreutils ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v0.1.2/panubo-functions.tar.gz \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v0.1.2/panubo-functions.tar.gz.asc \
  && GPG_KEYS="E51A4070A3FFBD68C65DDB9D8BECEF8DFFCC60DD" \
  && ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
      || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEYS" \
      || gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEYS" ) \
  && gpg --batch --verify panubo-functions.tar.gz.asc panubo-functions.tar.gz  \
  && tar -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apk del ${fetchDeps} \
  ;
```
