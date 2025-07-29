extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	#exclude_subregistry_names.append("debug")
	
	# TODO BUG THE FOLLOWING FUNCTION DOES NOT COLLECT THE SUBREGISTRIES?
	check_library_for_registries("res://g_libs/", true)
	
	# FIX TEMP v
	subregistry_paths.append("res://lib/g_libs/g_console/registry/g_libs/")
	
	return OK

## override this function to set name and what directories to load files from for this registry
func _boot_registry():
	directories_to_load = [
	]
	return OK
