# Base
FROM node:20.15.1-alpine3.20 AS base

ARG PORT
ARG REDIS_HOST
ARG DATABASE_URL
ARG JWT_PRIVATE_KEY
ARG JWT_PUBLIC_KEY
ARG CLOUDFLARE_ACCOUNT_ID
ARG AWS_BUCKET_NAME
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ENV PORT=${PORT} \
    REDIS_HOST=${REDIS_HOST} \
    DATABASE_URL=${DATABASE_URL} \
    JWT_PRIVATE_KEY=${JWT_PRIVATE_KEY} \
    JWT_PUBLIC_KEY=${JWT_PUBLIC_KEY} \
    CLOUDFLARE_ACCOUNT_ID=${CLOUDFLARE_ACCOUNT_ID} \
    AWS_BUCKET_NAME=${AWS_BUCKET_NAME} \
    AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

# Prod deps
FROM base AS prod-deps

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

# Build
FROM base AS build

COPY . .

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm prisma generate
RUN pnpm run build

# Start
FROM base

COPY --from=prod-deps /app/node_modules /app/node_modules

COPY --from=build /app/dist /app/dist
COPY --from=build /app/prisma /app/prisma

COPY --from=build /app/package.json /app/package.json
COPY --from=build /app/pnpm-lock.yaml /app/pnpm-lock.yaml

EXPOSE 3333

CMD [ "pnpm", "start:prod" ]
