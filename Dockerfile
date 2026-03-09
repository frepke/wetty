FROM node:20-alpine AS build

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apk add --no-cache git make g++ python3 py3-setuptools
RUN npm i -g husky@9

WORKDIR /src

RUN git clone --depth=1 https://github.com/butlerx/wetty.git app

WORKDIR /src/app

RUN pnpm install
RUN pnpm build
RUN pnpm prune --prod

FROM node:20-alpine AS runtime

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV NODE_ENV=production

RUN adduser -D -u 10001 wetty
RUN apk add --no-cache openssh-client sshpass

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@latest --activate

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
