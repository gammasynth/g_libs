extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	#exclude_subregistry_names.append("debug")
	check_library_for_registries("res://g_libs/", true)
	return OK

## override this function to set name and what directories to load files from for this registry
func _boot_registry():
	directories_to_load = [
	]
	return OK
