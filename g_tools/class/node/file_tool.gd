#|*******************************************************************
# file_tool.gd
#*******************************************************************
# This file is part of g_libs.
# 
# g_libs is an open-source software library.
# g_libs is licensed under the MIT license.
# 
# https://github.com/gammasynth/g_libs
#*******************************************************************
# Copyright (c) 2025 AD - present; 1447 AH - present, Gammasynth.  
# Gammasynth (Gammasynth Software), Texas, U.S.A.
# 
# This software is licensed under the MIT license.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
#|*******************************************************************

@tool
extends Node
class_name FileTool

@export_category("Destination Files")
@export var search_path: String = "res://"
@export var search_recursive: bool = true

@export_group("Path Filtering")
@export_subgroup("Filename Begin & End")
@export var filename_begins_with: String = "database_"
@export var filename_ends_with: String = ".gd"
@export_subgroup("")

@export_subgroup("Blacklist Files & Folders")
@export var blacklist_folder_names: Array[String] = []
@export var blacklist_file_names: Array[String] = ["LICENSE", "README"]
@export_subgroup("")

@export var include_hidden_folders: bool = true
@export_group("")

@export var comment_character: String = "#"


@export_category("Batch Script Edit")
@export var control_script_path: String = "res://lib/g_libs/g_db/class/node/database_node.gd"

#@export var update_scripts_to_control_script: bool = false:
	#set(b):
		#update_scripts_to_control_script = b
		#if b:
			#do_update_scripts_to_control_script()
			#await get_tree().create_timer(0.1).timeout
			#update_scripts_to_control_script = false
## Modify the destination script files to contain the same code as the [param]
@export_tool_button("Batch Update Scripts to Control Script") var update_scripts_action: Callable = do_update_scripts_to_control_script

@export_category("Batch File Licensing")
@export var control_license_path: String = "res://LICENSE.md"

@export_group("File Headers")
@export_multiline var licensed_file_header:String = "This file is part of an open-source software."
@export var header_licensed_files: bool = false
@export var name_licensed_files: bool = false

@export_group("File Filtering")
@export var only_license_gd_files: bool = false
@export var licensable_filetypes:Array[String] = [".txt", ".md", ".gd"]

@export var only_license_files_with_filename_beginning: bool = false
@export var only_license_files_with_filename_ending: bool = false
@export_group("")

@export var license_files: bool = false

#@export var update_licensing: bool = false:
	#set(b):
		#update_licensing = b
		#if b:
			#do_update_files_licensing()
			#await get_tree().create_timer(0.1).timeout
			#update_licensing = false
@export_tool_button("Batch Update File Licensing") var update_licenses_action: Callable = do_update_files_licensing


func do_update_scripts_to_control_script():
	var file_paths : Array = []
	
	if search_recursive:
		file_paths = FileUtilTool.search_for_file_paths_recursively(search_path, false, true, include_hidden_folders, blacklist_folder_names, blacklist_file_names)
	else:
		file_paths = FileUtilTool.get_all_filepaths_from_directory(search_path, "", true, blacklist_file_names)
	
	#print("FileTool | files: " + str(file_paths) )
	
	var script_paths: Array = []
	for file_path: String in file_paths:
		var file_name : String = FileUtilTool.get_file_name_from_file_path(file_path, true)
		if file_name.begins_with(filename_begins_with) and file_name.ends_with(filename_ends_with):
			script_paths.append(file_path)
	
	print("FileTool | scripts: " + str(script_paths) )
	
	var control_script: Script = load(control_script_path)
	if not control_script:
		print("FileTool | Error no control script!")
		return
	var control_source_code: String = control_script.source_code
	var control_script_file_name: String = FileUtilTool.get_file_name_from_file_path(control_script_path)
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
		var file_name : String = FileUtilTool.get_file_name_from_file_path(script_path)
		
		var class_string_name: String = file_name.to_pascal_case()
		
		var class_extends: String = str("extends " + file_name.substr(filename_begins_with.length()).to_pascal_case())
		class_extends = class_extends.replacen("2D", "2D")
		class_extends = class_extends.replacen("3D", "3D")
		print("FileTool | class extends: " + class_extends)
		
		var class_def: String = str("class_name " + class_string_name)
		class_def = class_def.replacen("2D", "2D")
		class_def = class_def.replacen("3D", "3D")
		print("FileTool | class def: " + class_def)
		
		var script: Script = load(script_path)
		var source_code: String = control_source_code
		
		if source_code.containsn(control_class_extends):
			source_code = source_code.replacen(control_class_extends, class_extends)
		
		
		if source_code.containsn(control_class_def):
			source_code = source_code.replacen(control_class_def, class_def)
		
		script.source_code = source_code
		script.reload()
		
		if ResourceSaver.save(script, script_path):
			print("FileTool | saved script: " + file_name)
	
	if script_paths.size() > 0: print("FileTool | saved scripts!")


