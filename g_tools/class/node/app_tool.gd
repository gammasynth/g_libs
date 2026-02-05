#|*******************************************************************
# app_tool.gd
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
class_name AppTool

@export_category("App Version")
enum StatusTypes {alpha, beta, release}
enum CodeTypes {none, library, application}

@export var json_tool_node : JsonTool
@export var project_is_godot_editor : bool = false
@export_dir var local_project_root: String = "res://"
@export_global_dir var project_root: String = ProjectSettings.globalize_path("res://")
@export_global_dir var godot_project_root: String = ProjectSettings.globalize_path("res://")

@export var project_name : String = ProjectSettings.get_setting("application/config/name")

@export var version_status: StatusTypes = StatusTypes.alpha

@export var current_version : String = ProjectSettings.get_setting("application/config/version")
@export var new_version : String = current_version

@export var dependencies: Array[String] = []
@export var project_type: CodeTypes = CodeTypes.none

@export var started_project: bool = false
@export_tool_button("Startup New Project") var startup_project_action: Callable = startup_project


@export_dir var local_json_info: String = ""
@export_global_dir var json_info: String = ProjectSettings.globalize_path("res://version.json")

@export_dir var local_updates_info_file_path : String = ""
@export_global_dir var updates_info_file_path : String = ""
@export_multiline var update_description : String = ""
@export_file() var local_changelog : String = ""
@export_global_file() var changelog : String = ""

@export_tool_button("Write commit to changelog") var add_commit_action : Callable = add_commit_to_changelog

@export_global_dir var new_changelog_file_path : String = ""
@export_tool_button("Create new changelog") var create_changelog_action : Callable = create_new_changelog

@export_category("Versions Manifest")
@export_global_file() var versions_manifest : String = ""
@export_global_file() var versions_manifest_gitpush : String = ""
@export var encryption_key : String = ""
@export_tool_button("Update Version Manifest") var update_version_action : Callable = update_version_manifest

@export_category("Update Application")

## Writes commit & changelogs & any JSON (lib/version) Information, updates ProjectSettings version to [member new_version] if [member project_is_godot_editor], updates  [member versions_manifest]. [br] [br]
## Equivalent to pressing "Write commit to changelog" and then "Update Version Manifest", at the same time. [br] [br]
## You should make sure to update/commit/push your repo and/or res://lib/ repos prior to doing this. (Then you can commit again after to push the changelogs.)
@export_tool_button("Update App") var update_app_action : Callable = update_app

