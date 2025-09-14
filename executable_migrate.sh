#!/bin/bash

# Script Principal de Migração
# Coordena o processo completo de migração

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo -e "${BOLD}${BLUE}=================================="
    echo -e "  Sistema de Migração Linux"
    echo -e "=================================="
    echo -e "Arch Linux → Qualquer Distribuição${NC}"
    echo
}

show_menu() {
    echo -e "${YELLOW}Escolha uma opção:${NC}"
    echo
    echo "1) 📦 Fazer backup completo (dotfiles + listas de pacotes)"
    echo "2) 🚀 Instalar pacotes na distribuição atual"  
    echo "3) 📋 Visualizar pacotes que serão migrados"
    echo "4) 🔄 Processo completo (backup + instalação)"
    echo "5) ❌ Sair"
    echo
}

show_package_summary() {
    echo -e "${BLUE}=== Resumo dos Pacotes ===${NC}"
    
    if [ -f /tmp/explicit_packages.txt ]; then
        local explicit_count=$(wc -l < /tmp/explicit_packages.txt)
        echo -e "Pacotes oficiais: ${GREEN}$explicit_count${NC}"
        
        echo -e "\n${YELLOW}Alguns exemplos:${NC}"
        head -10 /tmp/explicit_packages.txt | while read pkg; do
            echo "  • $pkg"
        done
        if [ $explicit_count -gt 10 ]; then
            echo "  ... e mais $((explicit_count - 10)) pacotes"
        fi
    fi
    
    if [ -f /tmp/foreign_packages.txt ] && [ -s /tmp/foreign_packages.txt ]; then
        local aur_count=$(wc -l < /tmp/foreign_packages.txt)
        echo -e "\nPacotes AUR: ${GREEN}$aur_count${NC}"
        
        echo -e "\n${YELLOW}Pacotes AUR encontrados:${NC}"
        cat /tmp/foreign_packages.txt | while read pkg; do
            echo "  • $pkg"
        done
    fi
    
    echo
}

backup_process() {
    echo -e "${GREEN}Iniciando processo de backup...${NC}"
    "$SCRIPT_DIR/dotfiles_sync.sh"
    echo -e "${GREEN}✓ Backup concluído!${NC}"
}

install_process() {
    echo -e "${GREEN}Iniciando instalação de pacotes...${NC}"
    "$SCRIPT_DIR/migration_installer.sh"
    echo -e "${GREEN}✓ Instalação concluída!${NC}"
}

complete_process() {
    echo -e "${GREEN}Iniciando processo completo de migração...${NC}"
    echo
    backup_process
    echo
    read -p "Pressione Enter para continuar com a instalação de pacotes..." -r
    echo
    install_process
}

# Função principal
main() {
    print_header
    
    # Verificar se os scripts existem
    if [ ! -f "$SCRIPT_DIR/migration_installer.sh" ] || [ ! -f "$SCRIPT_DIR/dotfiles_sync.sh" ]; then
        echo -e "${RED}Erro: Scripts não encontrados no diretório atual${NC}"
        exit 1
    fi
    
    while true; do
        show_menu
        
        read -p "Digite sua escolha [1-5]: " choice
        echo
        
        case $choice in
            1)
                backup_process
                echo
                read -p "Pressione Enter para continuar..." -r
                ;;
            2)
                install_process
                echo
                read -p "Pressione Enter para continuar..." -r
                ;;
            3)
                show_package_summary
                read -p "Pressione Enter para continuar..." -r
                ;;
            4)
                complete_process
                echo
                read -p "Pressione Enter para continuar..." -r
                ;;
            5)
                echo -e "${GREEN}Saindo...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opção inválida. Tente novamente.${NC}"
                echo
                ;;
        esac
    done
}

# Verificar se está sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi