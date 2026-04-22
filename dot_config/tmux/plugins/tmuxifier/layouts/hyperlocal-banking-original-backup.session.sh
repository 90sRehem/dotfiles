# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "$HOME/Documentos/dev/work/hyperlocal/finance/"

# Create session with specified name if it does not already exist.
if initialize_session "hyperlocal-banking"; then

  # Window 1: Vim occupying the whole screen.
  new_window "editor"
  run_cmd "nvim"

  # Window 2: Scripts - Para executar os scripts de automação
  new_window "scripts"
  run_cmd "clear && echo '🛠️  Scripts de Automação Disponíveis:' && echo '' && echo '1. ./switch-to-main.sh  - Muda todos os repos para branch main' && echo '2. ./git-pull-all.sh    - Faz git pull em todos os repos' && echo '3. ./install-deps.sh    - Instala dependências em todos os projetos' && echo '' && echo '💡 Execute os scripts na ordem: 1 → 2 → 3 para setup completo' && echo ''"

  # Window 3: Serviços com CLI seletora interativa
  new_window "services"
  select_window "services"
  run_cmd "tmux set-option -w synchronize-panes off"

  # Iniciar CLI seletora de microfrontends
  run_cmd "cd '$HOME/Documentos/dev/work/hyperlocal/finance' && clear && echo '🚀 Hyperlocal Banking - Microfrontends Launcher' && echo '' && echo '⏳ Inicializando...' && sleep 1 && ./hyperlocal-selector.sh"

  # Volta para a janela 1 (editor) após criar tudo
  select_window "editor"
fi

# Finalizar a sessão e entrar nela
finalize_and_go_to_session
