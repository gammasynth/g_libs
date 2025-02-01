extends LiveDatabase

class_name RegistryBase

const REGISTRY_SCRIPT_PATH: String = "res://core/class/node/registry/registry.gd"

var registry_path:String = REGISTRY_SCRIPT_PATH


## if boot_load, this Registry will run boot() after it runs start(), this is only useful if you do not use a ModularLoadingScreen for the Registry.
@export var boot_load:bool = false


func _init(_name:String="RegistryBase", _key:Variant=_name) -> void:
	
	if _name == "RegistryBase":
		if not name.is_empty():
			_name = name
			_key = _name
	
	
	name = _name
	
	db = Database.new(_name, _key)
	db.name_changed.connect(func(n1, _n2): name = n1)
	_initialized()
	return
func _initialized() -> void: return


func _start() -> Error:
	assert(name is StringName)
	chat(" ")
	chat("Starting Registry...", Text.COLORS.white)
	
	var err = OK
	err = await _start_registry()
	warn("Starting registry", err)
	
	err = await _notify_loader_of_worker()
	warn("Notifying loader workers", err)
	chat("Registry started.", Text.COLORS.white)
	
	err = await registry_started()
	warn("registry_started function", err)
	
	return err

func _start_registry() -> Error: return OK

func registry_started() -> Error:
	var err = await _registry_started()
	if boot_load:
		err = await boot()
	return err

func _registry_started() -> Error: return OK




func boot() -> Error:
	return await boot_registry()

func _boot_registry() -> Error:
	# override this function to set name and what directories to load files from for this registry
	if name == "RegistryBase": warn("un-named registry!"); db.name = "Un-Named Registry"
	directories_to_load = []
	return OK

func _registry_booting() -> Error: return OK

func boot_registry() -> Error:
	if debug:
		print(" ")
		chat("Booting Registry...", Text.COLORS.white)
	
	var err = await _boot_registry()
	if err != OK:
		chat("Booting error!", Text.COLORS.red)
		return err
	
	#var modded_registry_filepaths_array:Array = await boot_modded_files_for_registry()
	
	# This will need to be modified later to only load modded files if that mod is enabled.
	#directories_to_load.append_array(modded_registry_filepaths_array) # currently not loading modded files
	chat(name + " | " + "load directories: " + str(directories_to_load));
	
	err = await _registry_booting()
	
	err = await _hookup_loader()
	if err != OK:
		chat("Loader hookup error!", Text.COLORS.red)
		#return err
	
	err = await load_registry_files()
	if err: chat(str("loading error: " + error_string(err)))
	
	
	
	err = await boot_finished()
	
	return err

func _boot_finished() -> Error: return OK

func boot_finished() -> Error:
	var err = await _boot_finished()
	
	chat("Registry booted!", Text.COLORS.white)
	return err

func _notify_loader_of_worker() -> Error:
	if not load_tracker: return OK
	load_tracker.connected_workers += 1
	return OK



func load_registry_files() -> Error:
	var err = await _load_registry_files()
	if not load_is_finished:
		await finish_load()
	return err

## Base function to interactively load files, based on the [Registry] parameters, in any directories from [directories_to_load].
## Called on each registry's [boot()].
func _load_registry_files() -> Error:
	
	var dir_idx:int = 0
	for directory in directories_to_load:
		#if uses_entry_groups:
			#handle_groups_collection(directory, dir_idx)
		#else:
			#collect_unloaded_directory_data(directory, dir_idx)
		await handle_groups_collection(directory, dir_idx)
		dir_idx += 1
	
	for dir in unloaded_data:
		for new_data in unloaded_data[dir]:
			var file := FileAccess.open(new_data, FileAccess.READ)
			if not file: continue;
			var file_size := file.get_length()
			
			unloaded_data_sizes[new_data] = file_size
			
			total_workload += int(floor(file_size))
	
	if not unloaded_data.is_empty():
		if debug: 
			for dir in unloaded_data: chat("found unloaded data: " + str(File.get_file_names_from_file_paths(Cast.array_string(unloaded_data[dir]), true)))
		doing_load = true
		begin_load.emit(total_workload)
		
		
	
	await RenderingServer.frame_post_draw
	if doing_load:
		if debug: 
			print(" ")
			chat("Loading files for regsitry...", Text.COLORS.white, true)
		set_process(true)
		await finished_load
	#else:
		#finish_load()
	
	return OK



