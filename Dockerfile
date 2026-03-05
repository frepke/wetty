# --- build stage ---
FROM node:20-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apk add --no-cache git make g++ python3 py3-setuptools

WORKDIR /build
RUN git clone --depth=1 https://github.com/butlerx/wetty.git

WORKDIR /build/wetty
RUN pnpm install
RUN pnpm build

# --- runtime stage ---
FROM node:20-alpine

RUN adduser -D -u 10001 wetty
WORKDIR /app
ENV NODE_ENV=production

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@latest --activate

COPY --from=base /build/wetty/node_modules ./node_modules
COPY --from=base /build/wetty/build ./build
COPY --from=base /build/wetty/package.json .

RUN apk add --no-cache openssh-client sshpass coreutils

USER wetty

EXPOSE 3000
CMD ["pnpm","start"]
