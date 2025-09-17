#!/bin/bash

# Script para instalar dependências em todos os projetos
echo "📦 Instalando dependências em todos os projetos..."

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para instalar dependências com verificação do package manager
install_dependencies() {
    local package_manager="$1"
    local lock_file="$2"
    local emoji="$3"
    
    if command_exists "$package_manager"; then
        echo "  $emoji Usando $package_manager para instalar dependências..."
        if $package_manager install; then
            echo "  ✅ Dependências instaladas com sucesso ($package_manager)"
            return 0
        else
            echo "  ❌ Erro ao instalar dependências com $package_manager"
            return 1
        fi
    else
        echo "  ❌ ERRO: $package_manager não está instalado na máquina!"
        echo "  💡 Para instalar $package_manager:"
        case "$package_manager" in
            "yarn")
                echo "     npm install -g yarn"
                ;;
            "pnpm")
                echo "     npm install -g pnpm"
                ;;
            "npm")
                echo "     Node.js precisa ser instalado (npm vem junto)"
                ;;
        esac
        return 1
    fi
}

for dir in ~/Documentos/dev/work/hyperlocal/finance/*/; do
    if [ -d "$dir" ]; then
        echo ""
        echo "📁 Processando: $(basename "$dir")"
        cd "$dir"
        
        # Verifica se tem package.json
        if [ -f "package.json" ]; then
            # Detecta o package manager baseado nos lock files
            if [ -f "pnpm-lock.yaml" ]; then
                install_dependencies "pnpm" "pnpm-lock.yaml" "🟡"
            elif [ -f "yarn.lock" ]; then
                install_dependencies "yarn" "yarn.lock" "🧶"
            elif [ -f "package-lock.json" ]; then
                install_dependencies "npm" "package-lock.json" "📦"
            else
                echo "  🤔 Nenhum lock file encontrado, tentando detectar package manager preferido..."
                
                # Tenta pnpm primeiro (mais rápido)
                if command_exists "pnpm"; then
                    echo "  🟡 Usando pnpm (detectado automaticamente)..."
                    if pnpm install; then
                        echo "  ✅ Dependências instaladas com sucesso (pnpm)"
                    else
                        echo "  ❌ Erro ao instalar dependências com pnpm"
                    fi
                # Depois yarn
                elif command_exists "yarn"; then
                    echo "  🧶 Usando yarn (detectado automaticamente)..."
                    if yarn install; then
                        echo "  ✅ Dependências instaladas com sucesso (yarn)"
                    else
                        echo "  ❌ Erro ao instalar dependências com yarn"
                    fi
                # Por último npm (sempre disponível com Node.js)
                elif command_exists "npm"; then
                    echo "  📦 Usando npm (detectado automaticamente)..."
                    if npm install; then
                        echo "  ✅ Dependências instaladas com sucesso (npm)"
                    else
                        echo "  ❌ Erro ao instalar dependências com npm"
                    fi
                else
                    echo "  ❌ ERRO: Nenhum package manager encontrado!"
                    echo "  💡 Instale pelo menos um dos seguintes:"
                    echo "     - Node.js (inclui npm)"
                    echo "     - yarn: npm install -g yarn"
                    echo "     - pnpm: npm install -g pnpm"
                fi
            fi
        else
            echo "  ⚠️  Não encontrado package.json, pulando..."
        fi
    fi
done

echo ""
echo "✅ Processo concluído!"