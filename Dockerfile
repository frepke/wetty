# syntax=docker/dockerfile:1.7

############################
# Build stage
############################
FROM node:20-alpine AS build

ARG PNPM_VERSION=9.15.4
# Pin the upstream source ref (tag or commit SHA)
ARG WETTY_REPO=https://github.com/butlerx/wetty.git
ARG WETTY_REF=main

ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

WORKDIR /src

# Build dependencies only in build stage
RUN apk add --no-cache --update \
      git \
      python3 \
      make \
      g++ \
    && apk upgrade --no-cache \
    && corepack enable \
    && corepack prepare "pnpm@${PNPM_VERSION}" --activate

# Clone pinned ref (NOT floating HEAD)
RUN git clone --depth=1 --branch "${WETTY_REF}" "${WETTY_REPO}" app

WORKDIR /src/app

# If upstream has a lockfile, frozen install helps a lot
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
FROM node:20-alpine AS runtime

ARG PNPM_VERSION=9.15.4
# Set to "true" only if you really need sshpass
ARG INSTALL_SSHPASS=false

ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"
ENV NODE_ENV=production

WORKDIR /app

RUN apk add --no-cache --update openssh-client \
    && if [ "${INSTALL_SSHPASS}" = "true" ]; then apk add --no-cache sshpass; fi \
    && apk upgrade --no-cache \
    && adduser -D -u 10001 wetty \
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
