extends DatabaseNode

## LiveDatabase is an extension of DatabaseNode, that can load data from files at runtime.
## LiveDatabase is meant to be used as a base class for the [Registry] class system.
## See [Registry] for more use.
class_name LiveDatabase

signal begin_load
signal load_work
signal finished_load

@export var directories_to_load:Array[String] = []
@export var skip_loose_files: bool = false

var uses_registry_entries:bool = false
var uses_groups:bool = false
var element_is_folder:bool = false

var unloaded_data:Dictionary = {}# { DIR_PATH_IDX : [unloaded_file_path, ...] }
var unloaded_data_dir_idx:int = 0
var unloaded_data_sizes:Dictionary = {}

var group_directory_names:Array[String] = []
var group_folder_paths:Dictionary = {}

var load_is_finished:bool = false
var doing_load:bool = false

var total_workload:int = 0
var workload:int = 0

var last_file_workload = 0

var is_loading_file:bool = false
var load_index = 0
var group_index = 0

var load_tracker: LoadTracker

func _hookup_loader() -> Error:
	if not load_tracker: return OK
	begin_load.connect(load_tracker.worker_started)
	load_work.connect(load_tracker.worker_worked)
	finished_load.connect(load_tracker.worker_finished)
	return OK

func clean_functional_tags_from_file_name(file_name:String) -> String:
	return await _clean_functional_tags_from_file_name(file_name)

func clean_tag_from_file_name(file_name:String, tag:String) -> String:
	var f:String = file_name
	var t:String = tag
	var e:Callable = file_name.ends_with
	if e.call(t): return f.substr(0, f.length() - t.length())
	return file_name

func _clean_functional_tags_from_file_name(file_name:String) -> String:
	file_name = clean_tag_from_file_name(file_name, "example_tag")
	return file_name


func check_folder_for_folder(folder_path:String, target_folder_name:String, action:Callable, recursive:bool = false, condition:Callable=func(_n):return true) -> void:
	var library_folders: Array[String] = File.get_all_directories_from_directory(folder_path)
	
	#if library_folders.has(target_folder_name): action.call(str(folder_path + target_folder_name + "/"))
	for subfolder:String in library_folders:
		if subfolder.begins_with(target_folder_name): 
			var n:String = str(folder_path + subfolder + "/")
			if condition.call(n): action.call(n)
	
	if recursive:
		for subfolder:String in library_folders:
			var subfolder_path:String = str(folder_path + subfolder + "/")
			check_folder_for_folder(subfolder_path, target_folder_name, action, true)

func check_library_for_folder(folder_path:String, target_folder_name:String, action:Callable, recursive:bool = false) -> void:
	var library_folders: Array[String] = File.get_all_directories_from_directory(folder_path)
	
	#if library_folders.has(target_folder_name): action.call(str(folder_path + target_folder_name + "/"))
	for subfolder:String in library_folders:
		if subfolder.begins_with(target_folder_name): action.call(str(folder_path + subfolder + "/"))
	
	if recursive:
		for subfolder:String in library_folders:
			var subfolder_path:String = str(folder_path + subfolder + "/")
			if is_folder_library(subfolder_path):
				check_library_for_folder(subfolder_path, target_folder_name, action, true)

func is_folder_library(folder_path:String) -> bool:
	var folder_is_library: bool = false
	
	var file_names: Array[String] = File.get_all_filepaths_from_directory(folder_path)
	for file_name:String in file_names:
		if file_name == "lib.json":
			folder_is_library = true
			break
	
	return folder_is_library


func finish_load() -> bool:
	chat("Load finished.")
	load_is_finished = true
	await RenderingServer.frame_post_draw
	emit_signal("finished_load")
	doing_load = false
	set_process(false)
	return true

func increment_load_directory() -> bool:
	unloaded_data_dir_idx += 1
	chat(str("Loading next directory: " + str(unloaded_data[unloaded_data_dir_idx])))
	load_index = 0
	return true

