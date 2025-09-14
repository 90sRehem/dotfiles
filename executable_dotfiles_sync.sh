#!/bin/bash

# Script de Sincronização de Dotfiles
# Cria backup e sincroniza configurações importantes

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Diretório de backup
BACKUP_DIR="$HOME/dotfiles_migration_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Arquivos e diretórios importantes para backup
IMPORTANT_CONFIGS=(
    ".bashrc"
    ".zshrc" 
    ".profile"
    ".gitconfig"
    ".vimrc"
    ".tmux.conf"
    ".ssh"
    ".gnupg"
    ".config/nvim"
    ".config/git"
    ".config/tmux"
    ".config/alacritty"
    ".config/kitty"
    ".config/i3"
    ".config/sway"
    ".config/hypr"
    ".config/waybar"
    ".config/rofi"
    ".config/dunst"
    ".config/fontconfig"
    ".local/share/applications"
    ".mozilla"
    ".thunderbird"
)

# Função para backup
backup_config() {
    local config_path="$1"
    local full_path="$HOME/$config_path"
    
    if [ -e "$full_path" ]; then
        local backup_path="$BACKUP_DIR/$config_path"
        mkdir -p "$(dirname "$backup_path")"
        
        if [ -d "$full_path" ]; then
            cp -r "$full_path" "$backup_path" 2>/dev/null || log_warning "Erro ao copiar diretório $config_path"
        else
            cp "$full_path" "$backup_path" 2>/dev/null || log_warning "Erro ao copiar arquivo $config_path"
        fi
        
        log_success "Backup: $config_path"
    else
        log "Não encontrado: $config_path"
    fi
}

# Função para listar pacotes instalados
list_installed_packages() {
    log "Coletando informações de pacotes instalados..."
    
    # Pacman (explícitos)
    if command -v pacman &> /dev/null; then
        pacman -Qqe > "$BACKUP_DIR/pacman_explicit.txt" 2>/dev/null
        log_success "Lista de pacotes explícitos salva em pacman_explicit.txt"
        
        # Pacotes AUR/foreign
        pacman -Qqm > "$BACKUP_DIR/pacman_aur.txt" 2>/dev/null
        log_success "Lista de pacotes AUR salva em pacman_aur.txt"
        
        # Informações detalhadas
        pacman -Qe > "$BACKUP_DIR/pacman_detailed.txt" 2>/dev/null
        log_success "Informações detalhadas dos pacotes salvas"
    fi
    
    # Flatpak
    if command -v flatpak &> /dev/null; then
        flatpak list --app --columns=application > "$BACKUP_DIR/flatpak_packages.txt" 2>/dev/null
        log_success "Lista de aplicativos Flatpak salva"
    fi
    
    # Snap
    if command -v snap &> /dev/null; then
        snap list | tail -n +2 | awk '{print $1}' > "$BACKUP_DIR/snap_packages.txt" 2>/dev/null
        log_success "Lista de pacotes Snap salva"
    fi
    
    # Node.js packages (npm global)
    if command -v npm &> /dev/null; then
        npm list -g --depth=0 --parseable | sed '1d' | sed 's/.*\///' > "$BACKUP_DIR/npm_global.txt" 2>/dev/null
        log_success "Pacotes npm globais salvos"
    fi
    
    # Python packages (pip)
    if command -v pip &> /dev/null; then
        pip list --format=freeze > "$BACKUP_DIR/pip_packages.txt" 2>/dev/null
        log_success "Pacotes pip salvos"
    fi
    
    # Rust packages (cargo)
    if command -v cargo &> /dev/null; then
        cargo install --list | grep '^[a-zA-Z]' | awk '{print $1}' > "$BACKUP_DIR/cargo_packages.txt" 2>/dev/null
        log_success "Pacotes cargo salvos"
    fi
}

