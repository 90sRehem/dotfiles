#!/bin/bash

echo "Instalando tema Plymouth Delta Corps via chezmoi..."

# Verificar se Plymouth está instalado
if ! command -v plymouth-set-default-theme &> /dev/null; then
    echo "Plymouth não está instalado. Instalando..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm plymouth
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y plymouth
    else
        echo "Gerenciador de pacotes não suportado. Instale Plymouth manualmente."
        exit 1
    fi
fi

# Criar diretório do tema
sudo mkdir -p /usr/share/plymouth/themes/delta-corps

# Verificar se omarchy existe como base
if [ -d "/usr/share/plymouth/themes/omarchy" ]; then
    # Copiar arquivos base do omarchy
    sudo cp /usr/share/plymouth/themes/omarchy/*.png /usr/share/plymouth/themes/delta-corps/
    sudo cp /usr/share/plymouth/themes/omarchy/omarchy.script /usr/share/plymouth/themes/delta-corps/delta-corps.script
else
    echo "Tema omarchy não encontrado. Usando tema script como base..."
    sudo cp /usr/share/plymouth/themes/script/*.png /usr/share/plymouth/themes/delta-corps/ 2>/dev/null || true
    sudo cp /usr/share/plymouth/themes/script/script.script /usr/share/plymouth/themes/delta-corps/delta-corps.script 2>/dev/null || true
fi

# Copiar arquivo de configuração personalizado
sudo cp ~/.config/splashscreens/delta-corps.plymouth /usr/share/plymouth/themes/delta-corps/

# Substituir logo pelo Delta Corps azul transparente
sudo cp ~/.config/splashscreens/delta-corps-logo-blue-transparent.png /usr/share/plymouth/themes/delta-corps/logo.png

# Ativar o tema
sudo plymouth-set-default-theme delta-corps --rebuild-initrd

echo "Tema Delta Corps instalado e ativado via chezmoi!"
echo "Reinicie o sistema para ver o novo logo."