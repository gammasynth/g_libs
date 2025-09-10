extends RefCounted
class_name FileItem

signal selected
signal deselected

var file_name: String = ""
var file_path: String = ""
var file_type: FileType = null

var is_selected:bool = false:
	set(b):
		if b: selected.emit()
		else: deselected.emit()
		is_selected = b

var cut_state:bool = false

func _init(_file_path:String="", _file_type:FileType=null) -> void:
	file_path = _file_path
	
	file_type = _file_type
	if not file_type: file_type = FileType.get_file_type_from_path(file_path)
	
	if file_type.is_folder:
		file_name = File.begins_with_slash(File.ends_with_slash(file_path, false), false)
	else:
		file_name = File.get_file_name_from_file_path(file_path, true)
