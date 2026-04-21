# LLM Wiki Ingest — Templates e Referência

Referência completa de frontmatter e estrutura de seções para cada tipo de página criada durante o INGEST.

---

## Vault Root

`/home/rehem/Documents/obsidian/`

- Raw sources (immutable): `raw/` — at vault root, never modify
- Wiki (LLM writes): `wiki/` — at vault root

---

## Geração de Timestamp e Slug

**Timestamp:** Unix timestamp do dia atual (segundos). Exemplo para 2026-04-15: `1776124800`

**Slug:** kebab-case, português, máximo 6 palavras, sem artigos curtos (o, a, de, do, da).
- "Building a Second Brain — Notes" → `building-second-brain-notas`
- "Clean Architecture: A Craftsman's Guide" → `clean-architecture-guia-artesao`
- "React Performance Optimization" → `react-performance-otimizacao`

**Nome do arquivo de fonte:** `[timestamp]-[slug].md`

---

## Template: Página de Fonte (`wiki/fontes/`)

```markdown
---
tipo: fonte
subtipo: artigo | livro | video | podcast | paper
autor: Nome do Autor
data-original: YYYY-MM-DD
ingerido: YYYY-MM-DD
tags:
  - tag-1
  - tag-2
url: "https://..." ou ""
paginas-atualizadas:
  - "[[conceito-1]]"
  - "[[entidade-1]]"
---

# [Título em Português]

## 📋 Visão Geral

[2–4 frases resumindo o que é a fonte, seu contexto e relevância.]

## 🎯 Pontos Principais

- **[Ponto 1]** — [explicação concisa]
- **[Ponto 2]** — [explicação concisa]
- **[Ponto 3]** — [explicação concisa]
[4–8 pontos no total]

## 🏗️ [Seção de Conteúdo Principal]

[Seção com o conteúdo mais denso da fonte. Pode ser renomeada conforme o tema:
"Arquitetura", "Metodologia", "Conceitos Centrais", "Argumentos", etc.]

### [Subseção se necessário]

[Conteúdo]

## 💡 Insights e Aplicações

[O que é acionável ou aplicável a partir desta fonte. Pode incluir exemplos práticos.]

## ⚠️ Contradições

[Se houver contradições com páginas existentes no wiki, liste aqui.
Se não houver: omitir esta seção.]

## 🔗 Relacionados

- [[conceito-1]] — [relação]
- [[entidade-1]] — [relação]
[Todos os wikilinks para páginas criadas/atualizadas neste ingest]

## 📚 Fonte

[Citação completa: Autor. "Título". URL se disponível. Data.]
```

---

## Template: Página de Conceito (`wiki/conceitos/`)

```markdown
---
tipo: conceito
tags:
  - tag-1
  - tag-2
fontes:
  - "[[timestamp-slug-da-fonte]]"
criado: YYYY-MM-DD
atualizado: YYYY-MM-DD
---

# [Nome do Conceito]

## 📋 Visão Geral

[2–3 frases definindo o conceito claramente.]

## 🎯 [Seção Principal — renomear conforme o conceito]

[Conteúdo central. Exemplos de nomes: "Ideia Central", "Como Funciona",
"Princípios", "Argumentos", "Metodologia".]

## 🔗 Relacionados

- [[conceito-relacionado]] — [relação]
- [[entidade-relacionada]] — [relação]

## 📚 Fontes

- [[timestamp-slug-da-fonte]]
```

**Ao ATUALIZAR uma página de conceito existente:**
1. Adicionar o novo slug à lista `fontes:` no frontmatter
2. Atualizar `atualizado:` para a data de hoje
3. Incorporar novos insights ao corpo (não substituir — enriquecer)
4. Adicionar o novo wikilink em `## 📚 Fontes`
5. Se houver contradição com conteúdo existente, adicionar seção `## ⚠️ Contradições`

---

## Template: Página de Entidade (`wiki/entidades/`)

