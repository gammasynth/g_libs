extends Database
## The FileBrowser was made for application called Omni. See https://gammasynth.com/omni
## FileBrowser is meant to be used in tandem with an ExecutiveConsole.s
class_name FileBrowser

signal item_selected(selected_item:FileItem)
signal item_deselected(deselected_item:FileItem)

signal item_entered_cut_state(item:FileItem)
signal item_exited_cut_state(item:FileItem)

signal items_pasted(paste_info:Dictionary[String, Variant])
signal items_deleted(delete_info:Dictionary[String, Variant])

signal favorite_added(file_path:String)
signal favorite_removed(file_path:String)

signal directory_items_cleared(old_items:Array[FileItem])
signal directory_item_added(new_item:FileItem)
signal directory_focused()

signal directory_focus_changed(new_current_path:String)
var current_directory_path: String = ""#"C:/"

var dir_history: Array[String] = []
var dir_future: Array[String] = []

var directory_items: Array[FileItem] = []

var multi_select:bool = false
var selected_items: Array[FileItem] = []

var copied_items: Array[FileItem] = []
var cut_items: Array[FileItem] = []

var favorites:Dictionary = {}# order int : path String

# - - -
#region Selecting Items

func has_selected_files() -> bool: return selected_items.size() > 0

func deselect_item(item:FileItem) -> void: 
	item.is_selected = false
	if selected_items.has(item): 
		selected_items.erase(item)
		item_deselected.emit(item)

func deselect_all_items() -> void:
	var old_selected_items:Array[FileItem] = selected_items.duplicate()
	for item:FileItem in old_selected_items:
		deselect_item(item)

func select_item(item:FileItem, _additive:bool=false) -> void:
	var additive:bool = _additive; if multi_select: additive = true
	if not additive: deselect_all_items()
	if item.is_selected and not additive: deselect_item(item)
	else: item.is_selected = true
	
	if item.is_selected and not selected_items.has(item): 
		selected_items.append(item)
		item_selected.emit(item)

func open_item(item:FileItem) -> void: 
	if item == null or not is_instance_valid(item): return# This should not occur if app is written well.
	select_item(item)
	open()

func open() -> void:
	for item:FileItem in selected_items:
		OS.shell_open(item.file_path.uri_encode())

#endregion

## - - -



#region Clipboarding Paths

func has_copied_files() -> bool: return copied_items.size() > 0
func has_cut_files() -> bool: return cut_items.size() > 0

func copy_item(item:FileItem) -> void: 
	if item == null or not is_instance_valid(item): return# This should not occur if app is written well.
	select_item(item)
	copy()

func copy(cut:bool=false) -> void:
	clear_cuts_and_copies()
	for item in selected_items: 
		copied_items.append(item)
		if cut: start_item_cut(item)

func start_item_cut(item:FileItem) -> void:
	cut_items.append(item)
	item.cut_state = true
	item_entered_cut_state.emit(item)

func clear_cut(item:FileItem, remove:bool=true) -> void:
	item.cut_state = false
	if not cut_items.has(item): return
	item_exited_cut_state.emit(item)
	if remove: cut_items.erase(item)

func clear_cuts_and_copies() -> void:
	clear_cuts()
	copied_items.clear()

func clear_cuts() -> void:
	for item:FileItem in cut_items:
		clear_cut(item, false)
	cut_items.clear()

func clear_cut_set(cut_set:Array[FileItem]=cut_items, deselect_all:bool=true) -> void:
	if cut_set.is_empty(): return
	for item:FileItem in cut_set:
		clear_cut(item, false)
	cut_set.clear()
	if deselect_all: deselect_all_items()

func cut_item(item:FileItem) -> void: 
	if item == null or not is_instance_valid(item): return# This should not occur if app is written well.
	select_item(item)
	cut()

func cut() -> void:
	clear_cuts()
	copy(true)
	deselect_all_items()

