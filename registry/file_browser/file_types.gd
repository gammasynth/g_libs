extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	return OK

func _boot_registry():
	# override this function to set name and what directories to load files from for this registry
	#registry_name = "entities"
	#element_is_folder = true
	#multiple_elements_in_folder = true
	#uses_entry_groups = false
	#entry_class = RegistryEntry.new()
	directories_to_load = [
		"res://lib/g_libs/g_console/class/file_browser/file_types/",
		"res://src/class/file_types/"
	]
	#search_for_loadable_content_by_name("res://", "file_types")
	return OK
