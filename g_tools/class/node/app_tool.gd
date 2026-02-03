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
#|*******************************************************************@tool
@tool
extends Node
class_name AppTool

@export_category("App Version")
enum StatusTypes {alpha, beta, release}
enum CodeTypes {library, application}

@export var version_status: StatusTypes = StatusTypes.alpha
@export var project_type: CodeTypes = CodeTypes.application
@export_global_dir var project_root: String = ProjectSettings.globalize_path("res://")
@export_global_dir var godot_project_root: String = ProjectSettings.globalize_path("res://")

@export var current_version : String = ProjectSettings.get_setting("application/config/version")
@export var new_version : String = current_version


@export_global_dir var updates_info_file_path : String = ""
@export_multiline var update_description : String = ""
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

## Writes commit & changelogs, updates ProjectSettings version to [member new_version], updates  [member versions_manifest]. [br] [br]
## Equivalent to pressing "Write commit to changelog" and then "Update Version Manifest", at the same time. [br] [br]
## You should make sure to update/commit/push your repo and/or res://lib/ repos prior to doing this. (Then you can commit again after to push the changelogs.)
@export_tool_button("Update App") var update_app_action : Callable = update_app

func create_new_changelog() -> void:
	var changelog_file = str(File.ends_with_slash(new_changelog_file_path) + "changelog.txt")
	DirAccess.remove_absolute(changelog_file)
	
	var file = FileAccess.open(changelog_file, FileAccess.WRITE_READ)
	file.store_line(str(ProjectSettings.get_setting("application/config/name") + " | version changelog"))
	file.store_line("___")
	file.store_line(" ")
	
	print(str("Created new changelog at: " + changelog_file + " !"))
	new_changelog_file_path = ""

func add_commit_to_changelog() -> void:
	print("---")
	print(" ")
	print("AppTool | Writing update information to version changelog files...")
	print(" ")
	
	var updates_file_path :String = str(File.ends_with_slash(updates_info_file_path) + "version_" + str(new_version) + "_changelog.txt")
	print(updates_file_path)
	DirAccess.remove_absolute(updates_file_path)
	
	
	var updates_file = FileAccess.open(updates_file_path, FileAccess.WRITE_READ)
	write_update_info_to_file(updates_file)
	print("AppTool | Wrote individual update changelog file: " + updates_file_path.get_file() + " !")
	print(" ")
	
	print(changelog)
	var file = FileAccess.open(changelog, FileAccess.READ_WRITE)
	var changelog_string: String = file.get_as_text()
	var header: String = changelog_string.substr(0, changelog_string.find("___")+4)
	var body: String = changelog_string.substr(changelog_string.find("___")+4)
	file.resize(0)
	file.store_string(header)
	write_update_info_to_file(file)
	file.store_string(body)
	print("AppTool | Added this update info into main changelog file: " + changelog.get_file() + " !")
	print(" ")
	
	ProjectSettings.set_setting("application/config/version", new_version)
	current_version = ProjectSettings.get_setting("application/config/version")
	
	update_description = ""
	
	print("AppTool | Finished writing version update changelogs!")

func write_update_info_to_file(file:FileAccess) -> void:
	file.store_line("---")
	file.store_line("")
	file.store_line(str("version " + new_version))
	file.store_line("")
	file.store_string(update_description)
	file.store_line("")

func update_version_manifest() -> void:
	var data : Dictionary = FileUtilTool.load_dict_file(versions_manifest, encryption_key)
	print(str("AppTool | Pre-existing manifest data at " + str(versions_manifest) + " : "))
	print(data)
	
	var app_name:String = ProjectSettings.get_setting("application/config/name")
	var version:String = ProjectSettings.get_setting("application/config/version")
	
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
