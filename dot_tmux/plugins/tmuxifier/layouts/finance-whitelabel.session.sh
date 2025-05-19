# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "$HOME/Documentos/hyperlocal/finance"

# Create session with specified name if it does not already exist.
if initialize_session "finance-whitelabel"; then

  # Window 1: Vim occupying the whole screen.
  new_window "editor"
  run_cmd "nvim"

  # Window 2: Another window com os serviços
  new_window "services"

  # Criar um layout de grade 4x4 uniforme
  select_window "services"
  run_cmd "tmux set-option -w synchronize-panes off"

  # Criar os splits uniformemente
  split_v
  split_v
  split_v

  select_pane 0
  split_h
  split_h
  split_h

  select_pane 4
  split_h
  split_h
  split_h

  select_pane 8
  split_h
  split_h
  split_h

  select_pane 12
  split_h
  split_h
  split_h

  # Ajustar layout para manter os painéis do mesmo tamanho
  run_cmd "tmux select-layout tiled"

  # Counter para seleção de painéis
  pane_counter=0

  # Loop pelos diretórios e abrir nos painéis
  for dir in ~/Documentos/hyperlocal/finance/*; do
    if [ -d "$dir" ]; then
      select_pane $pane_counter
      run_cmd "cd \"$dir\" && echo \"Abrindo terminal em $dir e rodando yarn start...\" && yarn start"

      pane_counter=$((pane_counter + 1))

      # Se preencher os 16 painéis, interrompe o loop
      if [ $pane_counter -eq 16 ]; then
        break
      fi
    fi
  done
fi

# Finalizar a sessão e entrar nela
finalize_and_go_to_session
