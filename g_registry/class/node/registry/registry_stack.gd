#|*******************************************************************
# registry_stack.gd
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




extends RegistryModdable

class_name RegistryStack

static var instance:Registry=null;

@export var subregistry_paths: Array[String] = []


static var registries = {}
	#get: 
		#if instance and is_instance_valid(instance): return instance.data
		#return {}

## global counter indexing of all registries in app
var registry_idx:int = 0
static var registry_count:int = 0


## If a Registry has Subregistries (other Registries as the elements it contains), we can reference them by their name as a key in subregistries dictionary.
## subregistries property is simply a reference to the data property.
var subregistries = {}

var booted_subregistries:int = 0

@export var exclude_subregistry_names: Array[String] = []

func _initialized() -> void:
	registry_count += 1
	registry_idx = registry_count
	if registry_idx == 1:
		instance = self
		_setup_main_registry_subregistries()
	get_mod_folder_paths()
	set_process(false)
	
	if instance != self and not registries.has(name): registries.get_or_add(name, self)



func check_library_for_registries(folder_path:String, recursive:bool = false, registry_folder_name:String="registry") -> void:
	check_library_for_folder(folder_path, registry_folder_name, (func(n): subregistry_paths.append(n)), recursive)

func check_folder_for_registries(folder_path:String, recursive:bool = false, registry_folder_name:String="registry") -> void:
	check_folder_for_folder(folder_path, registry_folder_name, (func(n): subregistry_paths.append(n)), recursive)


## The user/dev may insert subregistry paths before given the default settings with the export variable, or they can override these functions in an extended script.
func _setup_main_registry_subregistries() -> void:
	if subregistry_paths.size() == 0: 
		var root_folders: Array[String] = File.get_all_directories_from_directory("res://")
		
		for folder:String in root_folders:
			var folder_path:String = str("res://" + folder + "/")
			if is_folder_library(folder_path):
				var src_folders: Array[String] = File.get_all_directories_from_directory(folder_path)
				if src_folders.has("registry"): subregistry_paths.append(str(folder_path + "registry/"))
		
		if root_folders.has("lib"):
			for folder:String in File.get_all_directories_from_directory("res://lib/"):
				var folder_path:String = str("res://lib/" + folder + "/")
				if is_folder_library(folder_path):
					var src_folders: Array[String] = File.get_all_directories_from_directory(folder_path)
					if src_folders.has("registry"): subregistry_paths.append(str(folder_path + "registry/"))
		
		
		if root_folders.has("registry"): subregistry_paths.append("res://registry/")
		
		if root_folders.has("src"): 
			var src_folders: Array[String] = File.get_all_directories_from_directory("res://src/")
			if src_folders.has("registry"): subregistry_paths.append("res://src/registry/")
		
		#subregistry_paths.append("res://core/registry/")
		#subregistry_paths.append("res://src/registry/")
	return



func _start_registry() -> Error:
	var err = await gather_subregistry_paths()
	if subregistry_paths.size() > 0:
		
		if err == OK: 
			err = await create_registries()
		if err != OK and debug: chat(str("Error creating subregistries: " + error_string(err)))
	return OK

func _registry_started() -> Error:
	if debug and instance == self: 
		chat(" ")
		chat("All registries started.", Text.COLORS.cyan)
	return OK


func gather_subregistry_paths() -> Error:
	var registry_folder:String = File.get_folder(registry_path)
	if registry_folder.to_lower() != "registry":
		if name == registry_folder:
			chat(str("linking folder to registry: " + registry_folder))
			subregistry_paths.append(File.get_folder(registry_path, true))
	
	return await _gather_subregistry_paths()

func _gather_subregistry_paths() -> Error: return OK

func search_for_loadable_content_by_name(path:String="res://", folder:String="debug", excluding_folders:Array[String]=[]):
	check_folder_for_folder(
		path, 
		folder, 
		(func(n): directories_to_load.append(n)), 
		true, 
		(func(n): 
			if not subregistry_paths.has(n) and not directories_to_load.has(n): 
				if not excluding_folders.has(n) and not excluding_folders.has(n.get_base_dir()): return true
			return false)
	)