func preestablish_registry_entry(entry_name:String, group:RegistryEntryGroup=null, with_instance:bool=false) -> Error:
	entry_name = await clean_functional_tags_from_file_name(entry_name)
	
	if group:
		if group.has(entry_name): return OK
	else:
		if db.has(entry_name): return OK
	
	var g = ""; if group: g = str(group.group_name + "/")
	
	chatd(str("pre-establishing name for RegistryEntry at: " + g + entry_name), Text.COLORS.yellow, true)
	
	var val = 1; if with_instance: val = RegistryEntry.make_entry(entry_name)
	uses_registry_entries = true
	
	if group:
		if group.group_name == entry_name:
			chat(("error: supposed RegistryEntry with same name as parent group: "), Text.COLORS.red)
			return ERR_BUG
		group.add(val, entry_name)
	else:
		db.add(val, entry_name)
	return OK

func collect_unloaded_directory_data(directory:String, dir_idx:int, group:RegistryEntryGroup=null) -> Error:
	if debug: 
		chat(str("Collecting data from directory: " + directory))
	
	var filepaths = File.get_all_filepaths_from_directory(directory, "", true)
	#print(filepaths)
	
	#var folder_paths = FileManager.get_all_directories_from_directory(directory, true)
	##print(folder_paths)
	#for folder in folder_paths:
		#if not RegistryEntryGroup.is_subfolder_a_group(folder):
			## we will assume this folder is an element with files inside under a similar name
			#filepaths.append_array(FileManager.get_all_filepaths_from_directory(folder, "", true))
	
	
	for file_path in filepaths:
		var valid_file = File.is_valid_file(file_path)
		if File.is_import_info_file(file_path): valid_file = false
		if valid_file:
			if unloaded_data.has(dir_idx):
				unloaded_data[dir_idx].append(file_path)
			else:
				unloaded_data[dir_idx] = [file_path]
	
	# Check for possible RegistryEntry files in this unloaded data directory, and ensure they are the first elements.
	if unloaded_data.has(dir_idx):
		var unloaded_data_directory: Array = unloaded_data[dir_idx]
		var old_unloaded_data_directory = unloaded_data_directory.duplicate()
		var ordered_unloaded_data_directory = []
		
		var has_registry_entry:bool = false
		
		var folder_name:String = File.get_folder(directory)
		var real_folder_name:String = folder_name
		while real_folder_name.substr(real_folder_name.length() - 1).is_valid_int():
			real_folder_name = real_folder_name.left(real_folder_name.length() - 1)
		if not group: 
			group = await RegistryEntryGroup.find_group(real_folder_name, data)
			if deep_debug: if group: chat(str("found group: " + group.group_name))
		else:
			if deep_debug: chat(str("existing group: " + group.group_name))
		#if group or data.has(folder_name):
			#has_registry_entry = true
		
		
		for file_path in unloaded_data_directory:
			var file_folder_name = File.get_folder(file_path)
			if file_folder_name != folder_name:
				continue
			#var entry_name:String = ""
			if file_path.ends_with("_data.gd"):
				#entry_name = file_path.left(file_path.length() - "_data.gd".length())
				has_registry_entry = true
				chat(str("found possible RegistryEntry file: " + file_path + ", moving to first priority for its directory load."))
				ordered_unloaded_data_directory.append(file_path)
				old_unloaded_data_directory.erase(file_path)
				preestablish_registry_entry(folder_name, group)
			
			#if FileManager.remove_extension_from_file_path(FileManager.get_file_name_from_file_path(file_path)) == folder_name:
			if File.get_file_name_from_file_path(file_path) == folder_name:
				#print(group)
				#has_registry_entry = true
				preestablish_registry_entry(folder_name, group)
			
		
		if not group and not has_registry_entry:
			chat(str("creating RegistryEntry for folder: " + folder_name))
			#data[folder_name] = RegistryEntry.make_entry(folder_name)
			var push:bool = true
			if db.has(folder_name):
				var v = db.grab(folder_name)
				if v is int and v == 1:
					db.erase(folder_name)
				else:
					push = false
			
			if push:
				db.add(RegistryEntry.make_entry(folder_name), folder_name)
				has_registry_entry = true
				element_is_folder = true
		
		if not has_registry_entry:
			for file_path in unloaded_data_directory:
				var file_folder_name = File.get_folder(file_path)
				if file_folder_name != folder_name: continue
				var file_name = File.get_file_name_from_file_path(file_path)
				preestablish_registry_entry(file_name, group, true)
		
		
		if not ordered_unloaded_data_directory.is_empty():
			ordered_unloaded_data_directory.append_array(old_unloaded_data_directory)
			unloaded_data[dir_idx] = ordered_unloaded_data_directory
	
	return OK






