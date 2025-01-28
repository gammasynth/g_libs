@tool
extends Node
class_name ScriptTool

@export var script_begins_with: String = "database_"
@export var script_ends_with: String = ".gd"

@export var search_path: String = "res://"
@export var search_recursive: bool = true

@export var control_script_path: String = "res://core/class/node/database_node.gd"

@export var update_scripts_to_control_script: bool = false:
	set(b):
		update_scripts_to_control_script = b
		if b:
			do_update_scripts_to_control_script()
			await get_tree().create_timer(0.1).timeout
			update_scripts_to_control_script = false



func do_update_scripts_to_control_script():
	var file_paths : Array = []
	
	if search_recursive:
		file_paths = FileTool.search_for_file_paths_recursively(search_path)
	else:
		file_paths = FileTool.get_all_filepaths_from_directory(search_path, "", true)
	
	#print("ScriptTool | files: " + str(file_paths) )
	
	var script_paths: Array = []
	for file_path: String in file_paths:
		var file_name : String = FileTool.get_file_name_from_file_path(file_path, true)
		if file_name.begins_with(script_begins_with) and file_name.ends_with(script_ends_with):
			script_paths.append(file_path)
	
	print("ScriptTool | scripts: " + str(script_paths) )
	
	var control_script: Script = load(control_script_path)
	if not control_script:
		print("ScriptTool | Error no control script!")
		return
	var control_source_code: String = control_script.source_code
	var control_script_file_name: String = FileTool.get_file_name_from_file_path(control_script_path)
	var control_class_extends: String = str("extends " + control_script_file_name.substr(script_begins_with.length()).to_pascal_case())
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
		
		var class_extends: String = str("extends " + file_name.substr(script_begins_with.length()).to_pascal_case())
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
