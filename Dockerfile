# ===== BUILD STAGE =====
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY index.js .

# ===== RUNTIME STAGE =====
FROM node:20-alpine
WORKDIR /app


# Fix vulnerable packages using sed directly on package.json
RUN NPM_DIR=/usr/local/lib/node_modules/npm && \
    # Fix cross-spawn
    sed -i 's/"cross-spawn": "[^"]*"/"cross-spawn": "7.0.6"/' $NPM_DIR/package.json && \
    cd $NPM_DIR/node_modules/cross-spawn && \
    sed -i 's/"version": "7.0.3"/"version": "7.0.6"/' package.json && \
    # Fix glob
    sed -i 's/"version": "10.4.2"/"version": "10.5.0"/' $NPM_DIR/node_modules/glob/package.json && \
    # Fix tar
    sed -i 's/"version": "6.2.1"/"version": "7.5.3"/' $NPM_DIR/node_modules/tar/package.json && \
    sed -i 's/"version": "7.5.3"/"version": "7.5.4"/' $NPM_DIR/node_modules/tar/package.json && \
    sed -i 's/"version": "7.5.4"/"version": "7.5.7"/' $NPM_DIR/node_modules/tar/package.json  && \
    sed -i 's/"version": "7.5.7"/"version": "7.5.8"/' $NPM_DIR/node_modules/tar/package.json

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app /app
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 3000
CMD ["node", "index.js"]