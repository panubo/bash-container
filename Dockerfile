FROM docker.io/debian:stretch-slim

# This Dockerfile is intended for testing and development of panubo-functions.sh and is not for distribution of panubo-functions.sh

# Install test dependencies
RUN set -x \
  && apt-get -y update \
  && apt-get -y install tzdata \
  && rm -rf /var/lib/apt/lists/* \
  ;

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates git wget procps xz-utils make sudo realpath vim \
  && useradd -m -s /bin/bash -G sudo user \
  && sed -i 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers \
  ;

# Install ShellCheck (Installing a newer version than is available via apt-get)
RUN set -x \
  && SHELLCHECK_VERSION=0.7.1 \
  && SHELLCHECK_CHECKSUM=64f17152d96d7ec261ad3086ed42d18232fcb65148b44571b564d688269d36c8 \
  && cd /tmp \
  && wget -nv https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
  && echo "${SHELLCHECK_CHECKSUM}  shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" > /tmp/SHA512SUM \
  && sha256sum -c SHA512SUM \
  && tar -Jxf shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
  && mv shellcheck-v${SHELLCHECK_VERSION}/shellcheck /usr/local/bin/shellcheck \
  && rm -rf /tmp/* \
  ;

RUN set -x \
  && GOMPLATE_VERSION=2.2.0 \
  && GOMPLATE_CHECKSUM=0e09e7cd6fb5e96858255a27080570624f72910e66be5152b77a2fd21d438dd7 \
  && wget -nv -O /tmp/gomplate_linux-amd64-slim -L https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64-slim \
  && echo "${GOMPLATE_CHECKSUM}  gomplate_linux-amd64-slim" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && mv /tmp/gomplate_linux-amd64-slim /usr/local/bin/gomplate \
  && chmod +x /usr/local/bin/gomplate \
  && rm -f /tmp/* \
  ;

RUN set -x \
  && cd ~ \
  && git clone https://github.com/bats-core/bats-core.git \
  && cd bats-core \
  && ./install.sh /usr/local \
  ;
