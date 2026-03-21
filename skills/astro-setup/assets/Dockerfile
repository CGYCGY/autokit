FROM oven/bun:1-alpine AS build
WORKDIR /app
COPY bun.lock package.json ./
RUN bun install --frozen-lockfile
COPY . .
RUN bun run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
HEALTHCHECK --interval=60s --timeout=5s --start-period=10s --retries=3 \
  CMD nc -z localhost 80
EXPOSE 80