func handle_groups_collection(folder_path:String, dir_idx:int, parent_group:RegistryEntryGroup=null) -> Error:
	
	var directory_subfolders : Array[String] = File.get_all_directories_from_directory(folder_path, true)
	for subfolder in directory_subfolders:
		if await RegistryEntryGroup.is_subfolder_a_new_group(subfolder, data):
			var d = data
			if parent_group: d = parent_group.data
			var group = await RegistryEntryGroup.find_group(File.get_folder(subfolder), d)
			if group:
				await handle_groups_collection(subfolder, dir_idx, group)
			else:
				await create_group(subfolder, parent_group, dir_idx)
		else:
			var d = data
			if parent_group: d = parent_group.data
			var group = await RegistryEntryGroup.find_group(File.get_folder(subfolder), d)
			if parent_group and not group: group = parent_group
			if File.has_files(subfolder):
				await collect_unloaded_directory_data(subfolder, dir_idx, group)
			elif group:
				await handle_groups_collection(subfolder, dir_idx, group)
	if File.has_files(folder_path):
		await collect_unloaded_directory_data(folder_path, dir_idx)
	if File.is_file(folder_path):
		var valid_file = File.is_valid_file(folder_path)
		if File.is_import_info_file(folder_path): valid_file = false
		if valid_file:
			if unloaded_data.has(dir_idx):
				unloaded_data[dir_idx].append(folder_path)
			else:
				unloaded_data[dir_idx] = [folder_path]
	return OK

func create_group(group_path, parent_group, dir_idx) -> Error:
	uses_groups = true
	var group_name = File.get_folder(group_path)
	var group = RegistryEntryGroup.new(group_name)
	
	if not group_directory_names.has(group_name): 
		group_directory_names.append(group_name)
	else:
		return OK
	
	if parent_group:
		#parent_group.data[group_name] = group
		parent_group.add(group, group_name)
		chat(str("creating subgroup: " + group_name + " , in parent group: " + parent_group.group_name))
	else:
		#data[group_name] = group
		db.add(group, group_name)
		chat(str("creating new group: " + group_name))
	
	if not group_folder_paths.has(group_name): group_folder_paths[group_name] = group_path
	
	var folder_paths = File.get_all_directories_from_directory(group_path, true)
	if folder_paths.is_empty():
		await collect_unloaded_directory_data(group_path, dir_idx)
	
	for subfolder in folder_paths:
		#print(subfolder)
		if await RegistryEntryGroup.is_subfolder_a_new_group(subfolder, data):
			#print("is group")
			var subgroup_name = File.get_folder(subfolder)
			if not parent_group:
				if not data.has(subgroup_name):
					await create_group(subfolder, group, dir_idx)
				else:
					await collect_unloaded_directory_data(subfolder, dir_idx)
			else:
				if not parent_group.data.has(subgroup_name):
					await create_group(subfolder, group, dir_idx)
				else:
					await collect_unloaded_directory_data(subfolder, dir_idx)
		else:
			await collect_unloaded_directory_data(subfolder, dir_idx, group)
	return OK
