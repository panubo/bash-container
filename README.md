# Bash Container

[![CI Tests](https://github.com/panubo/bash-container/workflows/CI%20Tests/badge.svg)](https://github.com/panubo/bash-container/actions)
[![Status](https://img.shields.io/badge/status-BETA-yellow.svg)]()

Common container Bash functions. All functions are tested and checked against [ShellCheck](https://github.com/koalaman/shellcheck).

## Install

The Panubo functions require bash, curl and coreutils. These take about 10M of space.

### Debian

```
RUN set -x \
  && BASHCONTAINER_VERSION=0.7.0 \
  && BASHCONTAINER_SHA256=45065b105614543b7775131728dbdf680586f553163240e4dd7226f03a35d4fa \
  && if ! command -v wget > /dev/null; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && echo "${BASHCONTAINER_SHA256}  panubo-functions.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum panubo-functions.tar.gz)"; exit 1; )) \
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
  && BASHCONTAINER_VERSION=0.7.0 \
  && BASHCONTAINER_SHA256=45065b105614543b7775131728dbdf680586f553163240e4dd7226f03a35d4fa \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && apk add --no-cache ca-certificates bash curl coreutils ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && echo "${BASHCONTAINER_SHA256}  panubo-functions.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum panubo-functions.tar.gz)"; exit 1; )) \
  && tar -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apk del ${fetchDeps} \
  ;
```

## Bash Strict Mode

Although we like [Unofficial Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/) not all of these functions currently work under strict mode.
