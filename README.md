# Bash Container

[![CI Tests](https://github.com/panubo/bash-container/workflows/CI%20Tests/badge.svg)](https://github.com/panubo/bash-container/actions)
[![Status](https://img.shields.io/badge/status-STABLE-green.svg)]()

Common container Bash functions used for handling Docker image entrypoint semantics.

All functions are [Bats](https://github.com/bats-core/bats-core) tested and checked against [ShellCheck](https://github.com/koalaman/shellcheck).

## Install

The main functions require bash, curl and coreutils. These take about 10M of space. The template function requires [gomplate](https://github.com/hairyhenderson/gomplate/).

### Debian

```Dockerfile
RUN set -x \
  && BASHCONTAINER_VERSION=0.7.1 \
  && BASHCONTAINER_SHA256=e13b1930e75aa4c5526820b5c7ec4f3530bdcfda45752bcf8dfef193d4624977 \
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

```Dockerfile
RUN set -x \
  && BASHCONTAINER_VERSION=0.7.1 \
  && BASHCONTAINER_SHA256=e13b1930e75aa4c5526820b5c7ec4f3530bdcfda45752bcf8dfef193d4624977 \
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

## Example Usage

The functions are used within a Docker entrypoint script to simplify container initialization and abstract entrypoints.

This example also uses a [Mountfile](https://github.com/voltgrid/voltgrid-pie/blob/master/docs/mountfile.md) and [Procfile](https://devcenter.heroku.com/articles/procfile#procfile-format).

```shell
#!/usr/bin/env bash

set -e

source /panubo-functions.sh

# Wait for services
wait_mariadb "${DB_HOST}" "${DB_PORT:-3306}"

# Mount data mounts (specifying an alternate mount point uid/gid)
MOUNTFILE_MOUNT_UID=33
MOUNTFILE_MOUNT_GID=33
run_mountfile

# Exec Procfile command, or if not found in Procfile execute the command passed to the entrypoint
exec_procfile "${1}" || exec "$@"
```

Alternate Procfile handling:

```shell
# Try to run a procfile command
exec_procfile "$1"

# exec_procfile returns 127 if the command isn't in the Procfile
if [ "$?" -eq "127" ]; then
	exec "${@}"
fi

```

### Using gomplate templating

Add to your `Dockerfile`, to install gomplate (Debian example):

```Dockerfile
# Install gomplate
RUN set -x \
  && GOMPLATE_VERSION=v3.6.0 \
  && GOMPLATE_CHECKSUM=0867b2d6b23c70143a4ea37705d4308d051317dd0532d7f3063acec21f6cbbc8 \
  && if ! command -v wget > /dev/null; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates ${fetchDeps} \
  && wget -nv -O /tmp/gomplate_linux-amd64-slim -L https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64-slim \
  && echo "${GOMPLATE_CHECKSUM}  gomplate_linux-amd64-slim" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && mv /tmp/gomplate_linux-amd64-slim /usr/local/bin/gomplate \
  && chmod +x /usr/local/bin/gomplate \
  && rm -rf /tmp/* \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;
```

A minimal template (`/foo.conf.tmpl`):

```
# Template example
FOO={{ getenv "MYAPP_FOO" "default_foo_value" }}
```

A minimal entrypoint script:

```shell
#!/usr/bin/env bash

set -e

source /panubo-functions.sh

render_templates /foo.conf.tmpl
```

This will render `/foo.conf.tmpl` to `/foo.conf`.

## Bash Strict Mode

Although we like [Unofficial Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/) not all of these functions currently work under strict mode.
