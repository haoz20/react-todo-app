# syntax=docker/dockerfile:1
# FROM node:12-alpine
# RUN apk add --no-cache python3 g++ make
# WORKDIR /app
# COPY . .
# RUN yarn install --production
# CMD ["node", "src/index.js"]

# ---- Build deps (for native modules like sqlite3) ----
FROM node:20-bookworm-slim AS deps
WORKDIR /app

# Tools needed if sqlite3 must compile
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ \
 && rm -rf /var/lib/apt/lists/*

# Install only prod dependencies
COPY package*.json ./
RUN npm ci --omit=dev


# ---- Runtime image ----
FROM node:20-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production

# Copy installed node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy app source
COPY . .

# (Optional) If your server listens on 3000, keep this.
EXPOSE 3000

CMD ["node", "src/index.js"]
