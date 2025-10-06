@tool
extends Node
class_name ScriptTool

@export var search_path: String = "res://"
@export var search_recursive: bool = true

@export var filename_begins_with: String = "database_"
@export var filename_ends_with: String = ".gd"

@export var comment_character: String = "#"

@export var blacklist_folder_names: Array[String] = []
@export var blacklist_file_names: Array[String] = []
@export var include_hidden_folders: bool = true

@export var control_script_path: String = "res://lib/g_libs/g_db/class/node/database_node.gd"

@export var update_scripts_to_control_script: bool = false:
	set(b):
		update_scripts_to_control_script = b
		if b:
			do_update_scripts_to_control_script()
			await get_tree().create_timer(0.1).timeout
			update_scripts_to_control_script = false

@export var control_license_path: String = "res://LICENSE.md"
@export_multiline var licensed_file_header:String = "This file is part of an open-source software."
@export var header_licensed_files: bool = false
@export var name_licensed_files: bool = false
@export var only_license_gd_files: bool = false
@export var licensable_filetypes:Array[String] = [".txt", ".md", ".gd"]

@export var only_license_files_with_filename_beginning: bool = false
@export var only_license_files_with_filename_ending: bool = false

@export var license_files: bool = false

@export var update_licensing: bool = false:
	set(b):
		update_licensing = b
		if b:
			do_update_files_licensing()
			await get_tree().create_timer(0.1).timeout
			update_licensing = false


func do_update_scripts_to_control_script():
	var file_paths : Array = []
	
	if search_recursive:
		file_paths = FileTool.search_for_file_paths_recursively(search_path, false, true, include_hidden_folders, blacklist_folder_names, blacklist_file_names)
	else:
		file_paths = FileTool.get_all_filepaths_from_directory(search_path, "", true, blacklist_file_names)
	
	#print("ScriptTool | files: " + str(file_paths) )
	
	var script_paths: Array = []
	for file_path: String in file_paths:
		var file_name : String = FileTool.get_file_name_from_file_path(file_path, true)
		if file_name.begins_with(filename_begins_with) and file_name.ends_with(filename_ends_with):
			script_paths.append(file_path)
	
	print("ScriptTool | scripts: " + str(script_paths) )
	
	var control_script: Script = load(control_script_path)
	if not control_script:
		print("ScriptTool | Error no control script!")
		return
	var control_source_code: String = control_script.source_code
	var control_script_file_name: String = FileTool.get_file_name_from_file_path(control_script_path)
	var control_class_extends: String = str("extends " + control_script_file_name.substr(filename_begins_with.length()).to_pascal_case())
	control_class_extends = control_class_extends.replacen("2D", "2D")
	control_class_extends = control_class_extends.replacen("3D", "3D")
	print(control_class_extends)
	#if control_source_code.containsn(control_class_extends):
		#control_source_code.replacen(control_class_extends, "")
	
	var control_class_def: String = str("class_name " + control_script_file_name.to_pascal_case())
	control_class_def = control_class_def.replacen("2D", "2D")
	control_class_def = control_class_def.replacen("3D", "3D")
	print(control_class_def)
	
	#if control_source_code.containsn(control_class_def):
		#control_source_code.replacen(control_class_def, "")
	
	for script_path: String in script_paths:
		var file_name : String = FileTool.get_file_name_from_file_path(script_path)
		
		var class_string_name: String = file_name.to_pascal_case()
		
		var class_extends: String = str("extends " + file_name.substr(filename_begins_with.length()).to_pascal_case())
		class_extends = class_extends.replacen("2D", "2D")
		class_extends = class_extends.replacen("3D", "3D")
		print("ScriptTool | class extends: " + class_extends)
		
		var class_def: String = str("class_name " + class_string_name)
		class_def = class_def.replacen("2D", "2D")
		class_def = class_def.replacen("3D", "3D")
		print("ScriptTool | class def: " + class_def)
		
		var script: Script = load(script_path)
		var source_code: String = control_source_code
		
		if source_code.containsn(control_class_extends):
			source_code = source_code.replacen(control_class_extends, class_extends)
		
		
		if source_code.containsn(control_class_def):
			source_code = source_code.replacen(control_class_def, class_def)
		
		script.source_code = source_code
		script.reload()
		
		if ResourceSaver.save(script, script_path):
			print("ScriptTool | saved script: " + file_name)
	
	if script_paths.size() > 0: print("ScriptTool | saved scripts!")


