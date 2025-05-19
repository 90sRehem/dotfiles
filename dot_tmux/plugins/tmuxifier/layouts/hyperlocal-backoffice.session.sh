# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "~/Documentos/hyperlocal/hyperlocal-backoffice"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "hyperlocal-backoffice"; then

	# Create a new window inline within session layout definition.
	new_window "editor"
	new_window "shell"

	# Load a defined window layout.
	#load_window "example"

	# Select the default active window on session creation.
	select_window 1
	run_cmd "nvim ."

	select_window 2
	run_cmd "yarn dev"

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
