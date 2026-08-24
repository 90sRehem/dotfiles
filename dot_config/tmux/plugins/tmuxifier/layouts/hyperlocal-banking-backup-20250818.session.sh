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

  # Window 3: Serviços com grid 4x4 de painéis
  new_window "services"
  select_window "services"
  run_cmd "tmux set-option -w synchronize-panes off"

  # Criar os splits uniformemente
  split_v
  split_v
  split_v

  select_pane 1
  split_h
  split_h
  split_h

  select_pane 5
  split_h
  split_h
  split_h

  select_pane 9
  split_h
  split_h
  split_h

  select_pane 13
  split_h
  split_h
  split_h

  # Ajustar layout para manter os painéis do mesmo tamanho
  run_cmd "tmux select-layout tiled"

  # Counter para seleção de painéis
  pane_counter=1

  # Loop pelos diretórios e abrir nos painéis
  for dir in ~/Documentos/dev/work/hyperlocal/finance/*; do
    if [ -d "$dir" ]; then
      repo_name=$(basename "$dir")
      select_pane $pane_counter
      run_cmd "cd \"$dir\" && clear && echo \"📁 $repo_name\" && yarn start"

      pane_counter=$((pane_counter + 1))

      # Se preencher os 16 painéis, interrompe o loop
      if [ $pane_counter -eq 17 ]; then
        break
      fi
    fi
  done

  # Seleciona o primeiro painel
  select_pane 1

  # Volta para a janela 1 (editor) após criar tudo
  select_window "editor"
fi

# Finalizar a sessão e entrar nela
finalize_and_go_to_session
