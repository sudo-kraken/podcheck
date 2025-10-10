FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG REGCTL_VERSION=0.9.2
ARG COSIGN_VERSION=3.0.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl ca-certificates git jq yq shellcheck shfmt podman skopeo \
    python3 python3-pip \
  && rm -rf /var/lib/apt/lists/*

# regctl static binary
RUN set -eux; \
    arch="$(uname -m)"; case "$arch" in x86_64) a=amd64 ;; aarch64) a=arm64 ;; *) a=amd64 ;; esac; \
    curl -fsSL -o /usr/local/bin/regctl "https://github.com/regclient/regclient/releases/download/v${REGCTL_VERSION}/regctl-linux-${a}"; \
    chmod +x /usr/local/bin/regctl

# cosign static binary
RUN set -eux; \
    arch="$(uname -m)"; case "$arch" in x86_64) a=amd64 ;; aarch64) a=arm64 ;; *) a=amd64 ;; esac; \
    curl -fsSL -o /usr/local/bin/cosign "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-${a}"; \
    chmod +x /usr/local/bin/cosign

ENV EDITOR=code