func do_update_files_licensing():
	var file_paths : Array = []
	
	if search_recursive:
		file_paths = FileUtilTool.search_for_file_paths_recursively(search_path, false, true, include_hidden_folders, blacklist_folder_names, blacklist_file_names)
	else:
		file_paths = FileUtilTool.get_all_filepaths_from_directory(search_path, "", true, blacklist_file_names)
	
	#print("FileTool | files: " + str(file_paths) )
	
	var paths: Array = []
	for file_path: String in file_paths:
		var file_name : String = FileUtilTool.get_file_name_from_file_path(file_path, true)
		if only_license_files_with_filename_beginning and not file_name.begins_with(filename_begins_with): continue
		if only_license_files_with_filename_ending and not file_name.ends_with(filename_ends_with): continue
		if only_license_gd_files and not file_name.ends_with(".gd"): continue
		var approve:bool = false
		for ext:String in licensable_filetypes:
			if file_name.ends_with(ext):
				approve = true
				break
		if approve: paths.append(file_path)
	
	print("FileTool | paths: " + str(paths) )
	
	var license_text:String = "All rights reserved."
	if license_files:
		if not FileAccess.file_exists(control_license_path):
			print(str("FileTool | No control license file at path: " + control_license_path))
			print("FileTool | Cancelling action!")
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
		var file_name : String = FileUtilTool.get_file_name_from_file_path(path, true)
		var this_licensing : String = full_licensing
		if name_licensed_files: this_licensing = str(file_name + "\n" + license_bracket + "\n" + this_licensing)
		this_licensing = str(main_license_bracket + "\n" + this_licensing)
		var this_licensing_lines:PackedStringArray = this_licensing.split("\n", true, 0)
		this_licensing = ""
		
		#var idx:int = 0
		for line:String in this_licensing_lines:
			var this_line:String = line
			if not this_line.begins_with(comment_character): 
				this_line = str(comment_character + " " + this_line)
			
			#if idx != this_licensing_lines.size() - 1: this_line = str(this_line + "\n")
			# ^ possible problem with cutting line from file at top?? ^
			this_line = str(this_line + "\n")
			this_licensing = str(this_licensing + this_line)
			#idx += 1
		
		var file: FileAccess = FileAccess.open(path, FileAccess.READ_WRITE)
		if not file:
			print(str("FileTool | Couldn't open file at: " + path))
			print("FileTool | Skipping file!")
			continue
		
		var text: String = file.get_as_text()
		
		if text.containsn(main_license_bracket):
			
			var start: int = text.findn(main_license_bracket)
			print("FileTool | found existing license start bracket! @ char: " + str(start))
			
			var pre_length: int = start + main_license_bracket.length()
			var remaining_text: String = text.substr(pre_length)
			var next_bracket: int = remaining_text.findn(main_license_bracket)
			if next_bracket != -1: 
				print("FileTool | found existing next bracket! @ char: " + str(next_bracket))
				#next_bracket += pre_length
			else: next_bracket = 0
			var end: int = pre_length + next_bracket + main_license_bracket.length()
			var old_license:String = text.substr(start, end - start)
			text = text.replace(old_license, "")
			print("FileTool | removed previous file licensing!")
		
		# WARN this commented code removed every newline from scripts currently...
		#if text.begins_with("\n"):
			#while text.begins_with("\n"): text = text.replace("\n", "")
			#print("FileTool | removed whitespace newlines at beginning of file...")
		
		if license_files: text = str(this_licensing + text)
		
		file.resize(0)# WARN
		file.store_string(text)
		print("FileTool | saved " + is_licensed_print + " file: " + file_name)
	
	if paths.size() > 0: print("FileTool | saved scripts!")
