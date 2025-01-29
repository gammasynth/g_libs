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
	
	#var all_class_folder_paths: Array[String] = FileManager.get_all_directories_from_directory("res://", true, true)
	#var all_class_folder_names: Array[String] = FileManager.get_all_directories_from_directory("res://", false, true)
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
			#FileManager.get_all_filepaths_from_directory(pool_folder_path, "", true)
		#)
	#
	#directories_to_load.append_array(all_pool_script_paths)
	check_folder_for_folder("res://", "pool", (func(n): directories_to_load.append(n)), true, (func(n): 
			if not subregistry_paths.has(n): return true
			return false))
	return OK
