# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "/home/rehem/Documents/dev/personal/easy-list"

# Create session with specified name if it does not already exist.
if initialize_session "easy-list"; then

  # Window 1: Frontend (Web App) - Editor
  new_window "frontend"
  run_cmd "cd apps/web && n"

  # Window 2: Backend (API) - Editor
  new_window "backend"
  run_cmd "cd apps/api && n"

  # Window 3: Design System - Editor
  new_window "design-system"
  run_cmd "cd packages/design-system && n"

  # Window 4: Terminal com splits para cada app + design system
  new_window "terminals"
  select_window "terminals"

  # Split horizontal para criar 3 painéis
  split_v
  split_v

  # Ajustar layout para painéis uniformes
  run_cmd "tmux select-layout even-vertical"

  # Painel 1: Frontend terminal
  select_pane 1
  run_cmd "cd apps/web && clear && echo '🌐 Frontend Terminal' && echo 'Pronto para comandos do frontend (web)'"

  # Painel 2: Backend terminal
  select_pane 2
  run_cmd "cd apps/api && clear && echo '⚡ Backend Terminal' && echo 'Pronto para comandos do backend (api)'"

  # Painel 3: Design System terminal
  select_pane 3
  run_cmd "cd packages/design-system && clear && echo '🎨 Design System Terminal' && echo 'Pronto para comandos do design system'"

  # Window 5: Turbo Commands
  new_window "turbo"
  run_cmd "clear && echo '🚀 Turbo Commands - Easy List' && echo '' && echo 'Comandos disponíveis:' && echo '' && echo 'pnpm dev          - Inicia todos os serviços' && echo 'pnpm build        - Build de todos os projetos' && echo 'pnpm lint         - Lint em todos os projetos' && echo 'pnpm format       - Formata código' && echo 'pnpm check-types  - Verificação de tipos' && echo '' && echo '💡 Execute pnpm dev para iniciar tudo'"

  # Volta para a janela 1 (frontend) após criar tudo
  select_window "frontend"
fi

# Finalizar a sessão e entrar nela
finalize_and_go_to_session
