extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	check_library_for_registries("res://", true, "debug")
	return OK

func _boot_registry():
	# override this function to set name and what directories to load files from for this registry
	directories_to_load = [
	]
	#search_for_loadable_content_by_name("res://", "debug")
	return OK
