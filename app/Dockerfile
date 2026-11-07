# ---- Base image ----
FROM node:24-alpine

WORKDIR /app

# ---- Dependencies ----
# Copied before the source so this layer stays cached when only code changes
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ---- Application source ----
COPY src ./src

# ---- Runtime config ----
# Declared late so a new version doesn't invalidate the npm layer
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION} \
    NODE_ENV=production \
    PORT=8080

# ---- Security ----
# Built-in "node" user, numeric UID so Kubernetes can verify runAsNonRoot
USER 1000

# ---- Start ----
EXPOSE 8080
CMD ["node", "src/server.js"]