## Sets some internal AppTool values/members, makes changelog .txt file and /changelog_updates/ folder, and makes either a lib.json or a version.json, all depending on whether the [member project_type] is either [member CodeTypes.library] or [member CodeTypes.application]. [br] [br]
## Does nothing if [member project_type] is set to [member CodeTypes.none]. [br]
## Does nothing if [member started_project] is set to true. [br]
## Sets [member started_project] to true, after execution.[br] [br]
## This method has a button in the Godot Editor inspector.
func startup_project() -> void:
	print(" ")
	if started_project: 
		print("AppTool | Warning! Already started project!")
		return
	if project_type == CodeTypes.application: 
		print("AppTool | Starting new Application project...")
		print(" ")
		local_json_info = ""
		if project_is_godot_editor: 
			print("AppTool | project_is_godot_editor detected, asking ProjectSettings for application name...")
			project_name = ProjectSettings.get_setting("application/config/name")
			print(str("AppTool | Godot Project name is " + project_name) + ", applied to project_name!")
			print(" ")
		
		var root:String = get_project_root()
		if root.is_empty():
			print(" ")
			print("AppTool | There is no Application root directory set!")
			print("AppTool | Tip: Application projects prefer to use project_root, if it is not empty!")
			print("AppTool | Using default Library structure (res://app/project_name/)...")
			root = "res://app/"
			DirAccess.make_dir_recursive_absolute(root)
			root = str(root + project_name.validate_filename() + "/")
			DirAccess.make_dir_recursive_absolute(root)
			print("AppTool | Application directory folder established!")
			print(" ")
		
		print(str("AppTool | Application directory folder: " + root))
		
		json_info = str("version.json")
		if not FileAccess.file_exists(json_info):
			print("AppTool | There is no JSON version.json information file! Creating a new one...")
			
			var json_tool:JsonTool = json_tool_node
			if not json_tool_node:
				print("AppTool | Adding new JsonTool node...")
				json_tool = JsonTool.new()
				await Make.child(json_tool, self)
			
			print("AppTool | Added new JsonTool node!")
			print("AppTool | Configuring JsonTool node...")
			json_tool.app_name = project_name
			json_tool.app_build = StatusTypes.keys().get(version_status)
			json_tool.app_dependencies = dependencies
			json_tool.app_version = new_version
			json_tool.new_file_path = json_info
			
			print("AppTool | Generating new JSON version.json information file...")
			json_tool.generate_version_json()
			print("AppTool | Generated new JSON version.json information file successfully!")
		else:
			print("AppTool | This project already has a version.json file! Continuing...")
		
		var uses_local_updates_path:bool = false
		if updates_info_file_path.is_empty(): 
			if not local_updates_info_file_path.is_empty():
				uses_local_updates_path = true
				print("AppTool | This project is using local_updates_info_file_path!")
				#print("AppTool | There is no updates_info_file_path! Attempting to use local_updates_info_file_path...")
				#updates_info_file_path = ProjectSettings.globalize_path(local_updates_info_file_path)
			
			if not uses_local_updates_path && updates_info_file_path.is_empty(): 
					print("AppTool | There is no updates_info_file_path! Generating new changelog updates directory...")
					var changelogs_dir:String = str(get_project_root() + "changelog_updates/")
					if changelogs_dir.begins_with("res://"): 
						local_updates_info_file_path = changelogs_dir
						uses_local_updates_path = true
						print(str("AppTool | Generated local_updates_info_file_path changelogs updates directory at: " + local_updates_info_file_path))
					else:
						updates_info_file_path = changelogs_dir
						print(str("AppTool | Generated updates_info_file_path changelogs updates directory at: " + updates_info_file_path))
		else:
			print("AppTool | This project already has a updates_info_file_path set! Continuing...")
		
		print("AppTool | Validating changelog updates directory...")
		if uses_local_updates_path: DirAccess.make_dir_recursive_absolute(local_updates_info_file_path)
		else: DirAccess.make_dir_recursive_absolute(updates_info_file_path)
		# TODO do actual validation; check for folder; print
		if uses_local_updates_path: print(str("AppTool | Validated updates_info_file_path changelog updates directory: " + local_updates_info_file_path))
		else: print(str("AppTool | Validated updates_info_file_path changelog updates directory: " + updates_info_file_path))
		
	elif project_type == CodeTypes.library:
		print("AppTool | Starting new Library project...")
		
		print("AppTool | Validating Library setup...")
		json_info = ""
		var lib_dir:String = get_project_root()
		
		if lib_dir.is_empty():
			print(" ")
			print("AppTool | There is no Library root directory set!")
			print("AppTool | Tip: Library projects prefer to use local_project_root, which is a local directory (starting with res://), if it is not empty!")
			print("AppTool | Using default Library structure (res://lib/project_name/)...")
			lib_dir = "res://lib/"
			DirAccess.make_dir_recursive_absolute(lib_dir)
			lib_dir = str(lib_dir + project_name.validate_filename() + "/")
			DirAccess.make_dir_recursive_absolute(lib_dir)
			print("AppTool | Library directory folder established!")
			print(" ")
			
		
		print(str("AppTool | Library directory folder: " + lib_dir))
		
		local_json_info = str(lib_dir + "lib.json")
		if not FileAccess.file_exists(local_json_info):
			print("AppTool | There is no JSON lib.json information file! Creating a new one..")
			
			var json_tool:JsonTool = json_tool_node
			if not json_tool_node:
				print("AppTool | Adding new JsonTool node...")
				json_tool = JsonTool.new()
				await Make.child(json_tool, self)
			
			print("AppTool | Added new JsonTool node!")
			print("AppTool | Configuring JsonTool node...")
			
			json_tool.lib_name = project_name
			json_tool.lib_build = StatusTypes.keys().get(version_status)
			json_tool.lib_dependencies = dependencies
			json_tool.lib_version = new_version
			json_tool.new_file_path = local_json_info
			
			print("AppTool | Generating new JSON lib.json information file...")
			json_tool.generate_library_json()
			print("AppTool | Generated new JSON lib.json information file successfully!")
		else:
			print("AppTool | This project already has a lib.json file! Continuing...")
		
		var changelogs_dir:String = local_updates_info_file_path
		if local_updates_info_file_path.is_empty() && updates_info_file_path.is_empty(): 
			print("AppTool | There is no updates_info_file_path or local_updates_info_file_path! Generating new changelog updates directory...")
			
			local_updates_info_file_path = str(lib_dir + "changelog_updates/")
			print(str("AppTool | Generated updates_info_file_path changelogs updates directory at: " + updates_info_file_path))
		else:
			if project_is_godot_editor && not updates_info_file_path.is_empty():
				changelogs_dir = ProjectSettings.localize_path(updates_info_file_path)
				if changelogs_dir.is_empty(): changelogs_dir = local_updates_info_file_path
			print("AppTool | This project already has a updates_info_file_path! Continuing...")
		
		print("AppTool | Validating changelog updates directory...")
		var uses_local_updates_path:bool = false
		if updates_info_file_path.is_empty():
			if not changelogs_dir.is_empty():
				print("AppTool | This project is using local_updates_info_file_path!")
				uses_local_updates_path = true
				#updates_info_file_path = ProjectSettings.globalize_path(local_updates_info_file_path)
		if uses_local_updates_path: DirAccess.make_dir_recursive_absolute(local_updates_info_file_path)
		else: DirAccess.make_dir_recursive_absolute(updates_info_file_path)
		# TODO do actual validation; check for folder; print
		if uses_local_updates_path: print(str("AppTool | Validated updates_info_file_path changelog updates directory: " + local_updates_info_file_path))
		else: print(str("AppTool | Validated updates_info_file_path changelog updates directory: " + updates_info_file_path))
		
	
	
	if not changelog and not local_changelog:
		create_new_changelog()
	else: 
		print("AppTool | This project already has a changelog file!")
	
	print("AppTool | Finished Project setup!")
	print(" ")

