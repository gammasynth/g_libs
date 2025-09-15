extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = false
	keywords = ["help"]
	command_description = "Lists other relevant commands."
	return


func _perform_command(text_line:String) -> bool:
	# In the case that a user is using the console to stdin a line, we should escape the console help command.
	if console is ExecutiveConsole and (console as ExecutiveConsole).console_processing: return false
	
	console.print_out("command: help")
	
	for command in console.parser.all_commands:
		if command.keywords.is_empty(): continue
		if not command.is_base_command: continue
		
		var this_keywords:String = ""
		var kidx:int=0
		for keyword:String in command.keywords:
			if kidx == 0: this_keywords = str(this_keywords + keyword)
			else: this_keywords = str(this_keywords + "/" + keyword)
			kidx+=1
		console.print_out([str(this_keywords + " :> | " + command.command_description), " "])
		
	
	return true
