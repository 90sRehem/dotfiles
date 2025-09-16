#!/bin/bash
# Script para configurar sincronização automática do tema tmux com Omarchy

echo "🎨 Configurando sincronização de tema tmux com Omarchy..."

# Criar diretório de configuração do tmux
mkdir -p ~/.config/tmux

# Recarregar daemon do systemd
systemctl --user daemon-reload

# Habilitar e iniciar o serviço
systemctl --user enable tmux-theme-watcher.service
systemctl --user start tmux-theme-watcher.service

# Verificar se o serviço está rodando
if systemctl --user is-active --quiet tmux-theme-watcher.service; then
    echo "✅ Serviço tmux-theme-watcher iniciado com sucesso"
else
    echo "❌ Falha ao iniciar o serviço tmux-theme-watcher"
    systemctl --user status tmux-theme-watcher.service
    exit 1
fi

# Executar sincronização inicial
if command -v omarchy-theme-current &> /dev/null; then
    echo "🔄 Executando sincronização inicial do tmux..."
    ~/.local/bin/tmux-theme-sync
    echo "✅ Tema tmux inicial sincronizado: $(omarchy-theme-current)"
else
    echo "⚠️  Comando omarchy-theme-current não encontrado"
fi

# Recarregar tmux se estiver rodando
if tmux list-sessions &>/dev/null; then
    echo "🔄 Recarregando configuração do tmux..."
    tmux source-file ~/.tmux.conf
    echo "✅ Tmux recarregado com novo tema"
fi

echo "🎨 Configuração do tmux concluída! O tmux agora sincroniza automaticamente com o tema do Omarchy."
echo "📝 Para testar, use: omarchy-theme-set \"Nome do Tema\""