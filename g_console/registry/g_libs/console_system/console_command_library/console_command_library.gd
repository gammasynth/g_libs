extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	var dir: DirAccess = DirAccess.open("res://")
	if dir.dir_exists("res://src/registry/core/console_system/console_command_library/"):
		subregistry_paths.append("res://src/registry/core/console_system/console_command_library/")
	return OK

func _boot_registry():
	# override this function to set name and what directories to load files from for this registry
	#registry_name = "entities"
	#element_is_folder = true
	#multiple_elements_in_folder = true
	#uses_entry_groups = false
	#entry_class = RegistryEntry.new()
	directories_to_load = [
	]
	
	return OK
