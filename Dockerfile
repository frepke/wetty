# --- build stage ---
FROM node:20-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apk add --no-cache git make g++ python3 py3-setuptools

ARG WETTY_VERSION=v2.7.0

WORKDIR /build
RUN git clone --depth=1 --branch $WETTY_VERSION https://github.com/butlerx/wetty.git

WORKDIR /build/wetty
RUN pnpm install --no-frozen-lockfile
RUN pnpm build
RUN pnpm prune --prod


# --- runtime stage ---
FROM node:20-alpine

RUN adduser -D -u 10001 wetty

WORKDIR /app
ENV NODE_ENV=production

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apk add --no-cache openssh-client sshpass coreutils

COPY --from=base /build/wetty/node_modules ./node_modules
COPY --from=base /build/wetty/build ./build
COPY --from=base /build/wetty/package.json .

USER wetty

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost:3000 || exit 1

CMD ["pnpm","start"]
