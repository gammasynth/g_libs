#|*******************************************************************
# registry_moddable.gd
#*******************************************************************
# This file is part of g_libs. 
# g_libs is an open-source software codebase.
# g_libs is licensed under the MIT license.
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

extends RegistryBase

class_name RegistryModdable


#region Modded Stuff
func boot_modded_files_for_registry():
	return await _boot_modded_files_for_registry()

func _boot_modded_files_for_registry():
	var modded_directories_for_this_registry = []
	
	for main_directory_path in directories_to_load:
		var modded_dirs_dict = get_modded_directories_for_registry(main_directory_path)
		if debug: print(modded_dirs_dict);
		
		for mod_name in modded_dirs_dict:
			modded_directories_for_this_registry.append(modded_dirs_dict[mod_name])
	
	return modded_directories_for_this_registry

func get_mod_folder_paths() -> Dictionary:
	var mods_folder:String = "user://mods/"
	DirAccess.make_dir_absolute(mods_folder)
	
	var mod_folder_names = []
	
	var dir = DirAccess.open(mods_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("Found Mod Folder: " + file_name)
				mod_folder_names.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the mods folder!")
	
	var mod_folder_paths = {}
	
	for mod_name in mod_folder_names:
		mod_folder_paths[mod_name] = str(mods_folder + mod_name + "/")
	
	return mod_folder_paths

func get_modded_directories_for_registry(directory_path:String) -> Dictionary:
	# example texture folder path : "res://src/game/assets/texture/tile/world/floor/"
	
	var modded_directories_for_this_registry: Dictionary = {}
	
	var src_path = "res://game/"
	
	if directory_path.begins_with(src_path):
		directory_path = directory_path.right(src_path.length() * -1)
	
	var mod_directories = get_mod_folder_paths()
	if debug: print("mod_directories: " + str(mod_directories))
	
	
	for mod_name in mod_directories.keys():
		var this_mod_directory = mod_directories[mod_name]
		var needed_mod_dir_path = str(this_mod_directory + directory_path)
		if DirAccess.dir_exists_absolute(needed_mod_dir_path):
			modded_directories_for_this_registry[mod_name] = needed_mod_dir_path
	
	return modded_directories_for_this_registry
#endregion
