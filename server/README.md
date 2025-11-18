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

```bash
"docker build -t hanbang-api ."
"docker run -p 8080:8080 --env-file .env hanbang-api"
```
