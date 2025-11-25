# Tooling Patterns - Biome, Bun, Docker

**CONFIGURAR** ferramentas de desenvolvimento para máxima produtividade:

## **BIOME CONFIGURATION** - Linting e formatting consistente:

```json
// biome.json
{
  "$schema": "https://biomejs.dev/schemas/1.5.3/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "complexity": {
        "noExtraBooleanCast": "error",
        "noMultipleSpacesInRegularExpressionLiterals": "error",
        "noUselessConstructor": "error",
        "noUselessLoneBlockStatements": "error"
      },
      "correctness": {
        "noChildrenProp": "error",
        "noConstAssign": "error",
        "noConstantCondition": "error",
        "noEmptyPattern": "error",
        "noGlobalObjectCalls": "error",
        "noInvalidConstructorSuper": "error",
        "noNewSymbol": "error",
        "noNonoctalDecimalEscape": "error",
        "noPrecisionLoss": "error",
        "noSelfAssign": "error",
        "noSetterReturn": "error",
        "noSwitchDeclarations": "error",
        "noUndeclaredVariables": "error",
        "noUnreachable": "error",
        "noUnreachableSuper": "error",
        "noUnsafeFinally": "error",
        "noUnsafeOptionalChaining": "error",
        "noUnusedLabels": "error",
        "noUnusedVariables": "error",
        "useExhaustiveDependencies": "warn",
        "useHookAtTopLevel": "error",
        "useIsNan": "error",
        "useValidForDirection": "error",
        "useYield": "error"
      },
      "security": {
        "noDangerouslySetInnerHtml": "error",
        "noDangerouslySetInnerHtmlWithChildren": "error"
      },
      "style": {
        "noArguments": "error",
        "noVar": "error",
        "useConst": "error",
        "useTemplate": "error"
      },
      "suspicious": {
        "noArrayIndexKey": "error",
        "noAsyncPromiseExecutor": "error",
        "noCatchAssign": "error",
        "noClassAssign": "error",
        "noCommentText": "error",
        "noCompareNegZero": "error",
        "noConfusingLabels": "error",
        "noConsoleLog": "warn",
        "noControlCharactersInRegex": "error",
        "noDebugger": "error",
        "noDoubleEquals": "error",
        "noDuplicateCase": "error",
        "noDuplicateClassMembers": "error",
        "noDuplicateObjectKeys": "error",
        "noDuplicateParameters": "error",
        "noEmptyBlockStatements": "error",
        "noExplicitAny": "warn",
        "noExtraNonNullAssertion": "error",
        "noFallthroughSwitchClause": "error",
        "noFunctionAssign": "error",
        "noGlobalAssign": "error",
        "noImportAssign": "error",
        "noLabelVar": "error",
        "noMisleadingCharacterClass": "error",
        "noPrototypeBuiltins": "error",
        "noRedeclare": "error",
        "noShadowRestrictedNames": "error",
        "noUnsafeNegation": "error",
        "useGetterReturn": "error",
        "useValidTypeof": "error"
      }
    }
  },
  "formatter": {
    "enabled": true,
    "formatWithErrors": false,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineEnding": "lf",
    "lineWidth": 100,
    "attributePosition": "auto"
  },
  "javascript": {
    "formatter": {
      "jsxQuoteStyle": "double",
      "quoteProperties": "asNeeded",
      "trailingComma": "es5",
      "semicolons": "always",
      "arrowParentheses": "always",
      "bracketSpacing": true,
      "bracketSameLine": false,
      "quoteStyle": "single"
    }
  },
  "json": {
    "formatter": {
      "trailingCommas": "none"
    }
  },
  "files": {
    "include": [
      "src/**/*",
      "app/**/*",
      "components/**/*",
      "lib/**/*",
      "hooks/**/*",
      "utils/**/*",
      "types/**/*",
      "*.ts",
      "*.tsx",
      "*.js",
      "*.jsx",
      "*.json"
    ],
    "ignore": [
      "node_modules",
      "dist",
      "build",
      ".next",
      "coverage",
      "*.d.ts"
    ]
  }
}
```

## **BUN SCRIPTS PATTERN** - Package.json otimizado:

```json
// package.json
{
  "scripts": {
    "dev": "bun run --hot src/index.ts",
    "dev:frontend": "bun run next dev",
    "dev:backend": "bun run nest start --watch",
    
    "build": "bun run build:check && bun run build:frontend && bun run build:backend",
    "build:check": "bun run typecheck && bun run lint && bun run format:check",
    "build:frontend": "bun run next build",
    "build:backend": "bun run nest build",
    
    "typecheck": "bun tsc --noEmit",
    "typecheck:watch": "bun tsc --noEmit --watch",
    
    "lint": "bunx @biomejs/biome lint .",
    "lint:fix": "bunx @biomejs/biome lint --apply .",
    "lint:unsafe": "bunx @biomejs/biome lint --apply-unsafe .",
    
    "format": "bunx @biomejs/biome format --write .",
    "format:check": "bunx @biomejs/biome format .",
    
    "check": "bunx @biomejs/biome check .",
    "check:fix": "bunx @biomejs/biome check --apply .",
    "check:unsafe": "bunx @biomejs/biome check --apply-unsafe .",
    
    "test": "bun test",
    "test:watch": "bun test --watch",
    "test:coverage": "bun test --coverage",
    "test:ui": "bun test --ui",
    
    "test:e2e": "bun run playwright test",
    "test:e2e:ui": "bun run playwright test --ui",
    "test:e2e:headed": "bun run playwright test --headed",
    
    "db:generate": "bun run drizzle-kit generate",
    "db:migrate": "bun run drizzle-kit migrate",
    "db:push": "bun run drizzle-kit push",
    "db:studio": "bun run drizzle-kit studio",
    "db:seed": "bun run src/database/seed.ts",
    
    "docker:build": "docker build -t app .",
    "docker:run": "docker run -p 3000:3000 app",
    "docker:dev": "docker-compose -f docker-compose.dev.yml up",
    "docker:prod": "docker-compose -f docker-compose.prod.yml up -d",
    "docker:down": "docker-compose down",
    
    "clean": "rm -rf dist build .next node_modules/.cache",
    "fresh": "bun run clean && bun install",
    
    "precommit": "bun run check:fix && bun run typecheck && bun run test",
    "prepare": "husky install"
  }
}
```

