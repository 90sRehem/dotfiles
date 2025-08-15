#!/bin/bash

# Script de instalação automática de pacotes para Arch Linux
# Este script roda apenas uma vez quando chezmoi é aplicado

set -e  # Para se houver erro

echo "🚀 Iniciando instalação de pacotes essenciais..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log_info() {
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

# Verificar se está no Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    log_error "Este script é específico para Arch Linux!"
    exit 1
fi

# Verificar se yay está instalado
if ! command -v yay &> /dev/null; then
    log_warning "yay não encontrado. Instalando..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
    log_success "yay instalado!"
fi

# Atualizar sistema
log_info "Atualizando sistema..."
yay -Syu --noconfirm

# Pacotes essenciais do sistema
ESSENTIAL_PACKAGES=(
    "zsh"                    # Shell
    "tmux"                   # Terminal multiplexer
    "neovim"                 # Editor
    "git"                    # Controle de versão
    "curl"                   # Download tool
    "wget"                   # Download tool
    "unzip"                  # Compressão
    "tree"                   # Visualizar diretórios
    "htop"                   # Monitor de processos
    "btop"                   # Monitor moderno
    "fastfetch"              # System info
    "ripgrep"                # Busca rápida
    "fd"                     # Find alternativo
    "bat"                    # Cat com syntax highlight
    "exa"                    # ls moderno
    "fzf"                    # Fuzzy finder
    "mise"                   # Runtime version manager
)

# Pacotes de interface (Wayland/Desktop)
DESKTOP_PACKAGES=(
    "hyprland"               # Wayland compositor
    "waybar"                 # Status bar
    "alacritty"              # Terminal
    "zen-browser-bin"        # Modern browser
    "firefox"                # Browser
    "thunar"                 # File manager
    "code"                   # VS Code
    "bitwarden"              # Password manager
)

# Pacotes de desenvolvimento
DEV_PACKAGES=(
    "nodejs"                 # JavaScript runtime
    "npm"                    # Node package manager
    "python"                 # Python
    "python-pip"             # Python package manager
    "docker"                 # Containers
    "docker-compose"         # Docker orchestration
    "github-cli"             # GitHub CLI
)

# Pacotes de mídia e utilitários
MEDIA_PACKAGES=(
    "vlc"                    # Media player
    "gimp"                   # Image editor
    "obs-studio"             # Screen recording
    "discord"                # Chat
    "spotify"                # Music
)

# Função para instalar pacotes
install_packages() {
    local packages=("$@")
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        log_info "Instalando $package..."
        if yay -S --needed --noconfirm "$package"; then
            log_success "$package instalado!"
        else
            log_error "Falha ao instalar $package"
            failed_packages+=("$package")
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warning "Pacotes que falharam: ${failed_packages[*]}"
    fi
}

# Instalar pacotes por categoria
log_info "Instalando pacotes essenciais..."
install_packages "${ESSENTIAL_PACKAGES[@]}"

log_info "Instalando pacotes de desktop..."
install_packages "${DESKTOP_PACKAGES[@]}"

log_info "Instalando pacotes de desenvolvimento..."
install_packages "${DEV_PACKAGES[@]}"

# Perguntar sobre pacotes de mídia (opcionais)
echo
read -p "Deseja instalar pacotes de mídia (Discord, Spotify, etc.)? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Instalando pacotes de mídia..."
    install_packages "${MEDIA_PACKAGES[@]}"
fi

# Configurações pós-instalação
log_info "Configurando sistema..."

# Configurar zsh como shell padrão
if command -v zsh &> /dev/null; then
    if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
        log_info "Configurando zsh como shell padrão..."
        chsh -s /usr/bin/zsh
        log_success "zsh configurado como shell padrão!"
    fi
fi

# Habilitar Docker (se instalado)
if command -v docker &> /dev/null; then
    log_info "Habilitando Docker..."
    sudo systemctl enable docker
    sudo usermod -aG docker "$USER"
    log_success "Docker habilitado! (reboot necessário para usar sem sudo)"
fi

# Instalar Oh My Zsh (se zsh estiver instalado e OMZ não existir)
if command -v zsh &> /dev/null && [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_info "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh instalado!"
fi

# Instalar plugins do zsh
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    # zsh-autosuggestions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        log_info "Instalando zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Instalando zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi
fi

# Configurar mise (se instalado)
if command -v mise &> /dev/null; then
    log_info "Configurando mise..."
    # Adicionar mise ao shell
    if ! grep -q 'mise activate' "$HOME/.zshrc" 2>/dev/null; then
        echo 'eval "$(mise activate zsh)"' >> "$HOME/.zshrc"
        log_success "mise adicionado ao .zshrc!"
    fi
fi

echo
log_success "🎉 Instalação concluída!"
log_info "Reinicie o terminal ou faça logout/login para aplicar todas as mudanças."
log_info "Para usar Docker sem sudo, faça reboot do sistema."

echo
echo "📋 Próximos passos manuais:"
echo "  1. Configurar Git: git config --global user.name 'Seu Nome'"
echo "  2. Configurar Git: git config --global user.email 'seu@email.com'"
echo "  3. Configurar SSH keys para GitHub"
echo "  4. Personalizar configurações do Neovim"
echo "  5. Configurar Bitwarden e fazer login"
echo "  6. Instalar runtimes com mise: mise install node@latest python@latest"