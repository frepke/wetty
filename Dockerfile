# syntax=docker/dockerfile:1.7

############################
# Build stage
############################
FROM node:20-bookworm-slim AS build

ARG PNPM_VERSION=9.15.4
ARG WETTY_REPO=https://github.com/butlerx/wetty.git
ARG WETTY_REF=main

ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

WORKDIR /src

# Build deps (node-gyp toolchain)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git \
      python3 \
      make \
      g++ \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && corepack enable \
 && corepack prepare "pnpm@${PNPM_VERSION}" --activate

# Clone upstream (fallback if branch name differs)
RUN set -eux; \
    git clone --depth=1 --branch "${WETTY_REF}" "${WETTY_REPO}" app \
    || git clone --depth=1 --branch master "${WETTY_REPO}" app

WORKDIR /src/app

RUN if [ -f pnpm-lock.yaml ]; then \
      pnpm install --frozen-lockfile; \
    else \
      pnpm install; \
    fi

RUN pnpm build
RUN pnpm prune --prod

############################
# Runtime stage
############################
FROM node:20-bookworm-slim AS runtime

ARG PNPM_VERSION=9.15.4
ARG INSTALL_SSHPASS=false

ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"
ENV NODE_ENV=production

WORKDIR /app

# Runtime deps + user + pnpm
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-client \
      ca-certificates \
 && if [ "${INSTALL_SSHPASS}" = "true" ]; then \
      apt-get install -y --no-install-recommends sshpass; \
    fi \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -u 10001 -s /bin/bash wetty \
 && corepack enable \
 && corepack prepare "pnpm@${PNPM_VERSION}" --activate

COPY --from=build /src/app/node_modules /app/node_modules
COPY --from=build /src/app/build /app/build
COPY --from=build /src/app/package.json /app/package.json

USER wetty

EXPOSE 3000
CMD ["pnpm", "start"]

LABEL org.opencontainers.image.title="WeTTY"
LABEL org.opencontainers.image.description="Browser-based terminal over SSH packaged as a Docker container."
LABEL org.opencontainers.image.source="https://github.com/frepke/wetty"
LABEL org.opencontainers.image.url="https://github.com/frepke/wetty"
LABEL org.opencontainers.image.vendor="frepke"