# Função para criar script de restauração
create_restore_script() {
    cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash

# Script de Restauração de Dotfiles
# Restore dotfiles from backup

set -e

BACKUP_DIR="$(dirname "$0")"
TARGET_HOME="$HOME"

echo "Restaurando configurações..."

# Função para restaurar arquivo/diretório
restore_item() {
    local item="$1"
    local source="$BACKUP_DIR/$item"
    local target="$TARGET_HOME/$item"
    
    if [ -e "$source" ]; then
        echo "Restaurando: $item"
        mkdir -p "$(dirname "$target")"
        
        # Backup do existente se houver
        if [ -e "$target" ]; then
            mv "$target" "${target}.backup.$(date +%s)" 2>/dev/null || true
        fi
        
        # Restaurar
        cp -r "$source" "$target"
    fi
}

# Restaurar todos os itens
for item in $(find . -name ".*" -type f -o -name ".*" -type d | sed 's|^\./||' | grep -v '^.$'); do
    if [[ "$item" != "." && "$item" != ".." ]]; then
        restore_item "$item"
    fi
done

echo "Restauração concluída!"
echo "Arquivos originais foram renomeados com sufixo .backup se existiam."
EOF
    
    chmod +x "$BACKUP_DIR/restore.sh"
    log_success "Script de restauração criado: $BACKUP_DIR/restore.sh"
}

# Função principal
main() {
    log "=== Backup de Dotfiles e Configurações ==="
    log "Diretório de backup: $BACKUP_DIR"
    
    # Fazer backup das configurações
    log "Fazendo backup dos arquivos de configuração..."
    for config in "${IMPORTANT_CONFIGS[@]}"; do
        backup_config "$config"
    done
    
    # Listar pacotes instalados
    list_installed_packages
    
    # Informações do sistema
    log "Coletando informações do sistema..."
    uname -a > "$BACKUP_DIR/system_info.txt"
    cat /etc/os-release > "$BACKUP_DIR/os_release.txt" 2>/dev/null || true
    
    # Serviços habilitados (systemd)
    if command -v systemctl &> /dev/null; then
        systemctl --user list-unit-files --state=enabled > "$BACKUP_DIR/user_services.txt" 2>/dev/null || true
        systemctl list-unit-files --state=enabled > "$BACKUP_DIR/system_services.txt" 2>/dev/null || true
        log_success "Lista de serviços habilitados salva"
    fi
    
    # Criar script de restauração
    create_restore_script
    
    # Criar arquivo README
    cat > "$BACKUP_DIR/README.md" << EOF
# Backup de Configurações - $(date)

## Conteúdo do Backup

### Arquivos de Configuração
$(find "$BACKUP_DIR" -name ".*" -type f | sed "s|$BACKUP_DIR/|- |")

### Listas de Pacotes
- \`pacman_explicit.txt\`: Pacotes instalados explicitamente via pacman
- \`pacman_aur.txt\`: Pacotes do AUR
- \`flatpak_packages.txt\`: Aplicativos Flatpak
- \`snap_packages.txt\`: Pacotes Snap
- \`npm_global.txt\`: Pacotes npm globais
- \`pip_packages.txt\`: Pacotes Python (pip)
- \`cargo_packages.txt\`: Pacotes Rust (cargo)

### Scripts
- \`restore.sh\`: Script para restaurar as configurações

## Como usar

### Restaurar configurações:
\`\`\`bash
./restore.sh
\`\`\`

### Instalar pacotes em nova distribuição:
Use o script \`migration_installer.sh\` no diretório pai.

### Instalar pacotes específicos:
\`\`\`bash
# Arch Linux
sudo pacman -S \$(cat pacman_explicit.txt)

# Ubuntu/Debian  
sudo apt install \$(cat pacman_explicit.txt | tr '\\n' ' ')

# Fedora
sudo dnf install \$(cat pacman_explicit.txt | tr '\\n' ' ')
\`\`\`

## Notas
- Arquivos existentes são renomeados com sufixo .backup antes da restauração
- Verifique permissões após restaurar (especialmente ~/.ssh)
- Alguns pacotes podem ter nomes diferentes em outras distribuições
EOF
    
    log_success "Backup concluído!"
    log "Diretório: $BACKUP_DIR"
    log "Total de arquivos: $(find "$BACKUP_DIR" -type f | wc -l)"
    log "Tamanho: $(du -sh "$BACKUP_DIR" | cut -f1)"
    
    echo
    log "Para usar o backup em uma nova máquina:"
    log "1. Copie a pasta $BACKUP_DIR"
    log "2. Execute ./restore.sh para restaurar dotfiles"
    log "3. Execute ../migration_installer.sh para instalar pacotes"
}

main "$@"