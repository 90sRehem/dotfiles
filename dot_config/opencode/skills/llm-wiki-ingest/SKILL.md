---
name: llm-wiki-ingest
description: Executes the LLM Wiki INGEST workflow when the user runs /ingest with a file path or pastes raw text. Reads the source, creates a structured fonte page, identifies and creates/updates entidades and conceitos, then updates index.md and log.md. Asks for user confirmation before writing. Supports /ingest path/to/file.md, /ingest path/to/file.md --discuss (interactive takeaway discussion), and /ingest with pasted text. Do NOT use for wiki queries (use QUERY workflow), lint checks, or general note-taking outside the wiki/ structure.
license: CC-BY-4.0
metadata:
  author: rehem
  version: 1.0.0
---

# LLM Wiki — Ingest

Executes the full INGEST workflow for the LLM Wiki second brain. Reads a source (file path or pasted text), builds structured wiki pages, and keeps `index.md` and `log.md` current.

## Trigger

Activates when the user runs:
- `/ingest <path>` — ingest a file already in the vault or filesystem
- `/ingest <path> --discuss` — same, but opens an interactive takeaway discussion before writing
- `/ingest` followed by pasted text — ingest raw text directly from the chat

## Instructions

### Step 1: Read the Source

**If a file path was given:**
- Read the file at the provided path
- If the path is relative, resolve it from the vault root (`/home/rehem/Documents/obsidian/`)
- If the file does not exist, report the error and stop

**If text was pasted:**
- Use the pasted content directly as the source
- Ask the user: "Qual é o título desta fonte?" and "Tem URL ou autor?" before proceeding

### Step 2: Extract Metadata

From the source content, extract or infer:
- `titulo` — title of the source (translate to Portuguese if needed)
- `autor` — author name, or "Desconhecido" if not found
- `url` — original URL, or `""` if not available
- `subtipo` — one of: `artigo | livro | video | podcast | paper`
- `data-original` — publication date if found, otherwise today's date (YYYY-MM-DD)
- `tags` — 3–6 kebab-case tags relevant to the content
- `timestamp` — Unix timestamp for today (use current date to generate it)

### Step 3: Identify Entities and Concepts

Scan the source and list:
- **Entidades** — people, projects, tools, technologies mentioned (subtipo: `pessoa | projeto | ferramenta | tecnologia`)
- **Conceitos** — ideas, patterns, principles, theories discussed

For each, check `wiki/index.md` to determine:
- Does a page already exist? → mark as UPDATE
- No page exists? → mark as CREATE

### Step 4: Handle --discuss or Default Mode

**If `--discuss` flag was given:**
- Present a bullet summary of the top 5–7 takeaways you identified
- Ask: "Quer ajustar o foco, adicionar algo ou remover algum ponto antes de eu criar as páginas?"
- Wait for user response, incorporate feedback, then proceed to Step 5

**Default mode (no flag):**
- Skip the discussion — proceed directly to Step 5
- You will show a summary AFTER writing (Step 7) and offer adjustments then

### Step 5: Present the Write Plan

Before writing any file, show the user a concise plan:

```
📥 Pronto para ingerir: [Título da Fonte]

Vou criar/atualizar:
  📖 CRIAR  wiki/fontes/[timestamp]-[slug].md
  💡 CRIAR  wiki/conceitos/[conceito-1].md
  💡 ATUALIZAR  wiki/conceitos/[conceito-2].md  (adicionar esta fonte)
  🏷️ CRIAR  wiki/entidades/[entidade-1].md
  📚 ATUALIZAR  wiki/index.md  (+N entradas)
  📝 ATUALIZAR  wiki/log.md  (append)

Prosseguir? [s/n ou ajustes]
```

Wait for confirmation. If the user requests changes, adjust the plan and re-present. Only proceed when confirmed.

### Step 6: Write All Files

Execute all writes in this order:
1. `wiki/fontes/[timestamp]-[slug].md` — structured source summary
2. Each new concept page in `wiki/conceitos/`
3. Each new entity page in `wiki/entidades/`
4. Update existing concept/entity pages (append new fonte to `fontes:` frontmatter field and add a note in 📚 Fontes section)
5. Update `wiki/index.md` — add new rows to the correct tables, update `total-paginas` and `atualizado`
6. Append to `wiki/log.md` — new entry with format `## [YYYY-MM-DD] ingest | [Título]`

Read `references/workflow.md` for exact frontmatter templates and section structures for each page type.

**Never modify files in `raw/` (vault root).**

### Step 7: Report Results

After all writes complete, show a summary:

```
✅ Ingestão concluída: [Título]

Páginas criadas (N):
  📖 [[timestamp-slug]] — fonte
  💡 [[conceito-1]] — conceito
  🏷️ [[entidade-1]] — entidade (pessoa)

Páginas atualizadas (N):
  💡 [[conceito-existente]] — fonte adicionada

⚠️ Contradições encontradas: [lista ou "nenhuma"]

Quer ajustar alguma página antes de finalizar?
```

If contradictions were found between this source and existing pages, describe them explicitly and ask how the user wants to handle them.

## Examples

### Example 1: Ingest a file already in the vault

User: `/ingest wiki/raw/building-a-second-brain-notes.md`

Actions:
1. Read the file
2. Extract metadata (title, author, tags)
3. Identify concepts (PKM, PARA method, etc.) and entities (Tiago Forte, Notion, etc.)
4. Check index.md — some may already exist
5. Show write plan, wait for confirmation
6. Write all files
7. Report results

### Example 2: Ingest with discussion

User: `/ingest wiki/raw/clean-architecture.md --discuss`

Actions:
1–3. Same as above
4. Present top takeaways, ask for user input
5. Incorporate feedback into page content
6. Show write plan, wait for confirmation
7. Write all files
8. Report results

### Example 3: Ingest pasted text

User: `/ingest` + pastes article text

Actions:
1. Detect no path given, use pasted text
2. Ask for title, URL, author
3. Proceed with normal workflow from Step 2

## Rules

- **Always show the write plan and wait for confirmation** before writing any file
- **Never modify `raw/` (vault root)** — those files are immutable
- **Always update both `index.md` and `log.md`** — never skip either
- **Never leave frontmatter incomplete** — use "Desconhecido" or `""` for missing fields, never omit keys
- **Contradictions must be noted explicitly** — add an `⚠️ Contradições` section to affected pages
- **Content in Portuguese** — technical terms stay in their original language
- **Slug generation**: lowercase, kebab-case, Portuguese, max 6 words (e.g. `clean-architecture-principios-solid`)
