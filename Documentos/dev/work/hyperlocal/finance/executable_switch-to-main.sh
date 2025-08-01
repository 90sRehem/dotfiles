#!/bin/bash

# Script para mudar todos os repositórios para a branch main
echo "🔄 Mudando todos os repositórios para a branch main..."

# Contadores para o resumo
success_count=0
error_count=0
skipped_count=0

for dir in ~/Documentos/dev/work/hyperlocal/finance/*/; do
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        echo ""
        echo "📁 Processando: $(basename "$dir")"
        cd "$dir"
        
        # Verifica se está em um repositório git
        if git rev-parse --git-dir > /dev/null 2>&1; then
            current_branch=$(git branch --show-current)
            echo "  📋 Branch atual: $current_branch"
            
            # Se já está na main, pula
            if [ "$current_branch" = "main" ]; then
                echo "  ✅ Já está na branch main"
                ((success_count++))
                continue
            fi
            
            # Verifica se há mudanças não commitadas
            if ! git diff-index --quiet HEAD -- 2>/dev/null; then
                echo "  ⚠️  Há mudanças não commitadas, fazendo stash..."
                if git stash push -m "Auto stash before switching to main - $(date)"; then
                    echo "  📦 Mudanças salvas no stash"
                    stashed=true
                else
                    echo "  ❌ Erro ao fazer stash, pulando este repositório"
                    ((error_count++))
                    continue
                fi
            else
                stashed=false
            fi
            
            # Verifica se há arquivos não rastreados
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                echo "  📄 Arquivos não rastreados encontrados (serão mantidos)"
            fi
            
            # Verifica se a branch main existe localmente
            if git show-ref --verify --quiet refs/heads/main; then
                echo "  ✅ Mudando para branch main"
                if git checkout main; then
                    echo "  🎯 Mudança para main realizada com sucesso"
                    ((success_count++))
                    
                    # Restaura o stash se foi criado
                    if [ "$stashed" = true ]; then
                        echo "  📦 Restaurando mudanças do stash..."
                        if git stash pop; then
                            echo "  ✅ Stash restaurado com sucesso"
                        else
                            echo "  ⚠️  Conflito ao restaurar stash - resolva manualmente"
                            echo "  💡 Use: git stash list && git stash apply"
                        fi
                    fi
                else
                    echo "  ❌ Erro ao mudar para branch main"
                    ((error_count++))
                    # Restaura o stash em caso de erro
                    if [ "$stashed" = true ]; then
                        echo "  📦 Restaurando stash devido ao erro..."
                        git stash pop
                    fi
                fi
            elif git show-ref --verify --quiet refs/remotes/origin/main; then
                echo "  ✅ Criando e mudando para branch main (tracking origin/main)"
                if git checkout -b main origin/main; then
                    echo "  🎯 Branch main criada e checkout realizado com sucesso"
                    ((success_count++))
                    
                    # Restaura o stash se foi criado
                    if [ "$stashed" = true ]; then
                        echo "  📦 Restaurando mudanças do stash..."
                        if git stash pop; then
                            echo "  ✅ Stash restaurado com sucesso"
                        else
                            echo "  ⚠️  Conflito ao restaurar stash - resolva manualmente"
                            echo "  💡 Use: git stash list && git stash apply"
                        fi
                    fi
                else
                    echo "  ❌ Erro ao criar branch main"
                    ((error_count++))
                    # Restaura o stash em caso de erro
                    if [ "$stashed" = true ]; then
                        echo "  📦 Restaurando stash devido ao erro..."
                        git stash pop
                    fi
                fi
            else
                echo "  ⚠️  Branch main não encontrada (local nem remota)"
                echo "  📋 Mantendo branch atual: $current_branch"
                ((skipped_count++))
                
                # Restaura o stash se foi criado
                if [ "$stashed" = true ]; then
                    echo "  📦 Restaurando stash..."
                    git stash pop
                fi
            fi
        else
            echo "  ❌ Não é um repositório git"
            ((skipped_count++))
        fi
    fi
done

echo ""
echo "📊 Resumo do processo:"
echo "  ✅ Sucessos: $success_count"
echo "  ❌ Erros: $error_count"  
echo "  ⚠️  Pulados: $skipped_count"
echo ""
if [ $error_count -eq 0 ]; then
    echo "✅ Processo concluído com sucesso!"
else
    echo "⚠️  Processo concluído com alguns erros. Verifique os repositórios marcados com ❌"
fi