## Pastes whatever FileItems are currently copied or cut to path, and clears cut and copy lists.
## All selected nodes are deselected before the paste action occurs.
## Returns a dictionary containing information about the paste action.
## The returned dictionary gives the following key values:
## "pasted_to_path" : String directory path files were pasted into.
## "copied_from_items" : Array[FileItem] of the FileItems that were copied or cut before this paste.
## "pasted_items" : Array[FileItem] of the newly created FileItems at the paste.
## "cut_out_items" : Array[FileItem] of any FileItems that were cut and deleted for this paste action.
## "temp_deleted_items" : Array[FileItem] of stored newly created FileItems in temp/deleted/ for each cut item.
## "cut_out_items_info" : Dictionary[FileItem, FileItem] to access the FileItem in temp_deleted_items as values, with the FileItems in cut_out_items acting as keys.
func paste(path:String=current_directory_path) -> Dictionary[String, Variant]:
	deselect_all_items()
	var paste_info:Dictionary[String, Variant] = paste_action(path, copied_items, cut_items)
	clear_cuts_and_copies()
	return paste_info

func paste_action(path:String, items_to_copy:Array[FileItem], items_to_cut:Array[FileItem]) -> Dictionary[String, Variant]:
	var paste_info:Dictionary[String, Variant] = {}
	
	var copied_from_items:Array[FileItem] = []
	var pasted_items:Array[FileItem] = []
	var cut_out_items:Array[FileItem] = []
	var temp_deleted_items:Array[FileItem] = []
	var cut_out_items_info:Dictionary[FileItem, FileItem] = {}# cut_item : temp_recycled_item
	
	for item:FileItem in items_to_copy:
		copied_from_items.append(item)
		var pasted_item:FileItem = paste_item(item, path)
		pasted_items.append(pasted_item)
	for item in items_to_cut:
		var deleted_item:FileItem = remove_item(item)
		cut_out_items.append(item)
		temp_deleted_items.append(deleted_item)
		cut_out_items_info.set(item, deleted_item)
	
	paste_info.set("pasted_to_path", path)
	paste_info.set("copied_from_items", copied_from_items)
	paste_info.set("pasted_items", pasted_items)
	paste_info.set("cut_out_items", cut_out_items)
	paste_info.set("temp_deleted_items", temp_deleted_items)
	paste_info.set("cut_out_items_info", cut_out_items_info)
	items_pasted.emit(paste_info)
	focus_directory()
	return paste_info

## Copies a file to the current_directory_path, returns new FileItem of the pasted file.
func paste_item(item:FileItem, location:String=current_directory_path) -> FileItem:
	var old_path:String = item.file_path
	var new_path:String = str(location + item.file_name)
	var pasted_item:FileItem = FileItem.new(new_path)
	DirAccess.copy_absolute(old_path, new_path)
	return pasted_item

func delete_item(item:FileItem) -> void:
	select_item(item)
	delete()

func delete() -> Dictionary[String, Variant]:
	var delete_info:Dictionary[String, Variant] = {}
	var deleted_items:Array[FileItem] = []
	var backup_items:Array[FileItem] = []
	var backup_info:Dictionary[FileItem, FileItem] = {}
	for item in selected_items: 
		deleted_items.append(item)
		var backup_item:FileItem = remove_item(item)
		backup_items.append(backup_item)
		backup_info.set(item, backup_item)
	deselect_all_items()
	
	delete_info.set("deleted_items", deleted_items)
	delete_info.set("backup_items", backup_items)
	delete_info.set("backup_info", backup_info)
	items_deleted.emit(delete_info)
	
	focus_directory()
	return delete_info

