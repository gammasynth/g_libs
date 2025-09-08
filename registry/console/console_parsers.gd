extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	return OK

func _boot_registry():
	# override this function to set name and what directories to load files from for this registry
	directories_to_load = [
		#"res://g_libs/g_console/class/console/console_parsers/",
		#"res://src/class/console/console_parsers/"
	]
	check_folder_for_folder("res://", "parsers", (func(n): directories_to_load.append(n)), true)
	return OK
