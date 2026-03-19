# syntax=docker/dockerfile:1.7

FROM node:20-bookworm-slim AS build

ARG PNPM_VERSION=9.15.4
ARG WETTY_REPO=https://github.com/butlerx/wetty.git
ARG WETTY_REF=main

ENV HUSKY=0
ENV CI=true
ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

WORKDIR /src

RUN apt-get update \
  && apt-get install -y --no-install-recommends git python3 make g++ ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN corepack enable \
  && corepack prepare "pnpm@${PNPM_VERSION}" --activate

# Clone and checkout WETTY_REF safely (works for branches/tags AND commit SHAs)
RUN git clone --filter=blob:none --no-checkout "${WETTY_REPO}" app \
  && cd app \
  && git fetch --depth=1 origin "${WETTY_REF}" \
  && git checkout --detach "${WETTY_REF}"

WORKDIR /src/app

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm install --frozen-lockfile
RUN pnpm build
RUN NPM_CONFIG_IGNORE_SCRIPTS=true pnpm prune --prod

FROM node:20-bookworm-slim

ARG PNPM_VERSION=9.15.4

ENV NODE_ENV=production
ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends openssh-client ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN corepack enable \
  && corepack prepare "pnpm@${PNPM_VERSION}" --activate

RUN useradd -m -u 10001 -s /usr/sbin/nologin wetty

COPY --from=build /src/app/node_modules ./node_modules
COPY --from=build /src/app/build ./build
COPY --from=build /src/app/package.json ./package.json

USER wetty

EXPOSE 3000

CMD ["pnpm", "start"]

LABEL org.opencontainers.image.source="https://github.com/butlerx/wetty"
LABEL org.opencontainers.image.vendor="frepke"