## Copies a file to user/temp/deleted/, recycles the file, returns new FileItem of the temp/deleted/file.
## Backing up of the file to user/temp/deleted/file can be disabled with backup = false
## Warning! If hard is true, the file will be erased from the disk, and not recycled.
func remove_item(item:FileItem, backup:bool=true, hard:bool=false) -> FileItem:
	if item == null or not is_instance_valid(item): return null
	var item_path:String = item.file_path
	var deleted_item:FileItem = null
	if backup:
		var new_path :String = str("user://temp/deleted/" + item.file_name)
		deleted_item = FileItem.new(new_path)
		DirAccess.copy_absolute(item_path, new_path)
	if hard: DirAccess.remove_absolute(item_path)# WARN
	else: OS.move_to_trash(item_path)
	return deleted_item
#endregion

# - - -

#region Favoriting Paths
func toggle_favorite(file_path:String, toggle:Variant=null) -> void: 
	if toggle == null:
		if not remove_favorite(file_path): add_favorite(file_path)
	elif toggle is bool:
		if toggle: add_favorite(file_path)
		else: remove_favorite(file_path)

func add_favorite(file_path:String) -> bool:
	if favorites.values().has(file_path): return false
	
	favorites.set(favorites.size(), file_path)
	favorite_added.emit(file_path)
	return true

func remove_favorite(file_path:String) -> bool:
	if not favorites.values().has(file_path): return false
	
	var favorite_index:int = favorites.values().find(file_path)
	favorites.erase(favorite_index)
	favorite_removed.emit(file_path)
	return true
#endregion

#region Directory Navigation
func go_up_directory() -> void: 
	if not can_change_directory(): return
	
	var current:String = Main.console.current_directory_path
	var next:String = current
	var base:String = File.ends_with_slash(File.ends_with_slash(next, false).get_base_dir())
	if not base.is_empty(): next = base
	if next != current and DirAccess.dir_exists_absolute(base): open_directory(base)

func go_back_directory() -> void: travel_timeline(dir_history, dir_future)
func go_forward_directory() -> void: travel_timeline(dir_future, dir_history)

func travel_timeline(a:Array[String], b:Array[String]) -> void:
	if not can_change_directory(): return
	var current:String = Main.console.current_directory_path
	var next:String = current
	var this_size:int = a.size()
	if this_size>0:
		b.append(current)
		next = a.get(this_size-1)
		a.remove_at(this_size-1)
	if next != current: change_directory(next)

func clear_directory_items() -> void:
	var old_items:Array[FileItem] = directory_items.duplicate()
	directory_items.clear()
	directory_items_cleared.emit(old_items)

func add_directory_item(file_path:String) -> void:
	var new_item:FileItem = FileItem.new(file_path)
	directory_items.append(new_item)
	directory_item_added.emit(new_item)

func focus_directory(path:String=current_directory_path) -> Error:
	clear_directory_items()
	var all_paths: Array[String] = []
	
	var folder_paths = DirAccess.get_directories_at(path)
	for p in folder_paths: 
		all_paths.append(path + File.ends_with_slash(p))
	
	var file_paths = DirAccess.get_files_at(path)
	for p in file_paths: 
		all_paths.append(path + p)
	
	for p in all_paths:
		add_directory_item(p)
	
	directory_focused.emit()
	return OK

func _directory_change_prevented(at_path:String) -> void: pass

func open_directory(at_path:String=current_directory_path, force:bool=false) -> void: 
	if at_path == current_directory_path: return
	if not can_change_directory():
		if force: pass
		else: return _directory_change_prevented(at_path)
	_open_directory(at_path)
func _open_directory(at_path:String=current_directory_path) -> void: 
	dir_history.append(at_path)
	change_directory(at_path)

func change_directory(at_path:String=current_directory_path, focus:bool=true, emit:bool=true) -> void: _change_directory(at_path, focus, emit)
func _change_directory(at_path:String=current_directory_path, focus:bool=true, emit:bool=true) -> void: 
	current_directory_path = at_path
	if focus: focus_directory()
	if emit: directory_focus_changed.emit(at_path)

func can_change_directory() -> bool: return _can_change_directory()
func _can_change_directory() -> bool: return true

func refresh() -> void: _refresh()
func _refresh() -> void: change_directory(current_directory_path, true, false)



#endregion
