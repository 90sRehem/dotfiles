#!/bin/bash

# Sistema de Migração de Pacotes - Multi-Distribuição
# Gerado automaticamente para migração do Arch Linux

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para detectar a distribuição
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    elif type lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

# Função para log
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Função para instalar pacotes baseado na distribuição
install_packages() {
    local distro=$1
    local package_list="$2"
    
    case $distro in
        ubuntu|debian|linuxmint|pop)
            log "Instalando pacotes via apt..."
            sudo apt update
            echo "$package_list" | while read -r pkg; do
                if [ ! -z "$pkg" ]; then
                    sudo apt install -y "$pkg" 2>/dev/null || log_warning "Pacote '$pkg' não encontrado no APT"
                fi
            done
            ;;
        fedora|centos|rhel)
            log "Instalando pacotes via dnf/yum..."
            if command -v dnf &> /dev/null; then
                PKG_MGR="dnf"
            else
                PKG_MGR="yum"
            fi
            echo "$package_list" | while read -r pkg; do
                if [ ! -z "$pkg" ]; then
                    sudo $PKG_MGR install -y "$pkg" 2>/dev/null || log_warning "Pacote '$pkg' não encontrado no $PKG_MGR"
                fi
            done
            ;;
        opensuse*|sles)
            log "Instalando pacotes via zypper..."
            echo "$package_list" | while read -r pkg; do
                if [ ! -z "$pkg" ]; then
                    sudo zypper install -y "$pkg" 2>/dev/null || log_warning "Pacote '$pkg' não encontrado no zypper"
                fi
            done
            ;;
        arch|manjaro)
            log "Instalando pacotes via pacman..."
            echo "$package_list" | while read -r pkg; do
                if [ ! -z "$pkg" ]; then
                    sudo pacman -S --noconfirm "$pkg" 2>/dev/null || log_warning "Pacote '$pkg' não encontrado no pacman"
                fi
            done
            ;;
        *)
            log_error "Distribuição '$distro' não suportada automaticamente"
            log "Lista de pacotes para instalação manual:"
            echo "$package_list"
            return 1
            ;;
    esac
}

# Função para instalar AUR helper se necessário
install_aur_helper() {
    local distro=$1
    
    if [[ "$distro" == "arch" || "$distro" == "manjaro" ]]; then
        if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
            log "Instalando yay (AUR helper)..."
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            cd /tmp/yay
            makepkg -si --noconfirm
            cd -
            rm -rf /tmp/yay
        fi
    fi
}

# Lista de pacotes oficiais do sistema original
OFFICIAL_PACKAGES='$(cat /tmp/explicit_packages.txt | grep -v -f /tmp/foreign_packages.txt | tr "\n" " ")'

# Lista de pacotes AUR/Foreign
AUR_PACKAGES='$(cat /tmp/foreign_packages.txt | tr "\n" " ")'

# Mapeamento de pacotes comuns entre distribuições
create_package_mapping() {
    cat > /tmp/package_mapping.txt << 'EOF'
# Formato: arch_package:debian_package:fedora_package:opensuse_package
firefox:firefox:firefox:firefox
git:git:git:git
vim:vim:vim:vim
neovim:neovim:neovim:neovim
tmux:tmux:tmux:tmux
htop:htop:htop:htop
wget:wget:wget:wget
curl:curl:curl:curl
nodejs:nodejs:nodejs:nodejs
npm:npm:npm:npm
python:python3:python3:python3
python-pip:python3-pip:python3-pip:python3-pip
docker:docker.io:docker:docker
docker-compose:docker-compose:docker-compose:docker-compose
code:code:code:code
chromium:chromium-browser:chromium:chromium
libreoffice:libreoffice:libreoffice:libreoffice
gimp:gimp:gimp:gimp
vlc:vlc:vlc:vlc
discord:discord:discord:discord
spotify:spotify-client:spotify:spotify
zoom:zoom:zoom:zoom
teams:teams:teams:teams
slack-desktop:slack-desktop:slack:slack
telegram-desktop:telegram-desktop:telegram:telegram-desktop
whatsapp-nativefier:whatsapp-desktop:whatsapp:whatsapp-desktop
EOF
}

