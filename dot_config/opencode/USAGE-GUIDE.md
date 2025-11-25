# OpenCode Agent System - Guia de Uso

## 🎯 **Visão Geral**

Sistema de agentes inteligente com delegação automática para desenvolvimento full-stack TypeScript/React/NestJS.

### **Arquitetura:**
```
User Request → workflow-orchestrator → {
  Simple Task → @subagent específico
  Complex Task → @task-manager → delega para @subagents
}
```

## 🚀 **Como Usar**

### **Comando Principal:**
```bash
/workflow "sua solicitação aqui"
```

O `workflow-orchestrator` analisará automaticamente e roteará para o subagent apropriado.

## 🤖 **Subagents Disponíveis**

### **🏗️ Backend: @bounded-context-creator**
**Quando usar:** Criar novos domínios/contextos com Clean Architecture

**Exemplos:**
```bash
/workflow "create user authentication bounded context with login, register and password reset"
/workflow "implement product catalog context with categories, pricing and inventory"
/workflow "create order management domain with status tracking and payments"
```

**O que cria:**
- Domain layer (entities, use-cases, repositories, events)
- Infrastructure layer (controllers, DTOs, services, module)
- Clean Architecture completa

### **🎨 Frontend: @compound-component-builder**
**Quando usar:** Criar componentes UI complexos e reutilizáveis

**Exemplos:**
```bash
/workflow "create data table compound component with sorting, filtering and pagination"
/workflow "build modal dialog component with header, content and actions"
/workflow "implement form builder component with validation and dynamic fields"
```

**O que cria:**
- Compound component com Context API
- Sub-components especializados
- TypeScript interfaces robustas
- Testes automatizados

### **📡 Data Fetching: @react-query-integrator**
**Quando usar:** Configurar data fetching para entidades

**Exemplos:**
```bash
/workflow "setup users data fetching with CRUD operations and search"
/workflow "configure products React Query with infinite scroll and filters"
/workflow "implement orders data layer with real-time updates"
```

**O que cria:**
- Query factories com keys tipadas
- Funções API puras (uso fora do React)
- Hooks especializados
- Cache management

### **✅ Quality: @quality-validator**
**Quando usar:** Validar qualidade do código

**Exemplos:**
```bash
/workflow "validate code quality"
/workflow "run all quality checks before deploy"
```

**O que executa:**
- TypeScript validation
- Biome linting/formatting
- Tests execution
- Build validation

## 📋 **Workflows Complexos**

### **Feature Completa (Full-Stack):**

```bash
# 1. Solicitar feature complexa
/workflow "implement complete product review system with ratings, comments and moderation"

# O task-manager quebrará em subtasks e delegará:
# Task 01: @bounded-context-creator → Backend domain
# Task 02: @compound-component-builder → Frontend components  
# Task 03: @react-query-integrator → Data fetching
# Task 04: @quality-validator → Validation
```

### **Frontend Focus:**
```bash
/workflow "create advanced dashboard with widgets, charts and real-time data"
```

### **Backend Focus:**
```bash
/workflow "implement microservice for payment processing with events and saga patterns"
```

## 🎛️ **Controle Avançado**

### **Especificar Detalhes:**
```bash
/workflow "create e-commerce shopping cart with items management, discounts calculation, shipping estimation and checkout flow integration"
```

### **Incluir Requisitos Técnicos:**
```bash
/workflow "build file uploader component with drag-drop interface, preview thumbnails, progress tracking, size validation and AWS S3 integration"
```

### **Workflows de Qualidade:**
```bash
/workflow "validate entire codebase before production deployment"
/workflow "run security audit and performance checks"
```

## 📊 **Monitoramento de Progresso**

### **Task Tracking:**
Os tasks complexos são salvos em:
```
tasks/subtasks/{feature-name}/
├── README.md (índice com checkboxes)
├── 01-task-name.md
├── 02-task-name.md
└── ...
```

### **Status Reports:**
Cada subagent retorna relatórios estruturados:
```
✅ {Subagent} Complete: {feature-name}
📁 Structure: {arquivos criados}
🔧 Components: {componentes implementados}
📋 Next Steps: {próximas ações}
```

## 🛠️ **Debugging e Personalização**

### **Ver Agentes Disponíveis:**
```bash
ls ~/.config/opencode/agent/subagents/
```

### **Verificar Contextos:**
```bash
ls ~/.config/opencode/context/
```

### **Logs de Execução:**
O OpenCode mantém logs das execuções para debugging.

## 💡 **Dicas de Uso Eficiente**

### **✅ Boas Práticas:**

1. **Seja específico:** "product catalog with search and filters" > "product stuff"
2. **Inclua contexto:** "user profile with avatar upload and preferences"
3. **Mencione integrações:** "order tracking with email notifications"
4. **Use linguagem natural:** O roteamento é inteligente

### **🎯 Padrões de Requests Eficazes:**

```bash
# Backend - Bounded Context
"create {domain} bounded context with {entities} and {features}"

# Frontend - Compound Component  
"build {component} component with {sub-features} and {interactions}"

# Data - React Query
"setup {entity} data fetching with {operations} and {features}"

# Quality - Validation
"validate {scope} quality" ou "check {specific aspect}"
```

### **🔄 Workflow Típico:**

1. **Start:** `/workflow "feature description"`
2. **Monitor:** Acompanhe outputs dos subagents
3. **Validate:** Use `/workflow "validate quality"`
4. **Iterate:** Refine based on reports

## 🚀 **Próximos Passos**

1. **Experimente:** Comece com uma feature simples
2. **Observe:** Veja como o roteamento funciona
3. **Refine:** Ajuste prompts baseado nos resultados
4. **Scale:** Use para features complexas

O sistema está otimizado para seus padrões de desenvolvimento e pronto para acelerar significativamente sua produtividade! 🔥