## **DOCKER PATTERNS** - Containerização otimizada:

```dockerfile
# Dockerfile (Multi-stage build)
# Build stage
FROM oven/bun:1 AS builder

WORKDIR /app

# Copy package files
COPY package.json bun.lockb ./
COPY apps/frontend/package.json ./apps/frontend/
COPY apps/backend/package.json ./apps/backend/

# Install dependencies
RUN bun install --frozen-lockfile

# Copy source code
COPY . .

# Build applications
RUN bun run build

# Production stage
FROM oven/bun:1-slim AS production

WORKDIR /app

# Copy built applications
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
COPY --from=builder /app/bun.lockb ./

# Install only production dependencies
RUN bun install --production --frozen-lockfile

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Change ownership of the app directory
RUN chown -R nextjs:nodejs /app
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["bun", "start"]

# docker-compose.dev.yml - Desenvolvimento
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
      - "3001:3001"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:password@db:5432/app_dev
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    command: bun run dev

  db:
    image: postgres:15
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=app_dev
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/dev.conf:/etc/nginx/nginx.conf
    depends_on:
      - app

volumes:
  postgres_data:
  redis_data:

# docker-compose.prod.yml - Produção
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - db
      - redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/prod.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

## **QUALITY GATES PATTERN** - Validação automática:

```bash
#!/bin/bash
# scripts/quality-check.sh

set -e

echo "🔍 Running quality checks..."

echo "📝 Checking TypeScript..."
bun run typecheck

echo "🧹 Checking formatting..."
bun run format:check

echo "🔧 Checking linting..."
bun run lint

echo "🧪 Running tests..."
bun run test

echo "🏗️ Testing build..."
bun run build:check

echo "✅ All quality checks passed!"

# scripts/precommit.sh
#!/bin/bash

set -e

echo "🚀 Pre-commit checks..."

# Auto-fix formatting and linting
echo "🔧 Auto-fixing code..."
bun run check:fix

# Type checking
echo "📝 Type checking..."
bun run typecheck

# Run tests
echo "🧪 Running tests..."
bun run test

# Check if there are any changes after auto-fix
if ! git diff --quiet; then
  echo "⚠️  Code was auto-fixed. Please review and commit again."
  exit 1
fi

echo "✅ Pre-commit checks passed!"

# .husky/pre-commit
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

bun run precommit
```

## **DEVELOPMENT WORKFLOW** - Scripts utilitários:

```bash
# scripts/dev-setup.sh
#!/bin/bash

echo "🚀 Setting up development environment..."

# Install dependencies
echo "📦 Installing dependencies..."
bun install

# Setup database
echo "🗄️ Setting up database..."
bun run db:generate
bun run db:migrate
bun run db:seed

# Setup git hooks
echo "🎣 Setting up git hooks..."
bun run prepare

# Run quality checks
echo "🔍 Running initial quality checks..."
bun run check

echo "✅ Development environment ready!"
echo "🏃 Run 'bun run dev' to start development"

# scripts/reset-project.sh
#!/bin/bash

echo "🗑️ Resetting project..."

# Clean build artifacts
bun run clean

# Reinstall dependencies
echo "📦 Reinstalling dependencies..."
bun install

# Reset database
echo "🗄️ Resetting database..."
bun run db:push
bun run db:seed

# Run quality checks
bun run check

echo "✅ Project reset complete!"

# scripts/deploy.sh
#!/bin/bash

set -e

echo "🚀 Deploying application..."

# Quality checks
echo "🔍 Running quality checks..."
bun run quality-check.sh

# Build for production
echo "🏗️ Building for production..."
bun run build

# Build Docker image
echo "🐳 Building Docker image..."
docker build -t app:latest .

# Deploy based on environment
if [ "$NODE_ENV" = "production" ]; then
  echo "🌍 Deploying to production..."
  docker-compose -f docker-compose.prod.yml up -d
else
  echo "🧪 Deploying to staging..."
  docker-compose -f docker-compose.staging.yml up -d
fi

echo "✅ Deployment complete!"
```

**REGRAS IMPORTANTES**:

- **USE** Biome para linting e formatting consistente
- **CONFIGURE** scripts Bun para todas as operações comuns
- **IMPLEMENTE** Docker multi-stage builds para otimização
- **AUTOMATIZE** quality gates no processo de desenvolvimento
- **SEPARE** configurações de dev/staging/produção
- **MONITORE** health checks e logs em produção
- **VERSIONE** dependencies com lockfile
- **DOCUMENTE** comandos disponíveis no README
- **VALIDE** código antes de cada commit
- **OTIMIZE** builds para reduzir tamanho das imagens