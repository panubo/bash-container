# Bash Container

[![CI Tests](https://github.com/panubo/bash-container/workflows/CI%20Tests/badge.svg)](https://github.com/panubo/bash-container/actions)
[![Status](https://img.shields.io/badge/status-STABLE-green.svg)]()

Common container Bash functions used for handling Docker image entrypoint semantics.

All functions are [Bats](https://github.com/bats-core/bats-core) tested and checked against [ShellCheck](https://github.com/koalaman/shellcheck).

<!-- BEGIN_TOP_PANUBO -->
> [!IMPORTANT]
> **Maintained by Panubo** — Cloud Native & SRE Consultants in Sydney.
> [Work with us →](https://panubo.com.au)
<!-- END_TOP_PANUBO -->

## Table of Contents

- [Core Concepts](#core-concepts)
- [Functions](#functions)
  - [Process Management](#process-management)
  - [Service Waiting](#service-waiting)
  - [File Handling](#file-handling)
  - [Miscellaneous](#miscellaneous)
- [Install](#install)
- [Example Usage](#example-usage)
- [Bash Strict Mode](#bash-strict-mode)
- [License](#license)
- [Status](#status)

## Core Concepts

This collection of Bash functions simplifies the creation of robust Docker entrypoint scripts. The main goals are:

- **Service-awareness**: Wait for dependent services like databases or message queues to be available before starting the main application.
- **Dynamic configuration**: Use environment variables to render configuration files at runtime.
- **Process management**: Manage application processes using `Procfile`-like mechanics.
- **Filesystem setup**: Handle the mounting of data volumes and template files.

## Functions

### Process Management

| Function                                | Description                                                                    | Usage                               |
| --------------------------------------- | ------------------------------------------------------------------------------ | ----------------------------------- |
| `execute <PROCFILE> <COMMAND>`          | Executes a command from a Procfile. Returns 127 if the command is not found.   | `execute Procfile web`              |
| `exec_procfile <COMMAND>`               | A wrapper for `execute` that uses `Procfile` by default.                         | `exec_procfile web`                 |
| `run_all [PROCFILE]`                    | Runs all commands in a Procfile.                                               | `run_all` or `run_all Deployfile`   |
| `run_commands <PROCFILE> <COMMANDS...>` | Runs one or more specified commands from a Procfile.                           | `run_commands Procfile web worker`  |
| `run_deployfile`                        | Alias for `run_all Deployfile`.                                                | `run_deployfile`                    |
| `run_procfile`                          | Alias for `run_all Procfile`.                                                  | `run_procfile`                      |
| `run_procfile_commands`                 | Alias for `run_commands Procfile`.                                             | `run_procfile_commands web`         |
| `run_deployfile_commands`               | Alias for `run_commands Deployfile`.                                           | `run_deployfile_commands task`      |

### Service Waiting

| Function                                        | Description                                                          | Usage                                     |
| ----------------------------------------------- | -------------------------------------------------------------------- | ----------------------------------------- |
| `wait_http <URL> [TIMEOUT] [HTTP_TIMEOUT]`      | Waits for an HTTP service to become available.                       | `wait_http http://api:8080 60 5`          |
| `wait_kubeapi [RETRIES]`                        | Waits for the Kubernetes API to be available. Requires `kubectl`.    | `wait_kubeapi 60`                         |
| `wait_tcp <HOST> [PORT] [RETRIES] [TCP_TIMEOUT]`| Waits for a TCP port to be open.                                     | `wait_tcp db 5432`                        |
| `wait_tcp_multi <HOSTS> [MIN] [PORT]...`        | Waits for a minimum number of hosts to have an open TCP port.        | `wait_tcp_multi redis1,redis2 2 6379`     |
| `wait_mariadb <HOST> [PORT]...`                 | Alias for `wait_tcp` with port 3306.                                 | `wait_mariadb db`                         |
| `wait_postgres <HOST> [PORT]...`                | Alias for `wait_tcp` with port 5432.                                 | `wait_postgres db`                        |
| `wait_rabbitmq <HOST> [PORT]...`                | Alias for `wait_tcp` with port 5672.                                 | `wait_rabbitmq rabbit`                    |
| `wait_redis <HOST> [PORT]...`                   | Alias for `wait_tcp` with port 6379.                                 | `wait_redis cache`                        |
| `wait_multi_rabbitmq <HOSTS> [MIN] [PORT]`      | Alias for `wait_tcp_multi` with port 5672.                           | `wait_multi_rabbitmq rabbit1,rabbit2 1`   |
| `wait_multi_redis <HOSTS> [MIN] [PORT]`         | Alias for `wait_tcp_multi` with port 6379.                           | `wait_multi_redis redis1,redis2 1`        |
| `wait_multi_elasticsearch <HOSTS> [MIN] [PORT]` | Alias for `wait_tcp_multi` with port 9200.                           | `wait_multi_elasticsearch es1,es2 1`      |

### File Handling

| Function                              | Description                                            | Usage                                    |
| ------------------------------------- | ------------------------------------------------------ | ---------------------------------------- |
| `import_env <FILE>`                   | Sources an environment file and exports the variables. | `import_env /app/.env`                   |
| `render_templates <FILES...>`         | Renders template files using `gomplate`.               | `render_templates /app/config.yaml.tmpl` |
| `run_mountfile [MOUNTFILE] [DATADIR]` | Mounts directories based on a `Mountfile`.             | `run_mountfile`                          |

### Miscellaneous

| Function                  | Description                    | Usage                           |
| ------------------------- | ------------------------------ | ------------------------------- |
| `set_timezone [TIMEZONE]` | Sets the container's timezone. | `set_timezone America/New_York` |

## Install

The main functions require `bash`, `curl` and `coreutils`. These take about 10M of space. The template function requires [gomplate](https://github.com/hairyhenderson/gomplate/).

### Debian

```Dockerfile
# Install bash-container functions
RUN set -x \
  && BASHCONTAINER_VERSION=0.8.0 \
  && BASHCONTAINER_SHA256=0ddc93b11fd8d6ac67f6aefbe4ba790550fc98444e051e461330f10371a877f1 \
  && if ! command -v wget > /dev/null; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && echo "${BASHCONTAINER_SHA256}  panubo-functions.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum panubo-functions.tar.gz)"; exit 1; )) \
  && tar --no-same-owner -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;
```

### Alpine

```Dockerfile
# Install bash-container functions
RUN set -x \
  && BASHCONTAINER_VERSION=0.8.0 \
  && BASHCONTAINER_SHA256=0ddc93b11fd8d6ac67f6aefbe4ba790550fc98444e051e461330f10371a877f1 \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && apk add --no-cache ca-certificates bash curl coreutils ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && echo "${BASHCONTAINER_SHA256}  panubo-functions.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum panubo-functions.tar.gz)"; exit 1; )) \
  && tar --no-same-owner -C / -zxf panubo-functions.tar.gz \
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

# Set the timezone
set_timezone "${TZ}"

# Wait for services to be available
wait_postgres "${DB_HOST}" "${DB_PORT:-5432}"
wait_redis "${REDIS_HOST}" "${REDIS_PORT:-6379}"

# Render configuration templates
render_templates /etc/my.cnf.tmpl

# Import environment variables from a file
import_env /app/.env

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
  && GOMPLATE_VERSION=3.8.0 \
  && GOMPLATE_SHA256=847f7d9fc0dc74c33188c2b0d0e9e4ed9204f67c36da5aacbab324f8bfbf29c9 \
  && if ! command -v wget > /dev/null; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates ${fetchDeps} \
  && wget -nv -O /tmp/gomplate_linux-amd64-slim -L https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64-slim \
  && echo "${GOMPLATE_SHA256}  gomplate_linux-amd64-slim" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && mv /tmp/gomplate_linux-amd64-slim /usr/local/bin/gomplate \
  && chmod +x /usr/local/bin/gomplate \
  && rm -rf /tmp/* \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;
```

Or add to your `Dockerfile`, to install gomplate (Alpine example):

```Dockerfile
# Install gomplate
RUN set -x \
  && GOMPLATE_VERSION=3.8.0 \
  && GOMPLATE_SHA256=847f7d9fc0dc74c33188c2b0d0e9e4ed9204f67c36da5aacbab324f8bfbf29c9 \
  && cd /tmp \
  && wget -nv https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64 \
  && echo "${GOMPLATE_SHA256}  gomplate_linux-amd64" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum gomplate_linux-amd64)"; exit 1; )) \
  && chmod +x gomplate_linux-amd64 \
  && mv gomplate_linux-amd64 /usr/local/bin/gomplate \
  && rm -rf /tmp/* \
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

## License

This project is licensed under the [MIT License](LICENSE).

## Status

Stable and used in production.

<!-- BEGIN_BOTTOM_PANUBO -->
> [!IMPORTANT]
> ## About Panubo
>
> This project is maintained by Panubo, a technology consultancy based in Sydney, Australia. We build reliable, scalable systems and help teams master the cloud-native ecosystem.
>
> We are available for hire to help with:
>
> * SRE & Operations: Improving system reliability and incident response.
> * Platform Engineering: Building internal developer platforms that scale.
> * Kubernetes: Cluster design, security auditing, and migrations.
> * DevOps: Streamlining CI/CD pipelines and developer experience.
> * [See our other services](https://panubo.com.au/services)
>
> Need a hand with your infrastructure? [Let’s have a chat](https://panubo.com.au/contact) or email us at team@panubo.com.
<!-- END_BOTTOM_PANUBO -->
