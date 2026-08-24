# Hyperlocal Banking - Dynamic Session Template
# Template tmuxifier que adapta o layout baseado nos serviços selecionados

# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "${FINANCE_DIR:-$HOME/Documentos/dev/work/hyperlocal/finance/}"

# Create session with specified name if it does not already exist.
if initialize_session "hyperlocal-banking"; then

  # Window 1: Vim occupying the whole screen.
  new_window "editor"
  run_cmd "nvim"

  # Window 2: Scripts - Para executar os scripts de automação
  new_window "scripts"
  run_cmd "clear && echo '🛠️  Scripts de Automação Disponíveis:' && echo '' && echo '1. ./switch-to-main.sh  - Muda todos os repos para branch main' && echo '2. ./git-pull-all.sh    - Faz git pull em todos os repos' && echo '3. ./install-deps.sh    - Instala dependências em todos os projetos' && echo '' && echo '💡 Execute os scripts na ordem: 1 → 2 → 3 para setup completo' && echo ''"

  # Window 3: Serviços dinâmicos
  new_window "services"
  select_window "services"
  run_cmd "tmux set-option -w synchronize-panes off"

  # Converter SELECTED_SERVICES string em array
  IFS=' ' read -ra SERVICES_ARRAY <<< "${SELECTED_SERVICES}"
  SERVICE_COUNT=${#SERVICES_ARRAY[@]}

  # Função para criar layout baseado na quantidade de serviços
  create_dynamic_layout() {
    local count=$1
    
    if [ $count -eq 1 ]; then
      # 1 serviço: painel único
      echo "Layout: 1 painel único"
    elif [ $count -eq 2 ]; then
      # 2 serviços: split vertical
      split_v
    elif [ $count -le 4 ]; then
      # 3-4 serviços: layout 2x2
      split_v
      select_pane 1
      split_h
      select_pane 2
      split_h
    elif [ $count -le 6 ]; then
      # 5-6 serviços: layout 2x3
      split_v
      split_v
      select_pane 1
      split_h
      select_pane 3
      split_h
      select_pane 5
      split_h
    elif [ $count -le 9 ]; then
      # 7-9 serviços: layout 3x3
      split_v
      split_v
      select_pane 1
      split_h
      split_h
      select_pane 4
      split_h
      split_h
      select_pane 7
      split_h
      split_h
    else
      # 10+ serviços: layout 4x4 (original)
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
    fi
    
    # Ajustar layout para manter os painéis do mesmo tamanho
    run_cmd "tmux select-layout tiled"
  }

  # Criar layout dinâmico
  create_dynamic_layout $SERVICE_COUNT

  # Função para obter informações do serviço
  get_service_info() {
    local service_name="$1"
    local service_dir="${FINANCE_DIR}/${service_name}"
    
    if [ -d "$service_dir" ]; then
      echo "$service_dir"
    else
      echo ""
    fi
  }

  # Inicializar contador de painéis
  pane_counter=1

  # Iterar pelos serviços selecionados e configurar painéis
  for service in "${SERVICES_ARRAY[@]}"; do
    service_dir=$(get_service_info "$service")
    
    if [ -n "$service_dir" ] && [ -d "$service_dir" ]; then
      # Selecionar painel atual
      select_pane $pane_counter
      
      # Determinar comando baseado no tipo de serviço
      if [[ "$service" == *"pwa"* ]]; then
        # Para React Native/Expo
        run_cmd "cd \"$service_dir\" && clear && echo \"📱 $service (Expo)\" && echo \"\" && echo \"🚀 Iniciando servidor Expo...\" && yarn start"
      else
        # Para microfrontends web
        run_cmd "cd \"$service_dir\" && clear && echo \"📁 $service\" && echo \"\" && echo \"🚀 Iniciando servidor...\" && yarn start"
      fi
      
      pane_counter=$((pane_counter + 1))
      
      # Limitar ao número máximo de painéis disponíveis
      if [ $pane_counter -gt 16 ]; then
        break
      fi
    fi
  done

  # Mostrar informações dos serviços selecionados no primeiro painel
  select_pane 1
  run_cmd "clear && echo '🚀 Hyperlocal Banking - Serviços Ativos' && echo '' && echo 'Serviços iniciados:'"
  
  for service in "${SERVICES_ARRAY[@]}"; do
    service_dir=$(get_service_info "$service")
    if [ -n "$service_dir" ] && [ -d "$service_dir" ]; then
      # Extrair porta do package.json se disponível
      local port="unknown"
      if [ -f "$service_dir/package.json" ]; then
        port=$(grep -o '"start":[^}]*--port [0-9]*' "$service_dir/package.json" | grep -o '[0-9]*$' || echo "auto")
      fi
      
      # Casos especiais
      case "$service" in
        "hyperlocal-banking-main") port="9000" ;;
        "hyperlocal-banking-pwa") port="expo" ;;
      esac
      
      run_cmd "echo '  ✓ $service (porta: $port)'"
    fi
  done
  
  run_cmd "echo '' && echo '💡 Use Ctrl+B + q para ver números dos painéis' && echo '💡 Use Ctrl+B + [número] para navegar entre painéis' && echo ''"

  # Volta para a janela 1 (editor) após criar tudo
  select_window "editor"
fi

# Finalizar a sessão e entrar nela
finalize_and_go_to_session