func update_unloaded_data_directory() -> bool:
	if unloaded_data.is_empty(): return await finish_load()
	if not unloaded_data.has(unloaded_data_dir_idx):
		for key in unloaded_data.keys():
			if key is int:
				if unloaded_data_dir_idx < key:
					return increment_load_directory()
		return await finish_load()
	var unloaded_data_directory = unloaded_data[unloaded_data_dir_idx]
	if unloaded_data_directory.size() <= load_index:
		if unloaded_data.has(unloaded_data_dir_idx + 1):
			return increment_load_directory()
		return await finish_load()
	return false


func try_load_next_file(file_path:String) -> Variant:
	#print("E: " + file_path)
	if File.is_valid_resource(file_path):
		if file_path.ends_with(".tscn.remap"): 
			file_path = file_path.substr(0, file_path.length() - 6)
			var file = load(file_path)
			load_index += 1
			#print("SECRET LOADR" + str(file))
			return await handle_loaded_file(file, file_path)
		chat("ResourceLoader load interactive: " + file_path)
		var err = ResourceLoader.load_threaded_request(file_path, "", true, ResourceLoader.CACHE_MODE_REPLACE_DEEP)
		if err == OK:
			is_loading_file = true; return null
	
	var file = await File.try_load_file(file_path)
	if not file:
		chat("Error loading invalid user file: " + file_path + ", skipping!")
		load_index += 1
		return null
	
	return await handle_loaded_file(file, file_path)