```markdown
---
tipo: entidade
subtipo: pessoa | projeto | ferramenta | tecnologia
tags:
  - tag-1
  - tag-2
fontes:
  - "[[timestamp-slug-da-fonte]]"
criado: YYYY-MM-DD
atualizado: YYYY-MM-DD
status: ativo | arquivado
---

# [Nome da Entidade]

## 📋 Visão Geral

[2–3 frases descrevendo a entidade.]

## 🎯 [Seção Principal — renomear conforme subtipo]

[Para pessoa: "Contribuições Relevantes" ou "Papel no Contexto"
Para projeto: "O que é" ou "Funcionalidades"
Para ferramenta: "Características" ou "Uso no Contexto"
Para tecnologia: "Como Funciona" ou "Casos de Uso"]

## 🔗 Relacionados

- [[conceito-relacionado]] — [relação]
- [[entidade-relacionada]] — [relação]

## 📚 Fontes

- [[timestamp-slug-da-fonte]]
```

**Ao ATUALIZAR uma página de entidade existente:**
- Mesmas regras da atualização de conceito acima

---

## Template: Entrada no `wiki/log.md`

Sempre append — nunca editar entradas anteriores.

```markdown
## [YYYY-MM-DD] ingest | [Título da Fonte]

Fonte ingerida: [subtipo] de [autor] ([url ou "sem URL"]).

**Páginas criadas (N):**
- 📖 [[timestamp-slug]] — resumo da fonte
- 💡 [[conceito-1]] — [descrição de uma linha]
- 🏷️ [[entidade-1]] — entidade ([subtipo])

**Páginas atualizadas (N):**
- 💡 [[conceito-existente]] — fonte adicionada
- 🏷️ [[entidade-existente]] — fonte adicionada

**Contradições encontradas:** [lista ou "nenhuma"]
```

---

## Atualização do `wiki/index.md`

### Localizar a seção correta:
- Fontes → tabela `## 📖 Fontes`
- Entidades → tabela `## 🏷️ Entidades`
- Conceitos → tabela `## 💡 Conceitos`
- Sínteses → tabela `## 🔬 Sínteses`

### Formato de linha para cada tabela:

**Fontes:**
```
| [[timestamp-slug]] | subtipo | #tag1 #tag2 | Resumo de uma linha | YYYY-MM-DD |
```

**Entidades:**
```
| [[nome-entidade]] | subtipo | #tag1 #tag2 | Resumo de uma linha | YYYY-MM-DD |
```

**Conceitos:**
```
| [[nome-conceito]] | #tag1 #tag2 | Resumo de uma linha | YYYY-MM-DD |
```

### Atualizar o frontmatter do index:
```yaml
atualizado: YYYY-MM-DD
total-paginas: [incrementar pelo número de páginas CRIADAS]
```

E a linha de stats no corpo:
```
**Total de páginas:** N | **Última atualização:** YYYY-MM-DD
```

---

## Regras de Nomenclatura

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Fonte | `TIMESTAMP-slug-kebab.md` | `1776124800-clean-architecture.md` |
| Conceito | `nome-kebab.md` | `inversao-de-dependencia.md` |
| Entidade (pessoa) | `nome-sobrenome.md` | `robert-martin.md` |
| Entidade (ferramenta/projeto) | `nome-kebab.md` | `spring-boot.md` |
| Síntese | `TIMESTAMP-slug-pergunta.md` | `1776124800-quando-usar-microservicos.md` |

---

## Checklist de Qualidade Pós-Ingest

Antes de reportar conclusão ao usuário, verificar:

- [ ] Frontmatter completo em todas as páginas criadas (sem campos omitidos)
- [ ] Wikilinks bidirecionais — se A linka B, B linka A
- [ ] `index.md` atualizado com todas as páginas novas
- [ ] `log.md` tem nova entrada append-only
- [ ] Contradições documentadas nas páginas afetadas (se houver)
- [ ] Nenhum arquivo em `wiki/raw/` foi modificado
- [ ] `total-paginas` no frontmatter do index está correto
