# syntax=docker/dockerfile:1.7

FROM node:20-bookworm-slim AS build

ARG PNPM_VERSION=9.15.4
ARG WETTY_REPO=https://github.com/butlerx/wetty.git
ARG WETTY_REF=8f3c1ab

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

# Install deps with cache optimization
COPY pnpm-lock.yaml* ./
RUN if [ -f pnpm-lock.yaml ]; then \
      pnpm fetch; \
    fi

RUN if [ -f pnpm-lock.yaml ]; then \
      pnpm install --frozen-lockfile; \
    else \
      pnpm install; \
    fi

# Build app
RUN pnpm build

# Remove dev deps safely
RUN NPM_CONFIG_IGNORE_SCRIPTS=true pnpm prune --prod

############################
# Runtime stage (minimal)
############################
FROM node:20-bookworm-slim AS runtime

ARG PNPM_VERSION=9.15.4

ENV NODE_ENV=production
ENV PNPM_HOME="/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

WORKDIR /app

# Install only runtime deps
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-client \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Enable pnpm (runtime)
RUN corepack enable \
 && corepack prepare "pnpm@${PNPM_VERSION}" --activate

# Create non-root user
RUN useradd -m -u 10001 -s /usr/sbin/nologin wetty

# Copy only what we need
COPY --from=build /src/app/node_modules ./node_modules
COPY --from=build /src/app/build ./build
COPY --from=build /src/app/package.json ./package.json

USER wetty

EXPOSE 3000

CMD ["pnpm", "start"]

LABEL org.opencontainers.image.title="WeTTY"
LABEL org.opencontainers.image.description="Browser-based terminal over SSH packaged as a Docker container."
LABEL org.opencontainers.image.source="https://github.com/frepke/wetty"
LABEL org.opencontainers.image.vendor="frepke"
