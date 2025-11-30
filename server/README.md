# Hanbang API (Node/Express)

## Development

1. Install dependencies  
   `"cd server && npm install"`
2. Create `.env` from `.env.example` and fill in values.
3. Start in watch mode  
   `"npm run dev"`

## Production build

```bash
"npm run build"
"npm run start"
```

## Docker

**Important**: Docker build context must be the project root (not server/), so that it can access the `search_number/` folder and `.git` for Git LFS.

```bash
# Build from project root
cd ..  # Go to project root
docker build -f Dockerfile -t hanbang-api .
docker run -p 8080:8080 --env-file server/.env hanbang-api
```

Or using docker-compose (from project root):
```bash
docker-compose -f server/docker-compose.yml build
docker-compose -f server/docker-compose.yml up
```