func _registry_booting() -> Error:
	if registry_count > 1: registries[name] = self
	
	var err = OK
	if debug:
		chat(str("contains subregistries: " + str(subregistries.size() > 0)))	
	
	if subregistries.size() > 0: 
		chat("Booting subregistries...")
		err = await boot_subregistries()
	
	return OK


func create_registries() -> Error:
	chat("Creating Subregistries...", Text.COLORS.white)
	#print(subregistry_paths)
	# remember to load and create active modded registries later
	for path in subregistry_paths:
		await create_registries_recursive(path)
	return OK

func create_registries_recursive(folder_path:String) -> Error:
	if folder_path == REGISTRY_SCRIPT_PATH: return OK
	if File.is_file(folder_path):
		chat(str("Creating Registry from FilePath: " + folder_path), Text.COLORS.yellow)
		await create_subregistry(folder_path)
		return OK
	
	await create_subregistries_from_folder(folder_path)
	var all_folders = File.get_all_directories_from_directory(folder_path, true)
	for folder in all_folders:
		await create_registries_recursive(folder)
	return OK


func create_subregistries_from_folder(folder_path:String, exclude_file_paths:Array[String]=exclude_subregistry_names) -> Array[Registry]:
	var new_registries: Array[Registry] = []
	var all_filepaths = File.get_all_filepaths_from_directory(folder_path, "", true)
	var main_subregistry_path: String = str(folder_path + File.get_folder(folder_path) + ".gd")
	if all_filepaths.has(main_subregistry_path):
		all_filepaths.erase(main_subregistry_path)
		all_filepaths.push_front(main_subregistry_path)
	for filepath in all_filepaths:
		if exclude_file_paths.has(filepath): continue;
		
		if filepath.ends_with(".uid"): continue;
		
		var r = await create_subregistry(filepath); 
		if r: 
			if new_registries.has(r) or registries.values().has(r):
				chat(str("created existing registry, ignoring: " + folder_path), Text.COLORS.yellow)
			else:
				new_registries.append(r)
	return new_registries


func _get_existing_subregistry(_subregistry_name:String, _from_database:Dictionary={}, _recursive:bool=false) -> Registry:
	return null

func create_subregistry(script_path:String=REGISTRY_SCRIPT_PATH) -> Registry:
	if script_path == registry_path: return self
	var subregistry_name: String = File.get_file_name_from_file_path(script_path)
	if exclude_subregistry_names.has(subregistry_name): return null
	
	var existing:Registry = await _get_existing_subregistry(subregistry_name, data, true)
	if existing: return null
	chat(str("loading registry file: " + script_path))
	
	var script: GDScript = File.load_gdscript_file(script_path)
	
	var loaded_script: Variant = script.new()
	if loaded_script is not Registry:
		warnd("NOT A REGISTRY SCRIPT! OTHER OBJ"); return null
	loaded_script.queue_free()
	loaded_script = script.new(subregistry_name)
	
	var subregistry : Registry = loaded_script
	subregistry.registry_path = script_path
	
	subregistry.setup_new_load_tracker(load_tracker)
	
	await Make.child(subregistry, self)
	subregistries.set(subregistry_name, subregistry)
	
	await subregistry.start()
	
	return subregistry

func gather_all_content_to_load() -> void:
	
	for subregistry_name in subregistries:
		var subregistry:Registry = subregistries.get(subregistry_name)
		await subregistry.gather_all_content_to_load()
	
	var err = await _boot_registry()
	if err != OK:
		warn("Booting error!", err)
	await gather_content_to_load()

func boot_subregistries() -> Error:
	for subregistry in get_children():
		await subregistry.boot_registry()
	chat("All subregistries booted!", Text.COLORS.white)
	return OK