func get_project_root() -> String:
	var root:String = ""
	if not godot_project_root.is_empty(): root = godot_project_root
	if not project_root.is_empty() && project_root != godot_project_root: root = project_root
	if not local_project_root.is_empty() && local_project_root != project_root: root = local_project_root
	
	if project_type == CodeTypes.application:
		if not project_root.is_empty() and root != project_root: 
			root = project_root
			
	elif project_type == CodeTypes.library:
		if not local_project_root.is_empty() and root != local_project_root: root = local_project_root
	
	if root == local_project_root: print("AppTool | get_project_root | This project is using local_project_root!")
	if root == project_root: print("AppTool | get_project_root | This project is using project_root!")
	if root == godot_project_root: print("AppTool | get_project_root | This project is using godot_project_root!")
	
	return File.ends_with_slash(root)

func create_new_changelog() -> void:
	if not changelog.is_empty() or not local_changelog.is_empty():
		print("AppTool | Warning! There is an existing changelog or local_changelog path! Cancelling create_new_changelog method.")
		return
	if new_changelog_file_path.is_empty(): new_changelog_file_path = str(get_project_root() + "changelog.txt")
	
	var changelog_file = new_changelog_file_path
	
	
	if changelog_file.begins_with("res://"): 
		#changelog_file = ProjectSettings.globalize_path(changelog_file)
		#DirAccess.remove_absolute(ProjectSettings.globalize_path(changelog_file))
		print("AppTool | This project is using local_changelog!")
		local_changelog = changelog_file
	else:
		#DirAccess.remove_absolute(changelog_file)
		print("AppTool | This project is using changelog_file!")
		changelog = changelog_file
	
	if FileAccess.file_exists(changelog_file):
		print("AppTool | Warning! There is an existing file at destination changelog file path! Cancelling create_new_changelog method.")
		print(str("AppTool | Existing changelog file: " + changelog_file))
		return 
	
	print("AppTool | Creating new changelog...")
	print(str(" @ " + changelog_file))
	
	var file = FileAccess.open(changelog_file, FileAccess.WRITE_READ)
	if not file:
		print("AppTool | Error creating changelog!")
		print(error_string(FileAccess.get_open_error()))
	file.store_line(str(project_name + " | version changelog"))
	file.store_line("___")
	file.store_line(" ")
	
	print(str("Created new changelog at: " + changelog_file + " !"))
	new_changelog_file_path = ""

