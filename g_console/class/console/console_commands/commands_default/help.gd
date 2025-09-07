extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = false
	keyword = "help"
	command_description = "Lists other relevant commands."
	return


func _perform_command(_text_line:String) -> bool:
	console.print_out("command: help")
	
	for library_name:String in console.parser.console_command_library_names:
		var library: Registry = Registry.get_registry(library_name)
		
		for command_key:String in library.data:
			var command_script = library.grab(command_key)
			if not command_script or command_script and command_script is not GDScript: continue
			
			var command = command_script.new()
			if command is not ConsoleCommand: continue
			command = command as ConsoleCommand
			
			if command.keyword.is_empty(): continue
			if not command.is_base_command: continue
			
			console.print_out(str(command.keyword + ": " + command.command_description))
		
	
	return true