# Função para mapear nomes de pacotes
map_package_name() {
    local arch_pkg=$1
    local target_distro=$2
    local col=2  # Default para debian/ubuntu
    
    case $target_distro in
        fedora|centos|rhel) col=3 ;;
        opensuse*|sles) col=4 ;;
    esac
    
    mapped=$(grep "^$arch_pkg:" /tmp/package_mapping.txt 2>/dev/null | cut -d: -f$col)
    if [ -n "$mapped" ]; then
        echo "$mapped"
    else
        echo "$arch_pkg"  # Retorna o nome original se não encontrou mapeamento
    fi
}

# Função para backup de dotfiles
backup_dotfiles() {
    log "Criando backup dos dotfiles..."
    
    mkdir -p ~/dotfiles_backup
    
    # Lista de arquivos/diretórios comuns para backup
    DOTFILES=(
        ".bashrc"
        ".zshrc"
        ".vimrc"
        ".gitconfig"
        ".tmux.conf"
        ".ssh"
        ".config"
        ".local"
    )
    
    for dotfile in "${DOTFILES[@]}"; do
        if [ -e ~/"$dotfile" ]; then
            cp -r ~/"$dotfile" ~/dotfiles_backup/ 2>/dev/null || log_warning "Erro ao copiar $dotfile"
            log_success "Backup de $dotfile criado"
        fi
    done
}

# Função principal
main() {
    log "=== Sistema de Migração de Pacotes ==="
    log "Sistema original: Arch Linux"
    log "Pacotes explícitos encontrados: $(echo $OFFICIAL_PACKAGES | wc -w)"
    log "Pacotes AUR encontrados: $(echo $AUR_PACKAGES | wc -w)"
    
    # Detectar distribuição atual
    CURRENT_DISTRO=$(detect_distro)
    log "Distribuição detectada: $CURRENT_DISTRO"
    
    # Criar mapeamento de pacotes
    create_package_mapping
    
    # Fazer backup dos dotfiles se solicitado
    read -p "Deseja fazer backup dos arquivos de configuração? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        backup_dotfiles
    fi
    
    # Instalar pacotes oficiais
    if [ ! -z "$OFFICIAL_PACKAGES" ]; then
        log "Instalando pacotes oficiais..."
        
        # Mapear nomes de pacotes para a distribuição atual
        MAPPED_PACKAGES=""
        for pkg in $OFFICIAL_PACKAGES; do
            mapped_pkg=$(map_package_name "$pkg" "$CURRENT_DISTRO")
            MAPPED_PACKAGES="$MAPPED_PACKAGES$mapped_pkg\n"
        done
        
        echo -e "$MAPPED_PACKAGES" | install_packages "$CURRENT_DISTRO"
    fi
    
    # Instalar pacotes AUR (somente em distribuições baseadas em Arch)
    if [[ "$CURRENT_DISTRO" == "arch" || "$CURRENT_DISTRO" == "manjaro" ]]; then
        if [ ! -z "$AUR_PACKAGES" ]; then
            install_aur_helper "$CURRENT_DISTRO"
            
            log "Instalando pacotes AUR..."
            for pkg in $AUR_PACKAGES; do
                if command -v yay &> /dev/null; then
                    yay -S --noconfirm "$pkg" 2>/dev/null || log_warning "Pacote AUR '$pkg' não pôde ser instalado"
                elif command -v paru &> /dev/null; then
                    paru -S --noconfirm "$pkg" 2>/dev/null || log_warning "Pacote AUR '$pkg' não pôde ser instalado"
                fi
            done
        fi
    else
        if [ ! -z "$AUR_PACKAGES" ]; then
            log_warning "Pacotes AUR encontrados, mas não podem ser instalados automaticamente em $CURRENT_DISTRO:"
            echo "$AUR_PACKAGES"
            log "Você precisará encontrar equivalentes ou compilar manualmente."
        fi
    fi
    
    log_success "Migração concluída!"
    log "Verifique os logs acima para pacotes que não puderam ser instalados."
    
    # Limpeza
    rm -f /tmp/package_mapping.txt
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi