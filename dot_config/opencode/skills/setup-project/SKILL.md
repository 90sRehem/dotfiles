---
name: setup-project
description: Configures a new project in the persistent memory setup (projets-wiki vault + Graphify knowledge graph). Use when user types /setup-project, "configure project in vault", "add project to setup", or "initialize project memory". Creates vault folder structure, generates knowledge graph, installs git hooks and OpenCode plugin, registers project in global AGENTS.md. Do NOT use for already-configured projects (check if projets-wiki/project-name already exists), for updating an existing project graph (use /graphify --update), or for creating standalone vault notes.
trigger: /setup-project
metadata:
  author: rehem
  version: 1.0.0
---

# /setup-project

Configura um projeto no setup de memória persistente com vault Obsidian + Graphify. Cria estrutura no vault, gera grafo de conhecimento completo, instala automações e registra o projeto.

## Usage

```
/setup-project                              # configura o projeto no diretório atual
/setup-project <path>                       # configura um projeto em outro caminho
/setup-project ~/Documents/dev/work/act    # exemplo com path absoluto
```

## Examples

### Example 1: Projeto no diretório atual

User says: `/setup-project`
Actions:
1. Detecta nome do projeto pelo nome da pasta atual
2. Lê `package.json` para extrair stack
3. Cria `projets-wiki/meu-projeto/{architecture,features,data,logs}/`
4. Cria `decisions.md` com stack detectada
5. Roda graphify e gera notas no vault
Result: Projeto configurado, pronto para usar `/resume` e `/save`

### Example 2: Projeto em outro diretório

User says: `/setup-project ~/Documents/dev/work/act`
Actions: Mesmo fluxo, mas opera no path fornecido
Result: Mesmo resultado, projeto `act` configurado no vault

### Example 3: Projeto sem package.json (Python)

User says: `/setup-project`
Actions:
1. Não encontra `package.json`, verifica `pyproject.toml` / `requirements.txt`
2. Detecta stack Python a partir dos arquivos encontrados
3. Continua o fluxo normalmente
Result: `decisions.md` com stack Python corretamente preenchida

## Error Handling

### graphify não encontrado
Causa: `graphify` não está no PATH.
Solução: Informe o usuário — `pip install graphifyy` — e continue os outros passos sem o graphify. Documente no relatório final quais passos foram pulados.

### Projeto não é repositório git
Causa: Pasta `.git` não existe.
Solução: Pule o Step 7 (git hooks) silenciosamente e informe no relatório final.

### `opencode.json` não existe
Causa: Projeto não tem configuração OpenCode.
Solução: Crie um `opencode.json` mínimo (`{}`) antes de rodar `graphify opencode install`.

### Projeto já configurado no vault
Causa: `projets-wiki/<nome>` já existe.
Solução: Avise o usuário antes de continuar — "Este projeto já tem uma pasta no vault. Deseja reconfigurar?" — e aguarde confirmação.

### `/graphify` falha na extração semântica
Causa: Erro de API ou timeout durante extração de docs/imagens.
Solução: O grafo AST ainda é gerado e funcional. Informe o usuário e sugira rodar `/graphify --update` manualmente depois.

## O que faz

1. Detecta o nome e stack do projeto
2. Cria estrutura de pastas no vault `~/Documents/dev/projets-wiki/`
3. Cria `decisions.md` inicial pré-preenchido com a stack detectada
4. Roda `graphify update .` para gerar `graph.json`
5. Roda `graphify opencode install` para registrar o plugin
6. Roda `graphify hook install` para instalar git hooks
7. Roda `/graphify` completo com `--obsidian` para gerar notas no vault
8. Atualiza `projets-wiki/AGENTS.md` com o novo projeto

---

## What You Must Do When Invoked

Se nenhum path foi fornecido, use o diretório atual (`.`). Não pergunte ao usuário.

Siga os passos em ordem. Não pule passos.

### Step 1 — Detectar projeto

```bash
# Determinar o diretório absoluto do projeto
PROJECT_DIR=$(realpath INPUT_PATH)
PROJECT_NAME=$(basename "$PROJECT_DIR")
echo "Projeto: $PROJECT_NAME"
echo "Caminho: $PROJECT_DIR"
```

Substitua INPUT_PATH pelo path fornecido, ou `.` se nenhum foi dado.

### Step 2 — Detectar stack

Leia os arquivos de configuração do projeto para identificar linguagem e frameworks principais:

```bash
# Verificar arquivos de config existentes
ls "$PROJECT_DIR" | grep -E "package.json|pyproject.toml|go.mod|Cargo.toml|pom.xml|build.gradle|mix.exs|composer.json|Gemfile|turbo.json|bun.lockb"
```

Depois leia os relevantes (ex: `package.json` para projetos Node/Bun) para extrair:
- Linguagem principal
- Frameworks (NestJS, React, Next.js, FastAPI, etc.)
- Ferramentas (Turborepo, Bun, Docker, etc.)
- Propósito do projeto (description no package.json ou inferido do nome)

Imprima um resumo compacto:
```
Stack detectada:
  Linguagem: TypeScript
  Runtime: Bun
  Backend: NestJS 11
  Frontend: React 19
  Ferramentas: Turborepo, Biome
```

### Step 3 — Criar estrutura no vault

```bash
VAULT_DIR="$HOME/Documents/dev/projets-wiki"
PROJECT_VAULT="$VAULT_DIR/$PROJECT_NAME"

mkdir -p "$PROJECT_VAULT"/{architecture,features,data,logs}
mkdir -p "$VAULT_DIR/graphify/$PROJECT_NAME"

echo "Estrutura criada em $PROJECT_VAULT"
```

### Step 4 — Criar decisions.md inicial

Crie o arquivo `$PROJECT_VAULT/architecture/decisions.md` com o conteúdo abaixo, substituindo os placeholders pela stack detectada no Step 2:

```markdown
---
title: Decisões de Arquitetura — PROJECT_NAME
tags: [PROJECT_NAME, architecture, decisions]
created: CURRENT_DATE
updated: CURRENT_DATE
status: active
type: permanent
---

# Decisões de Arquitetura — PROJECT_NAME

## Stack

STACK_LIST

## Convenções

(a preencher conforme o projeto evolui)

## Links relacionados
```

Substitua:
- `PROJECT_NAME` pelo nome real do projeto
- `CURRENT_DATE` pela data atual no formato `YYYY-MM-DD`
- `STACK_LIST` por uma lista markdown com cada item da stack detectada (ex: `- **Runtime:** Bun 1.2`)

### Step 5 — Gerar graph.json com graphify update

```bash
cd "$PROJECT_DIR"

GRAPHIFY_BIN=$(which graphify 2>/dev/null)
if [ -z "$GRAPHIFY_BIN" ]; then
  echo "ERRO: graphify não encontrado. Instale com: pip install graphifyy"
  exit 1
fi

graphify update . 2>&1 | tail -5
```

Se falhar, reporte o erro e continue para o próximo passo — não interrompa o setup completo.

### Step 6 — Instalar plugin OpenCode

```bash
cd "$PROJECT_DIR"
graphify opencode install 2>&1
```

Se o arquivo `opencode.json` não existir no projeto, crie um mínimo antes:

```bash
if [ ! -f "$PROJECT_DIR/opencode.json" ]; then
  echo '{}' > "$PROJECT_DIR/opencode.json"
fi
```

### Step 7 — Instalar git hooks

```bash
cd "$PROJECT_DIR"

# Verificar se é um repositório git
if [ ! -d "$PROJECT_DIR/.git" ]; then
  echo "AVISO: Não é um repositório git. Pulando git hooks."
else
  graphify hook install 2>&1
fi
```

### Step 8 — Rodar /graphify completo com vault Obsidian

Agora rode o pipeline completo do graphify com geração do vault Obsidian.

Invoque a skill `/graphify` passando o path do projeto e a flag `--obsidian --obsidian-dir`:

```
/graphify PROJECT_DIR --obsidian --obsidian-dir ~/Documents/dev/projets-wiki/graphify/PROJECT_NAME
```

Substitua `PROJECT_DIR` e `PROJECT_NAME` pelos valores reais.

A skill `/graphify` irá:
- Detectar arquivos (código, docs, imagens)
- Rodar extração AST + semântica
- Gerar `graph.json`, `GRAPH_REPORT.md`, `graph.html`
- Gerar as notas Obsidian em `projets-wiki/graphify/PROJECT_NAME/`
- Gerar `graph.canvas`

### Step 9 — Atualizar AGENTS.md do vault

Leia o arquivo `~/Documents/dev/projets-wiki/AGENTS.md` e adicione o novo projeto na tabela de projetos da seção `## Projetos`.

Adicione uma linha no formato:
```
| PROJECT_NAME | STACK_SUMMARY | `PROJECT_NAME/` |
```

Onde `STACK_SUMMARY` é uma string curta com os principais itens da stack (ex: `Bun + NestJS 11, React 19, PostgreSQL`).

### Step 10 — Adicionar seção de vault no AGENTS.md do projeto

Verifique se o `AGENTS.md` do projeto já tem a seção `## Vault de Memória Persistente`. Se não tiver, adicione ao final:

```markdown
## Vault de Memória Persistente

O vault centralizado do projeto fica em `~/Documents/dev/projets-wiki/`.

### Regra de Consulta em 3 Camadas
1. **Primeiro:** consultar `graphify-out/graph.json` ou `graphify-out/GRAPH_REPORT.md` para estrutura do código
2. **Segundo:** consultar `~/Documents/dev/projets-wiki/PROJECT_NAME/` para decisões, progresso e contexto
3. **Terceiro:** ler arquivos de código bruto apenas ao editar

### Comandos de Sessão
- `/resume` — ler logs recentes em `~/Documents/dev/projets-wiki/PROJECT_NAME/logs/` + `architecture/decisions.md`, resumir estado atual
- `/save` — criar log em `~/Documents/dev/projets-wiki/PROJECT_NAME/logs/YYYY-MM-DD-descricao.md` com o que foi feito, decisões e pendências
```

Substitua `PROJECT_NAME` pelo nome real.

Se o projeto não tiver `AGENTS.md`, crie um com esse conteúdo mínimo mais a seção acima.

### Step 11 — Relatório final

Imprima um resumo do que foi feito:

```
✅ Setup concluído: PROJECT_NAME

Vault:
  ~/Documents/dev/projets-wiki/PROJECT_NAME/
    architecture/decisions.md   ← stack e convenções
    features/                   ← features planejadas/implementadas
    data/                       ← schema e modelo de dados
    logs/                       ← logs de sessão (/save aqui)

Grafo:
  PROJECT_DIR/graphify-out/
    graph.json                  ← consultado pelo agente
    GRAPH_REPORT.md             ← god nodes e comunidades
    graph.html                  ← visualização interativa
  ~/Documents/dev/projets-wiki/graphify/PROJECT_NAME/
    (notas Obsidian + graph.canvas)

Automações:
  ✅ graphify opencode install  (plugin registrado)
  ✅ graphify hook install      (git hooks ativos)

Fluxo de uso:
  /resume  → início de sessão (carrega contexto do vault)
  /save    → fim de sessão (salva log no vault)
  git commit → reconstrói graph.json automaticamente
```

Se algum passo falhou, liste os erros e sugira como corrigir manualmente.
