# 🏠 Dotfiles - Sistema de Configuração Pessoal

Sistema completo de dotfiles e migração para Arch Linux gerenciado com [chezmoi](https://www.chezmoi.io/).

## 🚀 Instalação Rápida - Nova Máquina

### Pré-requisitos
```bash
# Arch Linux - instalar dependências mínimas
sudo pacman -S git base-devel chezmoi
```

### Aplicar Configurações
```bash
# Clonar e aplicar configurações da branch arch
chezmoi init --apply https://github.com/90sRehem/dotfiles.git --branch arch

# Os scripts de migração já estarão disponíveis
cd ~
./migrate.sh
```

## 📦 Sistema de Migração Incluído

Este repositório inclui um **sistema completo de migração multi-distribuição**:

### Scripts Disponíveis:
- **`migrate.sh`** - Menu interativo principal
- **`migration_installer.sh`** - Instalador cross-distro
- **`dotfiles_sync.sh`** - Backup completo de configurações

### Distribuições Suportadas:
- ✅ Arch Linux / Manjaro
- ✅ Ubuntu / Debian / Linux Mint
- ✅ Fedora / CentOS / RHEL  
- ✅ openSUSE / SLES

## 🔄 Processo de Migração Completo

### 1. Na Máquina Original
```bash
# Fazer backup completo
./dotfiles_sync.sh

# Ou usar o menu interativo
./migrate.sh
```

### 2. Na Nova Máquina

#### Opção A: Com Chezmoi (Recomendado)
```bash
chezmoi init --apply https://github.com/90sRehem/dotfiles.git --branch arch
./migrate.sh
```

#### Opção B: Manual
```bash
# Copiar pasta de backup + scripts

# Arch Linux
sudo pacman -S $(cat pacman_explicit.txt | tr '\n' ' ')
yay -S $(cat pacman_aur.txt | tr '\n' ' ')

# Ubuntu/Debian
sudo apt install $(cat pacman_explicit.txt | tr '\n' ' ')

# Fedora
sudo dnf install $(cat pacman_explicit.txt | tr '\n' ' ')

# Restaurar dotfiles
./restore.sh
```

## 📋 Pacotes Atuais (Exemplo)

**Pacotes Oficiais:** ~176  
**Pacotes AUR:** 9
- android-studio
- bundletool
- chaotic-keyring
- chaotic-mirrorlist
- lazysql
- localsend
- slack-desktop
- vicinae-bin
- zen-browser-bin

## 🛠️ Funcionalidades

### Backup Automático
- ✅ Dotfiles importantes (`.bashrc`, `.zshrc`, `.gitconfig`, etc.)
- ✅ Diretórios `.config`, `.ssh`, `.local`
- ✅ Listas de pacotes (pacman, AUR, flatpak, snap, npm, pip, cargo)
- ✅ Serviços systemd habilitados
- ✅ Informações do sistema

### Instalação Inteligente
- ✅ Detecção automática da distribuição
- ✅ Mapeamento de nomes de pacotes entre distros
- ✅ Instalação automática de AUR helper (yay)
- ✅ Logs detalhados de sucesso/erro
- ✅ Backup seguro antes de restaurar

### Restore Seguro
- ✅ Backup de arquivos existentes (`.backup.timestamp`)
- ✅ Script de restauração incluído
- ✅ Preservação de permissões
- ✅ README com instruções detalhadas

## 🎯 Casos de Uso

- **Nova instalação**: Configurar sistema do zero
- **Reinstalação**: Recuperar configurações após formatação  
- **Múltiplas máquinas**: Sincronizar configs entre dispositivos
- **Mudança de distro**: Migrar de/para diferentes distribuições
- **Backup**: Manter versioned das configurações

## 📂 Estrutura do Backup

```
dotfiles_migration_YYYYMMDD_HHMMSS/
├── README.md                 # Guia completo
├── restore.sh               # Script de restauração
├── system_info.txt          # Info do sistema original
├── pacman_explicit.txt      # Pacotes oficiais
├── pacman_aur.txt          # Pacotes AUR
├── flatpak_packages.txt    # Apps Flatpak
├── npm_global.txt          # Pacotes npm globais
├── pip_packages.txt        # Pacotes Python
├── cargo_packages.txt      # Pacotes Rust
├── user_services.txt       # Serviços systemd usuário
├── system_services.txt     # Serviços systemd sistema
└── .config/                # Diretórios de configuração
    ├── nvim/
    ├── git/
    ├── tmux/
    └── ...
```

## ⚡ Comandos Rápidos

```bash
# Menu principal
./migrate.sh

# Backup apenas
./dotfiles_sync.sh

# Instalação apenas
./migration_installer.sh

# Ver status chezmoi
chezmoi status

# Aplicar mudanças
chezmoi apply

# Editar arquivo
chezmoi edit ~/.bashrc
```

## 🔧 Personalização

Para personalizar o sistema de migração, edite:

- **Pacotes para mapear**: `create_package_mapping()` em `migration_installer.sh`
- **Dotfiles para backup**: `IMPORTANT_CONFIGS` em `dotfiles_sync.sh`
- **Opções do menu**: `show_menu()` em `migrate.sh`

## 📝 Notas Importantes

- **AUR**: Pacotes AUR são instalados apenas em distribuições Arch-based
- **Permissões**: Verifique permissões do `~/.ssh` após restauração
- **Conflitos**: Arquivos existentes recebem suffix `.backup` antes da restauração
- **Logs**: Sempre verifique os logs para pacotes que falharam na instalação

## 🤝 Contribuição

Para adicionar suporte a novas distribuições ou melhorar o mapeamento de pacotes, edite os scripts e faça commit via chezmoi:

```bash
chezmoi edit ~/migration_installer.sh
chezmoi apply
cd ~/.local/share/chezmoi && git commit -am "feat: improve migration system"
```

---

**🎉 Sistema testado e funcional para migração completa entre distribuições Linux!**