extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	return OK

func _boot_registry():
	directories_to_load = [
		#"res://g_libs/g_console/class/console/consoles/",
		#"res://src/class/console/consoles/"
	]
	
	check_folder_for_folder("res://", "consoles", (func(n): directories_to_load.append(n)), true)
	
	return OK
