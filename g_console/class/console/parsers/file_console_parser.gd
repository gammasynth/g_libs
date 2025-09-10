extends ConsoleParser

class_name FileConsoleParser


func _fallback_console_parse(text_line:String) -> Error:
	if try_parse_cd(text_line): did_operate = true
	return OK


func try_parse_cd(text_line:String) -> bool:
	if text_line.begins_with("cd "): text_line = text_line.substr(3)
	
	if DirAccess.dir_exists_absolute(text_line):
		console.open_directory(text_line)
		return true
	
	if is_text_line_above_folder(text_line): return true
	
	# if text is a folder name within the current directory
	if is_text_line_a_subfolder(text_line): return true
	return false

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
