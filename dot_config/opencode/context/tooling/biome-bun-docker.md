# Tooling: Biome, Bun, Docker

Load this when working on build config, linting, formatting, or containerization.

## Biome

- **Formatter + Linter** in one tool. Replaces ESLint + Prettier.
- Config file: `biome.json` at project root.
- Run: `bun biome check --apply .` (fix all) or `bun biome check .` (report only).
- Organize imports: handled by Biome automatically.
- Key rule: `noExplicitAny: "error"` — enforced project-wide.

### Commands

| Task | Command |
|---|---|
| Check all | `bun biome check .` |
| Fix all | `bun biome check --apply .` |
| Format only | `bun biome format --write .` |
| Lint only | `bun biome lint .` |

## Bun

- **Runtime + Package Manager + Test Runner + Bundler**.
- Lockfile: `bun.lock` (text-based since Bun v1.2+).
- Workspaces: `"workspaces"` field in root `package.json`.

### Commands

| Task | Command |
|---|---|
| Install deps | `bun install` |
| Run script | `bun run dev` |
| Run tests | `bun test` |
| Add dep | `bun add {package}` |
| Add dev dep | `bun add -d {package}` |
| Execute binary | `bunx {package}` |
| Typecheck | `bun tsc --noEmit` |

### Standard Scripts Pattern

```json
{
  "dev": "bun run --hot src/index.ts",
  "build": "bun run typecheck && bun run build:app",
  "typecheck": "bun tsc --noEmit",
  "check": "bun biome check --apply . && bun tsc --noEmit && bun test",
  "test": "bun test",
  "test:watch": "bun test --watch",
  "db:migrate": "bun drizzle-kit migrate",
  "db:generate": "bun drizzle-kit generate",
  "db:studio": "bun drizzle-kit studio"
}
```

## Docker

- Use multi-stage builds: `deps` → `build` → `production`.
- Base image: `oven/bun:1-alpine` for production, `oven/bun:1` for build.
- Copy lockfile first for layer caching: `COPY bun.lock package.json ./`.
- Run as non-root: `USER bun` (built into oven/bun images).
- `.dockerignore`: `node_modules`, `.git`, `.env`, `dist`, `.next`.

### Compose Essentials

```yaml
services:
  app:
    build: .
    ports: ["3000:3000"]
    env_file: .env
    depends_on:
      db: { condition: service_healthy }
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes: [pgdata:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
volumes:
  pgdata:
```

## Quality Gate (pre-commit)

```bash
bun biome check --apply . && bun tsc --noEmit && bun test
```

Hook via `lefthook` or `husky`. Fail fast — lint before typecheck before tests.
