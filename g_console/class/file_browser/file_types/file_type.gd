extends RefCounted

class_name FileType

static var default_file_icon: Texture2D = null

var is_folder: bool = false
var is_base_file: bool = false
var extensions: Array[String] = [""]

var file_browser_item_icon: Texture2D = default_file_icon

## Override this function in an extended script to add a new file extension.
func _refresh_info(_at_path:String="") -> void:
	is_base_file = false
	extensions = [""]
	
	file_browser_item_icon = default_file_icon

func get_file_icon(icon_file_name:String) -> Texture2D:
	#var icon_registry: Registry = Registry.get_registry("file_icons")
	#return icon_registry.db.grab(icon_file_name)
	return Registry.pull("file_icons", icon_file_name)


static func get_file_type_from_path(at_path:String) -> FileType:
	var file_type_registry: Registry = Registry.get_registry("file_types")
	var file_types_entry: RegistryEntry = file_type_registry.grab("file_types")
	
	var file_is_actually_folder: bool = false
	var file_extension: String = at_path.get_extension()
	if file_extension.is_empty(): 
		if DirAccess.dir_exists_absolute(at_path):
			file_is_actually_folder = true
	
	
	for entry_key: String in file_types_entry.data:
		var entry: Variant = file_types_entry.data.get(entry_key)
		
		if entry is not GDScript: continue
		
		var ft: FileType = entry.new()
		if not ft or ft is not FileType: continue
		
		var is_type: bool = FileType.is_file_path_of_file_type(ft, at_path, file_is_actually_folder)
		if is_type: return ft
	
	# we did not find a ref for this type of file extension.
	# return an unknown FileType?
	var default_ft: FileType = file_types_entry.grab("file_type").new()
	default_ft._refresh_info(at_path)
	return default_ft


static func is_file_path_of_file_type(file_type:FileType, at_path:String, file_is_actually_folder:bool= at_path.get_extension().is_empty() and DirAccess.dir_exists_absolute(at_path)) -> bool:
	file_type._refresh_info(at_path)
	
	if !file_type.is_base_file: return false
	
	if file_is_actually_folder:
		if file_type.is_folder: return true
	else:
		if file_type.extensions.has(at_path.get_extension()): return true
		if file_type.extensions.size() == 0 and at_path.get_extension().is_empty(): return true
	return false