func do_update_files_licensing():
	var file_paths : Array = []
	
	if search_recursive:
		file_paths = FileTool.search_for_file_paths_recursively(search_path, false, true, include_hidden_folders, blacklist_folder_names, blacklist_file_names)
	else:
		file_paths = FileTool.get_all_filepaths_from_directory(search_path, "", true, blacklist_file_names)
	
	#print("ScriptTool | files: " + str(file_paths) )
	
	var paths: Array = []
	for file_path: String in file_paths:
		var file_name : String = FileTool.get_file_name_from_file_path(file_path, true)
		if only_license_files_with_filename_beginning and not file_name.begins_with(filename_begins_with): continue
		if only_license_files_with_filename_ending and not file_name.ends_with(filename_ends_with): continue
		if only_license_gd_files and not file_name.ends_with(".gd"): continue
		var approve:bool = false
		for ext:String in licensable_filetypes:
			if file_name.ends_with(ext):
				approve = true
				break
		if approve: paths.append(file_path)
	
	print("ScriptTool | paths: " + str(paths) )
	
	var license_text:String = "All rights reserved."
	if license_files:
		if not FileAccess.file_exists(control_license_path):
			print(str("ScriptTool | No control license file at path: " + control_license_path))
			print("ScriptTool | Cancelling action!")
			return
		var license_file:FileAccess = FileAccess.open(control_license_path, FileAccess.READ)
		license_text = license_file.get_as_text()
	else:
		license_text = ""
	
	var license_bracket:String = "*******************************************************************"
	var main_license_bracket:String = str("|" + license_bracket)
	main_license_bracket = str(comment_character + main_license_bracket)
	license_bracket = str(comment_character + license_bracket)
	var is_licensed_print: String = "licensed"
	if not license_files: is_licensed_print = "unlicensed"
	
	var full_licensing:String = str(license_text + "\n" + main_license_bracket)
	if header_licensed_files: full_licensing = str(licensed_file_header + "\n" + license_bracket + "\n" + full_licensing)
	
	for path: String in paths:
		var file_name : String = FileTool.get_file_name_from_file_path(path, true)
		var this_licensing : String = full_licensing
		if name_licensed_files: this_licensing = str(file_name + "\n" + license_bracket + this_licensing)
		this_licensing = str(main_license_bracket + "\n" + this_licensing)
		var this_licensing_lines:PackedStringArray = this_licensing.split("\n", true, 0)
		this_licensing = ""
		for line:String in this_licensing_lines:
			var this_line:String = line
			if not this_line.begins_with(comment_character): 
				this_line = str(comment_character + " " + this_line)
			this_line = str(this_line + "\n")
			this_licensing = str(this_licensing + this_line)
		
		var file: FileAccess = FileAccess.open(path, FileAccess.READ_WRITE)
		if not file:
			print(str("ScriptTool | Couldn't open file at: " + path))
			print("ScriptTool | Skipping file!")
			continue
		
		var text: String = file.get_as_text()
		
		if text.containsn(main_license_bracket):
			var start: int = text.findn(main_license_bracket)
			var pre_length: int = start + main_license_bracket.length()
			var remaining_text: String = text.substr(pre_length)
			var next_bracket: int = remaining_text.findn(main_license_bracket)
			if next_bracket != -1: next_bracket += main_license_bracket.length()
			else: next_bracket = 0
			var end: int = pre_length + next_bracket
			var old_license:String = text.substr(start, end - start)
			text.replace(old_license, "")
		
		if license_files: text = str(this_licensing + "\n" + text)
		
		file.resize(0)# WARN
		file.store_string(text)
		print("ScriptTool | saved " + is_licensed_print + " file: " + file_name)
	
	if paths.size() > 0: print("ScriptTool | saved scripts!")
