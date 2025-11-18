# Node/Express + Render Backend Plan

This guide explains how to replace the earlier Firebase prototype with a pure
HTTP API built on Node/Express, deployed on Render’s free tier for now, while
keeping the architecture ready for a future paid host (e.g., AWS EC2).

## 1. Project layout (local development)

```
hanbang_app/
├─ docs/
│   └─ node_render_backend.md  ← this file
├─ server/                     ← create next to hanbang_app
│   ├─ src/
│   │   ├─ server.ts           ← Express bootstrap
│   │   ├─ routes/
│   │   │   └─ profile.routes.ts
│   │   └─ services/
│   │       └─ profile.service.ts
│   ├─ package.json
│   ├─ tsconfig.json
│   ├─ .env.example            ← documents required env vars
│   ├─ Dockerfile
│   └─ docker-compose.yml      ← optional, for local dev + db
└─ ...
```

- Use **TypeScript** for type parity with the Flutter models.
- Keep all credentials/secrets in `.env` and never commit them. Only expose
  strongly-typed config via a helper (e.g., `config.ts`) that reads
  `process.env`.

## 2. Express server responsibilities

1. **HTTP-only**: the server exposes RESTful JSON endpoints (`/profiles/me`,
   `/bookings`, `/chat`, etc.). No server-rendered HTML.
2. **Services**: business logic lives in `services/` modules. Routes are thin,
   call services, and respond with DTOs matching Flutter models.
3. **Error handling**: central middleware converts thrown errors into a uniform
   JSON shape `{ message, code }`.
4. **Domain enforcement**: never hardcode IPs. The Flutter app must hit
   `https://api.medicalstandard.dev` (or another domain) even during Render
   testing. Use DNS CNAMEs to point the domain to Render’s host.

## 3. Environment variables

Create `server/.env.example` with entries like:

```
NODE_ENV=development
PORT=8080
DATABASE_URL=postgres://...
JWT_SECRET=change-me
ALLOW_ORIGIN=https://staging.medicalstandard.dev
```

Load them via [dotenv](https://www.npmjs.com/package/dotenv) at startup. When
deploying to Render, configure the same keys inside the Render dashboard. For
EC2, use SSM Parameter Store or `.env` files managed by the CI pipeline.

## 4. Dockerization (optional but recommended)

`Dockerfile` example:

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/dist ./dist
ENV NODE_ENV=production
CMD [\"node\", \"dist/server.js\"]
```

`docker-compose.yml` can spin up the API plus any local databases. Render can
deploy directly from Docker images if desired; EC2 certainly can.

## 5. Deploying to Render (free tier)

1. Push the `server/` folder to its own Git repo (or keep it in this monorepo).
2. Connect the repo to [Render](https://render.com/) and create a **Web Service**.
3. Choose “Node” runtime or supply the Dockerfile. Set build command
   `npm install && npm run build`, start command `npm run start:prod`.
4. Add environment variables in Render’s dashboard.
5. Obtain the Render-provided URL (e.g., `https://hanbang-api.onrender.com`).
6. **Create a domain alias** (e.g., `api.medicalstandard.dev`) pointing to the
   Render host via CNAME. The Flutter app should always use the domain, not the
   raw Render URL.

## 6. Future migration to AWS EC2 (or similar)

- Reuse the same Docker image. Deploy it to EC2 (via ECS, EKS, or bare EC2 with
  `docker-compose`).
- CloudFront/ALB terminates TLS for `api.medicalstandard.dev`, so the Flutter
  client doesn’t change.
- CI/CD pipeline simply switches the deployment target; the app’s API base URL
  stays the same.

## 7. Flutter configuration

- Keep using `AppConfig.apiBaseUrl`, but set `API_BASE_URL` to the domain:
  `flutter run --dart-define API_BASE_URL=https://api.medicalstandard.dev`.
- For staging, create `staging.medicalstandard.dev` and point it to the staging
  Render service.
- The fallback mock service remains available for local UI development if the
  backend is offline.

## 8. Tasks you need to perform

Because deploying to Render/EC2 requires credentials and billing access, you’ll
need to:

1. Create the `server/` folder structure and TypeScript project (use this doc as
   a blueprint).
2. Implement the actual Express routes/services (I can help review code).
3. Provision Render web services, set environment variables, and connect your
   custom domain.
4. When migrating to EC2, set up the infrastructure (VMs, load balancer, TLS).

Once you share the server repo or deployment logs, I can assist with reviews,
Docker tweaks, or Flutter config updates.
