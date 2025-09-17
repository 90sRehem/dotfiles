#!/bin/bash

# Script para fazer git pull em todos os repositórios
echo "⬇️  Fazendo git pull em todos os repositórios..."

for dir in ~/Documentos/dev/work/hyperlocal/finance/*/; do
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        echo ""
        echo "📁 Processando: $(basename "$dir")"
        cd "$dir"
        
        # Verifica se está em um repositório git
        if git rev-parse --git-dir > /dev/null 2>&1; then
            current_branch=$(git branch --show-current)
            echo "  📋 Branch atual: $current_branch"
            
            # Verifica se há mudanças não commitadas
            if ! git diff-index --quiet HEAD --; then
                echo "  ⚠️  Há mudanças não commitadas, fazendo stash..."
                git stash push -m "Auto stash before pull - $(date)"
                stashed=true
            else
                stashed=false
            fi
            
            # Faz o pull
            echo "  ⬇️  Fazendo git pull..."
            if git pull; then
                echo "  ✅ Pull realizado com sucesso"
                
                # Restaura o stash se foi criado
                if [ "$stashed" = true ]; then
                    echo "  📦 Restaurando mudanças do stash..."
                    git stash pop
                fi
            else
                echo "  ❌ Erro ao fazer pull"
            fi
        else
            echo "  ❌ Não é um repositório git"
        fi
    fi
done

echo ""
echo "✅ Processo concluído!"