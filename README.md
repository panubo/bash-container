# Bash Container

[![Build Status](https://travis-ci.org/panubo/bash-container.svg?branch=master)](https://travis-ci.org/panubo/bash-container)
[![Status](https://img.shields.io/badge/status-BETA-yellow.svg)]()

Common container Bash functions.

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
  && wget -nv https://github.com/panubo/bash-container/releases/download/0.1.0/panubo-functions.tar.gz \
  && wget -nv https://github.com/panubo/bash-container/releases/download/0.1.0/panubo-functions.tar.gz.asc \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "E51A4070A3FFBD68C65DDB9D8BECEF8DFFCC60DD" \
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
```
