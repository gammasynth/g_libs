extends ConsoleParser

class_name ExecutiveConsoleParser


func _get_console_command_library_names() -> Array[String]:
	if not console_command_library_names.is_empty(): return console_command_library_names
	return ["console_commands"]


func _fallback_console_parse(text_line:String) -> Error:
	var operated: bool = false
	var _extension: String = text_line.get_extension()
	
	# First, you should check all commands from Registry to see if one runs. If not, let code below run.
	# TODO
	# !!!
	# Registry.get_registry("console_commands")
	# set operated = true when doing a command
	# !!!
	# TODO
	
	# default non-command behavior below
	
	## this could be a file, or a URL
	#if extension.length() > 0:
		## check if file, else check if URL
		#var file_paths: Array[String] = File.get_all_filepaths_from_directory(console.current_directory_path)
		#for fp: String in file_paths:
			#print(fp)
			#if text_line.to_snake_case() == fp.to_snake_case():
				#operated = true
				#
				#App.print_out("executing file " + text_line.to_snake_case() + "...")
				#App.execute(str(console.current_directory_path + fp))
		#
		#if not operated:
			#operated = true
			#var client: HTTPClient = HTTPClient.new()
			#if not text_line.begins_with("https://"): text_line = str("https://" + text_line)
			#
			#print("connecting to url...")
			#var connection: Error = client.connect_to_host(text_line)
			#print(str(str(text_line) + error_string(connection)))
			#
			#if connection == OK:
				#var e: Error = client.request(HTTPClient.METHOD_GET, "", [])
				#print(error_string(e))
			#else: print("BAD")
	
	# if text is the above directory's folder name
	if not operated: operated = is_text_line_above_folder(text_line)
	
	# if text is a folder name within the current directory
	if not operated: operated = is_text_line_a_subfolder(text_line)
	
	if not operated:
		console.print_out(str(text_line))
		console.execute(text_line)
		#operated = true
		# console executes on thread, so did_operate will set in a later function after the thread
	
	if operated: did_operate = true
	# - - -
	return OK


func is_text_line_above_folder(text_line:String) -> bool:
	var cp:String = console.current_directory_path
	
	cp = cp.to_lower()
	text_line = text_line.to_lower()
	
	while true:
		while cp.right(1) == "/" or cp.right(1) == "\\": cp = File.ends_with_slash(cp, false)
		
		if not cp.containsn("/") and not cp.containsn("\\"): return false
		
		var slash_index:int = cp.rfind("/")
		if slash_index == -1: slash_index = cp.rfind("\\")
		if slash_index == -1: return false
		
		cp = cp.left(slash_index)
		var above_folder_name:String = File.no_slashes(cp).replacen(":","").to_snake_case()
		var line_name: String = File.no_slashes(text_line).to_snake_case()
		
		
		if line_name == above_folder_name:
			cp = File.ends_with_slash(cp)
			if DirAccess.dir_exists_absolute(cp):
				console.open_directory(cp)
				return true
	
	return false

func is_text_line_a_subfolder(text_line) -> bool:
	var folder_paths: Array[String] = File.get_all_directories_from_directory(console.current_directory_path, true)
	
	text_line = text_line.to_lower()
	
	var folder_name: String = File.no_slashes(text_line).to_snake_case()
	for fp: String in folder_paths:
		var fn:String = File.no_slashes(fp).to_snake_case().to_lower()
		if folder_name == fn:
			fn = str(File.no_slashes(fp) + "/")
			console.open_directory(str(console.current_directory_path + fn))
			return true
	
	return false
