# Dockerfile for Hanbang API Server
# Build context: project root (not server/)
# This allows access to search_number/ folder and .git for Git LFS

FROM node:20-alpine AS builder
# Install Git and Git LFS for postal code database files
RUN apk add --no-cache git git-lfs
RUN git lfs install
WORKDIR /app

# Copy server files
COPY server/package*.json ./server/
COPY server/tsconfig.json ./server/
COPY server/prisma ./server/prisma
COPY server/src ./server/src

# Copy Git files for LFS
COPY .gitattributes ./.gitattributes
# Copy entire .git folder for LFS (needed for git lfs pull)
# Note: If .git is not available (e.g., in CI/CD), the files should already be in search_number/
COPY .git ./.git 2>/dev/null || echo "Warning: .git folder not found, assuming LFS files are already present"

# Pull Git LFS files (postal code database)
# This will download the actual postal code .txt files if .git is available
RUN if [ -d .git ]; then git lfs pull || echo "Git LFS pull failed, continuing..."; else echo "Skipping git lfs pull (no .git folder)"; fi

# Verify postal code files exist
RUN if [ -d search_number ]; then \
      echo "Postal code files found:"; \
      ls -lh search_number/*.txt 2>/dev/null | head -5 || echo "Warning: No .txt files in search_number/"; \
    else \
      echo "ERROR: search_number directory not found!"; \
      exit 1; \
    fi

# Build server
WORKDIR /app/server
RUN npm install
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY server/package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/server/dist ./dist
COPY --from=builder /app/server/.env.example ./dist/.env.example
# Copy postal code database files
COPY --from=builder /app/search_number ./search_number
ENV NODE_ENV=production
CMD ["node", "dist/server.js"]

