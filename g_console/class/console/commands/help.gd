extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = false
	keywords = ["help"]
	command_description = "Lists other relevant commands."
	return


func _perform_command(text_line:String) -> bool:
	console.print_out("command: help")
	
	for library_name:String in console.parser.console_command_library_names:
		var library: Registry = Registry.get_registry(library_name)
		
		for command_key:String in library.data:
			var command_script = library.grab(command_key)
			if not command_script or command_script and command_script is not GDScript: continue
			
			var command = command_script.new(console)
			if command is not ConsoleCommand: continue
			command = command as ConsoleCommand
			
			if command.keywords.is_empty(): continue
			if not command.is_base_command: continue
			
			var this_keywords:String = ""
			var kidx:int=0
			for keyword:String in command.keywords:
				if kidx == 0: this_keywords = str(this_keywords + keyword)
				else: this_keywords = str(this_keywords + "/" + keyword)
				kidx+=1
			console.print_out(str(this_keywords + ":> " + command.command_description))
		
	
	return true
