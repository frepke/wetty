# syntax=docker/dockerfile:1.7

############################
# Build stage
############################
FROM node:20-bookworm-slim AS build

ARG PNPM_VERSION=9.15.4
ARG WETTY_REPO=https://github.com/butlerx/wetty.git
ARG WETTY_REF=main

ENV HUSKY=0
ENV CI=true
ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

WORKDIR /src

# Build dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git \
      python3 \
      make \
      g++ \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Enable pnpm
RUN corepack enable \
 && corepack prepare "pnpm@${PNPM_VERSION}" --activate

# Clone main branch (shallow clone)
RUN git clone --depth=1 --branch "${WETTY_REF}" "${WETTY_REPO}" app

WORKDIR /src/app

# Install dependencies
RUN pnpm install

# Build
RUN pnpm build

# Remove dev dependencies
RUN NPM_CONFIG_IGNORE_SCRIPTS=true pnpm prune --prod

############################
# Runtime stage
############################
FROM node:20-bookworm-slim AS runtime

ARG PNPM_VERSION=9.15.4

ENV NODE_ENV=production
ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

WORKDIR /app

# Runtime dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-client \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Enable pnpm in runtime
RUN corepack enable \
 && corepack prepare "pnpm@${PNPM_VERSION}" --activate

# Non-root user
RUN useradd -m -u 10001 -s /usr/sbin/nologin wetty

# Copy production artifacts
COPY --from=build /src/app/node_modules ./node_modules
COPY --from=build /src/app/build ./build
COPY --from=build /src/app/package.json ./package.json

USER wetty

EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD node -e "require('http').get('http://localhost:3000', res => process.exit(res.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["pnpm", "start"]

# Labels
LABEL org.opencontainers.image.source="https://github.com/butlerx/wetty"
LABEL org.opencontainers.image.vendor="frepke"
