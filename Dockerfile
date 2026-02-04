# syntax=docker/dockerfile:1
FROM node:22-bullseye-slim AS deps
WORKDIR /app
RUN apt-get update && apt-get install -y git python3 make g++ && rm -rf /var/lib/apt/lists/*
COPY package.json yarn.lock ./
COPY toolkit ./toolkit
COPY configs ./configs
RUN yarn install --frozen-lockfile

FROM node:22-bullseye-slim AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build

FROM node:22-bullseye-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
EXPOSE 3000
CMD ["yarn", "start"]
