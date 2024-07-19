# Base
FROM node:20.15.1-alpine3.20 AS base

RUN --mount=type=secret,id=port \
  PORT=$(cat /run/secrets/port)
RUN --mount=type=secret,id=redis_host \
  REDIS_HOST=$(cat /run/secrets/redis_host)
RUN --mount=type=secret,id=database_url \
  DATABASE_URL=$(cat /run/secrets/database_url)
RUN --mount=type=secret,id=jwt_private_key \
  JWT_PRIVATE_KEY=$(cat /run/secrets/jwt_private_key)
RUN --mount=type=secret,id=jwt_public_key \
  JWT_PUBLIC_KEY=$(cat /run/secrets/jwt_public_key)
RUN --mount=type=secret,id=cloudflare_account_id \
  CLOUDFLARE_ACCOUNT_ID=$(cat /run/secrets/cloudflare_account_id)
RUN --mount=type=secret,id=aws_bucket_name \
  AWS_BUCKET_NAME=$(cat /run/secrets/aws_bucket_name)
RUN --mount=type=secret,id=aws_access_key_id \
  AWS_ACCESS_KEY_ID=$(cat /run/secrets/aws_access_key_id)
RUN --mount=type=secret,id=aws_secret_access_key \
  AWS_SECRET_ACCESS_KEY=$(cat /run/secrets/aws_secret_access_key)

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
