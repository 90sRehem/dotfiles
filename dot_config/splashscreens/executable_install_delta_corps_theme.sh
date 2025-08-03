#!/bin/bash

echo "Instalando tema Plymouth Delta Corps..."

# Criar diretório do tema
sudo mkdir -p /usr/share/plymouth/themes/delta-corps

# Copiar arquivos base do omarchy
sudo cp /usr/share/plymouth/themes/omarchy/*.png /usr/share/plymouth/themes/delta-corps/
sudo cp /usr/share/plymouth/themes/omarchy/omarchy.script /usr/share/plymouth/themes/delta-corps/delta-corps.script

# Copiar arquivo de configuração personalizado
sudo cp /home/rehem/.config/splashscreens/delta-corps-theme/delta-corps.plymouth /usr/share/plymouth/themes/delta-corps/

# Substituir logo pelo Delta Corps azul transparente
sudo cp /home/rehem/.config/splashscreens/delta-corps-logo-blue-transparent.png /usr/share/plymouth/themes/delta-corps/logo.png

# Ativar o tema
sudo plymouth-set-default-theme delta-corps --rebuild-initrd

echo "Tema Delta Corps instalado e ativado!"
echo "Reinicie o sistema para ver o novo logo."