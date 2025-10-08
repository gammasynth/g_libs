#|*******************************************************************
# pools.gd
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

extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	check_library_for_registries("res://", true, "pools")
	return OK

func _boot_registry():
	# override this function to set name and what directories to load files from for this registry
	#registry_name = "entities"
	#element_is_folder = true
	#multiple_elements_in_folder = true
	#uses_entry_groups = false
	#entry_class = RegistryEntry.new()
	directories_to_load = [
		"res://g_libs/g_db/class/db/pool.gd"
	]
	
	#var all_class_folder_paths: Array[String] = File.get_all_directories_from_directory("res://", true, true)
	#var all_class_folder_names: Array[String] = File.get_all_directories_from_directory("res://", false, true)
	#
	#var all_pool_folder_paths: Array[String] = []
	#
	#for idx in all_class_folder_names.size():
		#var n = all_class_folder_names[idx]
		#var p = all_class_folder_paths[idx]
		#
		#if n == "pool":
			#all_pool_folder_paths.append(p)
	#
	#var all_pool_script_paths : Array[String] = []
	#
	#for pool_folder_path in all_pool_folder_paths:
		#all_pool_script_paths.append_array(
			#File.get_all_filepaths_from_directory(pool_folder_path, "", true)
		#)
	#
	#directories_to_load.append_array(all_pool_script_paths)
	check_folder_for_folder("res://", "pool", (func(n): directories_to_load.append(n)), true, (func(n): 
			if not subregistry_paths.has(n): return true
			return false))
	return OK
