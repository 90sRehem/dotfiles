# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "$HOME/Documents/dev/work/act/globo"

# Create session with specified name if it does not already exist.
if initialize_session "globo"; then

  # Window 1: Vim occupying the whole screen.
  new_window "editor"
  run_cmd "nvim"

  # Window 2: Plain terminal shell.
  new_window "shell"

  # Window 3: VPN connection.
  new_window "vpn"
  run_cmd "vpn-globo"

  # Select vpn window as the initially focused window.
  select_window "vpn"

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
