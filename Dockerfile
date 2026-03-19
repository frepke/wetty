# syntax=docker/dockerfile:1.7

############################
# Build stage
############################
FROM node:20-bookworm-slim AS build

ARG WETTY_REPO=https://github.com/butlerx/wetty.git
ARG WETTY_REF=v2.7.0

ENV HUSKY=0
ENV CI=true

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

# Enable corepack (for yarn)
RUN corepack enable

# Clone release
RUN git clone --depth=1 --branch "${WETTY_REF}" "${WETTY_REPO}" app

WORKDIR /src/app

# Install deps (Yarn!)
RUN yarn install --frozen-lockfile

# Build
RUN yarn build

# Remove dev deps
RUN yarn workspaces focus --production || yarn install --production --ignore-scripts

############################
# Runtime stage
############################
FROM node:20-bookworm-slim AS runtime

ARG WETTY_REF=v2.7.0

ENV NODE_ENV=production

WORKDIR /app

# Runtime deps
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-client \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Enable corepack (for yarn)
RUN corepack enable

# Non-root user
RUN useradd -m -u 10001 -s /usr/sbin/nologin wetty

# Copy build output
COPY --from=build /src/app/node_modules ./node_modules
COPY --from=build /src/app/build ./build
COPY --from=build /src/app/package.json ./package.json

USER wetty

EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD node -e "require('http').get('http://localhost:3000', res => process.exit(res.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["yarn", "start"]

############################
# Metadata
############################
LABEL org.opencontainers.image.source="https://github.com/butlerx/wetty"
LABEL org.opencontainers.image.vendor="frepke"
LABEL org.opencontainers.image.version="${WETTY_REF}"
