#|*******************************************************************
# json_tool.gd
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
class_name JsonTool

@export_category("File Generation")
@export_global_file() var new_file_path:String = ""

@export_category("Timestamping")
@export var time_tool_node: TimeTool = null
var current_date_time_stamp:String = "jan-1-2000":
	get:
		if time_tool_node: current_date_time_stamp = time_tool_node.date_time_stamp
		else: current_date_time_stamp = TimeTool.get_date_time_stamp()
		return current_date_time_stamp

@export_category("Generate Library Info JSON")
@export_global_file() var example_lib_json_file : String = ProjectSettings.globalize_path("res://lib/g_libs/g_tools/example_lib.json")

@export_group("Library JSON Info")
@export_subgroup("Library Info")
## lib.json files are for packaged libraries of code and/or resources, for identification, and not for encapsulated application packages. Use version.json instead for applications.
@export var lib_name: String = "example_library"

## the "type" key should be a String representing the intended enviroment/compiler for the library to be used within.
@export var lib_type: String = "godot"

@export var lib_creation: bool = true
@export var date_lib_created: String = "jan-1-2000":
	get:
		if lib_creation: return current_date_time_stamp
		return date_lib_created

@export var lib_version: String = "0.0.1"
@export var lib_last_update: String = current_date_time_stamp

@export_subgroup("Source Info")
@export var lib_source: String = ""
@export var lib_origin: String = ""
@export var lib_useable_zipped: bool = false
@export_subgroup("Dependency Info")
@export var lib_dependencies: Array[String] = []
@export var lib_is_sublibrary: bool = false
@export_subgroup("Copyright & License Info")
@export var lib_owner: String = "Public"
@export var lib_website: String = ""
@export var lib_copyright: String = ""
@export var lib_license: String = "All Rights Reserved."
@export_global_file() var lib_copyright_file: String = ""
@export_global_file() var lib_license_file: String = ""
@export_subgroup("Environment Info")
@export var lib_executable_path: String = ""
@export var lib_add_to_user_environment_path: String = ""
@export var lib_add_to_global_environment_path: String = ""
@export var lib_post_install_executable_path: String = ""
@export_group("")
@export_tool_button("Generate lib.json") var generate_library_json_action: Callable = generate_library_json

@export_category("Generate Version Info JSON")
@export_global_file() var example_version_json_file : String = ProjectSettings.globalize_path("res://lib/g_libs/g_tools/example_version.json")
@export_group("Version JSON Info")
@export var app_name: String = "Generic Software Application"
@export var app_version: String = "0.0.1"
@export var app_build: String = "alpha"
@export var app_creation: bool = true
@export var date_app_created: String = "jan-1-2000":
	get:
		if app_creation: return current_date_time_stamp
		return date_app_created

@export var app_last_update: String = current_date_time_stamp
@export_subgroup("Dependency Info")
@export var app_dependencies: Array[String] = []
@export_subgroup("Copyright & License Info")
@export var app_owner: String = "Public"
@export var app_website: String = ""
@export var app_copyright: String = ""
@export var app_license: String = "All Rights Reserved."
@export_global_file() var app_copyright_file: String = ""
@export_global_file() var app_license_file: String = ""
@export_group("")
@export_tool_button("Generate version.json") var generate_version_json_action: Callable = generate_version_json

@export_category("Generic JSON File Read/Write")
@export var data : Dictionary = {}
## If there is not a valid JSON file selected, then a new file will be made/used instead at [member new_file_path].
@export_global_file() var json_file : String = ""
@export var encryption_key : String = ""

@export_tool_button("Read Json Data from File") var read_data_action: Callable = read_data_button
@export_tool_button("Write Json Data to File") var write_data_action: Callable = write_data_button


func generate_library_json() -> void:
	var file_data:Dictionary = {}
	
	if not example_lib_json_file.is_empty(): 
		file_data = File.load_dict_file(example_lib_json_file)
	
	var this_data:Dictionary = {}
	if not file_data.is_empty():
		if file_data.has("lib"):
			var lib: Variant = file_data.get("lib")
			if lib is Dictionary:
				this_data = lib
		else:
			this_data = file_data
			file_data = {} 
	
	this_data.set("name", lib_name)
	this_data.set("type", lib_type)
	this_data.set("version", lib_version)
	this_data.set("latest_update", lib_last_update)
	this_data.set("date_created", date_lib_created)
	this_data.set("source", lib_source)
	this_data.set("origin", lib_origin)
	this_data.set("useable_zipped", lib_useable_zipped)
	this_data.set("dependencies", lib_dependencies)
	this_data.set("is_sublibrary", lib_is_sublibrary)
	this_data.set("owner", lib_owner)
	this_data.set("website", lib_website)
	this_data.set("copyright", lib_copyright)
	this_data.set("license", lib_license)
	this_data.set("copyright_filepath", lib_copyright_file)
	this_data.set("license_filepath", lib_license_file)
	this_data.set("executable_path", lib_executable_path)
	this_data.set("add_to_user_environment_path", lib_add_to_user_environment_path)
	this_data.set("add_to_global_environment_path", lib_add_to_global_environment_path)
	this_data.set("post_install_executable_path", lib_post_install_executable_path)
	
	file_data.set("lib", this_data)
	
	write_data(file_data)

func generate_version_json() -> void:
	var file_data:Dictionary = {}
	
	if not example_version_json_file.is_empty(): 
		file_data = File.load_dict_file(example_version_json_file)
	
	var this_data:Dictionary = {}
	if not file_data.is_empty(): this_data = file_data
	
	this_data.set("name", app_name)
	this_data.set("version", app_version)
	this_data.set("build", app_build)
	this_data.set("dependencies", app_dependencies)
	this_data.set("date_created", date_app_created)
	this_data.set("latest_update", app_last_update)
	this_data.set("owner", app_owner)
	this_data.set("website", app_website)
	this_data.set("copyright", app_copyright)
	this_data.set("license", app_license)
	this_data.set("copyright_filepath", app_copyright_file)
	this_data.set("license_filepath", app_license_file)
	
	file_data = this_data
	write_data(file_data)

func validate_path(path:Variant) -> bool:
	if typeof(path) == 0 or not path or (path is String and path.is_empty()): return false
	return true

func read_data_button() -> void: data = read_data()

func read_data() -> Dictionary: 
	var path = json_file; if not validate_path(path): path = new_file_path
	if not validate_path(path):
		print("JsonTool | Error: No valid path!")
		return {}
	
	var this_data: Dictionary = FileUtilTool.load_dict_file(path, encryption_key)
	print("JsonTool | Loaded file!")
	print(this_data)
	return this_data

func write_data_button() -> void: write_data(data)

func write_data(this_data:Dictionary=data) -> void: 
	var path = json_file; if not validate_path(path): path = new_file_path
	if not validate_path(path):
		print("JsonTool | Error: No valid path!")
		return
	
	var err:Error = FileUtilTool.save_dict_file(this_data, path, encryption_key)
	if err == OK: print("JsonTool | Saved file!" )
	else: print(str("JsonTool | Failed to save file! Err == " + str(err) + " " + error_string(err)))
	
