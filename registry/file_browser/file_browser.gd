extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	subregistry_paths.append("res://lib/g_libs/registry/file_browser/file_icons.gd")
	subregistry_paths.append("res://lib/g_libs/registry/file_browser/file_types.gd")
	return OK

func _boot_registry():
	# override this function to set name and what directories to load files from for this registry
	directories_to_load = [
	]
	return OK
