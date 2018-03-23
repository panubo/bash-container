# Bash Container

[![Build Status](https://travis-ci.org/panubo/bash-container.svg?branch=master)](https://travis-ci.org/panubo/bash-container)

Common container Bash functions.

## Status

Work in progress.

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
  && wget -nv https://URL/FILENAME \
  && gpg --batch --verify FILENAME.asc FILENAME  \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;
```

### Alpine

```
RUN set -x \
```
