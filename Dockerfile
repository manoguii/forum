# Base
FROM node:20.15.1-alpine3.20 AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

COPY . /app
WORKDIR /app

# Prod deps
FROM base AS prod-deps

RUN pnpm install --prod --frozen-lockfile

# Build
FROM base AS build

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm prisma generate
RUN pnpm run build

# Start
FROM base

COPY --from=prod-deps /app/node_modules /app/node_modules

COPY --from=build /app/dist /app/dist
COPY --from=build /app/prisma /app/prisma
COPY --from=build /app/package.json /app/package.json

EXPOSE 3333

CMD [ "pnpm", "start:prod" ]