func handle_loaded_file(file:Variant, file_path:String) -> Variant:
	var is_script:bool = false
	if file is GDScript:
		is_script = true
		var new_file = file.new()
		if new_file is RegistryEntry:
			file = new_file
		
		if new_file is Registry: return null
	
	var file_name = File.get_file_name_from_file_path(file_path)
	
	var valid_entry_file:bool = false;
	var has_data_tag:bool = false;
	if file_name.ends_with("_data"): 
		valid_entry_file = true
		has_data_tag = true
		chat(str("loaded possible RegistryEntry file: " + file_name + ", trimming '_data' from file name."))
		file_name = file_name.substr(0, file_name.length() - "_data".length())
	
	var real_file_name = File.get_file_name_from_file_path(file_path, true)
	if not is_script and not valid_entry_file and not File.is_valid_image_or_audio_resource(file_path) and not real_file_name.ends_with(".tscn"):
		real_file_name = file_name
	else:
		if valid_entry_file:
			if has_data_tag:
				var ext = str("." + real_file_name.get_extension())
				real_file_name = real_file_name.substr(0, real_file_name.length() - str("_data" + ext).length())
		elif is_script:
			real_file_name = file_name
	
	#var is_registry_entry:bool = false
	if file is RegistryEntry: 
		#is_registry_entry = true
		uses_registry_entries = true
		file.entry_name = file_name
		file.setup_entry(); chat(str("setting up RegistryEntry: " + file.entry_name))
	
	if uses_registry_entries and not valid_entry_file:
		var entry_name:String = file_name
		entry_name = await clean_functional_tags_from_file_name(file_name)
		var folder_name: String = File.begins_with_slash(file_path.get_base_dir(), false)
		if element_is_folder:
			entry_name = folder_name
		
		var entry_object:RegistryEntry
		if uses_groups:
			var group = await RegistryEntryGroup.get_group_from_element_filepath(data, file_path, group_folder_paths, directories_to_load)
			if not group: group = await RegistryEntryGroup.find_group(folder_name, data)
			if not group.data.has(entry_name):
				if skip_loose_files:
					chat("There is no loaded RegistryEntry for the following asset, skipping: " + file_path)
					load_index += 1
					is_loading_file = false
					return null
				else:
					chat("making impromptu RegistryEntry in group: " + group.name + ", for file: " + real_file_name)
					#group.data[real_file_name] = RegistryEntry.make_entry(real_file_name)
					group.add(RegistryEntry.make_entry(real_file_name), real_file_name)
					entry_object = group.data.get(real_file_name)
			else: 
				var entry = group.grab(entry_name)
				if entry is int:
					chat("replacing placeholder for RegistryEntry in group: " + group.name + ", for file: " + real_file_name)
					#group.data[entry_name] = 
					group.erase(entry_name)
					group.add(RegistryEntry.make_entry(entry_name), entry_name)
					entry = group.grab(entry_name)
				entry_object = entry
		else:
			if not db.has(entry_name): 
				if skip_loose_files:
					chat("There is no loaded RegistryEntry for the following asset, skipping: " + file_path)
					load_index += 1
					is_loading_file = false
					return null
				else:
					chat("making impromptu RegistryEntry for file: " + real_file_name)
					#data[real_file_name] = RegistryEntry.make_entry(real_file_name)
					if db.has(real_file_name):
						var v = db.grab(real_file_name)
						if v is int or v is RegistryEntry and element_is_folder: db.erase(real_file_name)
						else: warn("OH NO")
					db.add(RegistryEntry.make_entry(real_file_name), real_file_name)
					entry_object = data.get(real_file_name)
			else: 
				var entry = db.grab(entry_name)
				if entry is int:
					chat("replacing placeholder for RegistryEntry in: " + db.name + ", for file: " + real_file_name)
					#group.data[entry_name] = 
					var v = db.grab(real_file_name)
					if v is int or element_is_folder: db.erase(entry_name)
					db.add(RegistryEntry.make_entry(entry_name), entry_name)
					entry = db.grab(entry_name)
				entry_object = entry
		
		if not entry_object: if debug: push_error("DEBUG: Nil object returned instead of RegistryEntry for the following asset: " + file_path)
		entry_object.register_asset(real_file_name, file)
	else:
		if uses_groups:
			var group = await RegistryEntryGroup.get_group_from_element_filepath(data, file_path, group_folder_paths, directories_to_load)
			#group.data[real_file_name] = file
			# check for and remove any placeholder in this index
			if group.has(real_file_name):
				var v = group.grab(real_file_name)
				if v is int or element_is_folder: group.erase(real_file_name)
			group.add(file, real_file_name)
		else:
			#data[real_file_name] = file
			# check for and remove any placeholder in this index
			if db.has(real_file_name):
				var v = db.grab(real_file_name)
				if v is int or element_is_folder: db.erase(real_file_name)
			db.add(file, real_file_name)
	
	var file_size = unloaded_data_sizes[file_path]
	load_work.emit(file_size)
	
	await RenderingServer.frame_post_draw
	
	load_index += 1
	is_loading_file = false
	return file


func handle_interactive_load(file_path:String) -> void:
	var file_size = unloaded_data_sizes[file_path]
	var load_progress = ResourceLoader.load_threaded_get_status(file_path, [1])
	var this_workload = int(floor(load_progress * file_size))
	
	if last_file_workload == 0:
		last_file_workload = this_workload
	else:
		this_workload = this_workload - last_file_workload
	
	if this_workload > 0:
		load_work.emit(this_workload)


func _process(_delta):
	if not doing_load: return
	
	if await update_unloaded_data_directory(): return
	
	var file_path:String = unloaded_data[unloaded_data_dir_idx][load_index]
	#if file_path.ends_with(".tscn.remap"): file_path = file_path.substr(0, file_path.length() - 6)
	
	
	if not is_loading_file:
		try_load_next_file(file_path)
	else:
		var load_status = ResourceLoader.load_threaded_get_status(file_path)
		if load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			handle_interactive_load(file_path)
		elif load_status == ResourceLoader.THREAD_LOAD_LOADED:
			var file = ResourceLoader.load_threaded_get(file_path)
			handle_loaded_file(file, file_path)
		else:
			chat(str("ResourceLoader LoadStatus Code: " + str(load_status)), Text.COLORS.red)
			chat(str("REGISTRY FILE LOADING ERROR! File: " + file_path), Text.COLORS.red)
			#assert(false)
			load_index += 1
			is_loading_file = false