func add_commit_to_changelog() -> void:
	print("---")
	print(" ")
	print("AppTool | Writing update information to version changelog files...")
	print(" ")
	
	var info_files_path:String = updates_info_file_path
	if info_files_path.is_empty(): info_files_path = local_updates_info_file_path
	var updates_file_path :String = str(File.ends_with_slash(info_files_path) + "version_" + str(new_version) + "_changelog.txt")
	print(updates_file_path)
	DirAccess.remove_absolute(updates_file_path)
	
	
	var updates_file = FileAccess.open(updates_file_path, FileAccess.WRITE_READ)
	write_update_info_to_file(updates_file)
	print("AppTool | Wrote individual update changelog file: " + updates_file_path.get_file() + " !")
	print(" ")
	
	var this_changelog:String = changelog
	if this_changelog.is_empty(): this_changelog = local_changelog
	print(this_changelog)
	if not FileAccess.file_exists(this_changelog):
		print("AppTool | Changelog does not exist! Making one at new_changelog_file_path...")
		print("...")
		create_new_changelog()
	
	print("AppTool | Modifying changelog...")
	var file = FileAccess.open(this_changelog, FileAccess.READ_WRITE)
	var changelog_string: String = file.get_as_text()
	var header: String = changelog_string.substr(0, changelog_string.find("___")+4)
	var body: String = changelog_string.substr(changelog_string.find("___")+4)
	file.resize(0)
	file.store_string(header)
	write_update_info_to_file(file)
	file.store_string(body)
	print("AppTool | Added this update info into main changelog file: " + this_changelog.get_file() + " !")
	print(" ")
	
	if project_is_godot_editor:
		print("AppTool | project_is_godot_editor detected, setting new_version to ProjectSettings...")
		ProjectSettings.set_setting("application/config/version", new_version)
		current_version = ProjectSettings.get_setting("application/config/version")
	
	if not local_json_info.is_empty() or not json_info.is_empty():
		print("AppTool | Updating JSON (lib/version) information...")
		var json_path:String = json_info
		if json_path.is_empty(): json_path = local_json_info
		if FileAccess.file_exists(json_path):
			print("AppTool | Found JSON information file for project!")
			print(str("AppTool | JSON Information filepath: " + json_path))
			print("AppTool | Updating JSON (lib/version) information...")
			var dict:Dictionary = File.load_dict_file(json_path)
			var json_dict: Dictionary = dict
			if project_type == CodeTypes.library:
				if dict.has("lib"): json_dict = dict.get("lib")
			
			json_dict.set("version", new_version)
			json_dict.set("build", StatusTypes.keys().get(version_status))
			json_dict.set("latest_update", Timestamp.stamp())
			
			if project_type == CodeTypes.library:
				dict.set("lib", json_dict)
			
			var err:Error = File.save_dict_file(dict, json_path)
			if err == OK: print("AppTool | Updated version/build/latest_update in JSON Information File!")
			else: 
				print("AppTool | Error saving JSON Information File!")
				print(str("AppTool | File | Error: " + error_string(err)))
	
	
	update_description = ""
	current_version = new_version
	
	print("AppTool | Finished writing version update changelogs!")

func write_update_info_to_file(file:FileAccess) -> void:
	file.store_line("---")
	file.store_line("")
	file.store_line(str("version " + new_version + " " + StatusTypes.keys().get(version_status)))
	file.store_line("")
	file.store_string(update_description)
	file.store_line("")

func update_version_manifest() -> void:
	var data : Dictionary = FileUtilTool.load_dict_file(versions_manifest, encryption_key)
	print(str("AppTool | Pre-existing manifest data at " + str(versions_manifest) + " : "))
	print(data)
	
	
	var app_name:String = project_name
	var version:String = new_version
	if project_is_godot_editor:
		print("AppTool | project_is_godot_editor detected, using name & version from ProjectSettings instead...")
		app_name = ProjectSettings.get_setting("application/config/name")
		version = ProjectSettings.get_setting("application/config/version")
	
	if data.has(app_name):
		print(str("AppTool | Found existing entry in manifest for: " + app_name))
	else:
		print(str("AppTool | Creating entry in manifest for: " + app_name))
	
	data.set(app_name, version)
	print(str("AppTool | Post-update manifest data : "))
	print(data)
	
	var err: Error = FileUtilTool.save_dict_file(data, versions_manifest, encryption_key)
	if err == OK:
		print(str("AppTool | Saved updated version manifest data at " + str(versions_manifest) + " !"))
		if versions_manifest_gitpush is String and not versions_manifest_gitpush.is_empty():
			# TODO implement linux shell scripts
			if versions_manifest_gitpush.ends_with(".bat"):
				var output: Array = []
				var exit_code: int = OS.execute(versions_manifest_gitpush, [str(app_name + " update version " + version)], output, true, true)
				if exit_code == -1: print("AppTool | Error: versions_manifest_gitpush failed to execute!")
				print("AppTool | versions_manifest_gitpush output: ")
				print(output)
	else:
		print(str("AppTool | Failed to save file! Err == " + str(err) + " " + error_string(err)))


func update_app() -> void:
	add_commit_to_changelog()
	update_version_manifest()
	print("AppTool | Update finished! Use Git in the root project folder for online version control.")
