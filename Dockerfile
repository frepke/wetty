# syntax=docker/dockerfile:1.7

FROM node:20-bookworm-slim AS build

ARG PNPM_VERSION=9.15.4
ARG WETTY_REPO=https://github.com/butlerx/wetty.git
ARG WETTY_REF=edfc1c7

ENV HUSKY=0
ENV CI=true
ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

WORKDIR /src

RUN apt-get update  && apt-get install -y --no-install-recommends       git python3 make g++ ca-certificates  && rm -rf /var/lib/apt/lists/*

RUN corepack enable  && corepack prepare "pnpm@${PNPM_VERSION}" --activate

RUN git clone --depth=1 --branch "${WETTY_REF}" "${WETTY_REPO}" app

WORKDIR /src/app

RUN pnpm install
RUN pnpm build
RUN NPM_CONFIG_IGNORE_SCRIPTS=true pnpm prune --prod

FROM node:20-bookworm-slim

ENV NODE_ENV=production
ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

WORKDIR /app

RUN apt-get update  && apt-get install -y --no-install-recommends openssh-client ca-certificates  && rm -rf /var/lib/apt/lists/*

RUN corepack enable  && corepack prepare "pnpm@9.15.4" --activate

RUN useradd -m -u 10001 -s /usr/sbin/nologin wetty

COPY --from=build /src/app/node_modules ./node_modules
COPY --from=build /src/app/build ./build
COPY --from=build /src/app/package.json ./package.json

USER wetty

EXPOSE 3000

CMD ["pnpm", "start"]

LABEL org.opencontainers.image.source="https://github.com/butlerx/wetty"
LABEL org.opencontainers.image.vendor="frepke"
