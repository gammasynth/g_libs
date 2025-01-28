extends RegistryModdable

class_name RegistryStack

static var instance:Registry=null;

@export var subregistry_paths: Array[String] = []

## if all registries within a running app exist as children of the first Registry made, they can be accessed globally from registries.
static var registries = {}:
	get: 
		if instance and is_instance_valid(instance): return instance.data
		return {}

## global counter indexing of all registries in app
var registry_idx:int = -1
static var registry_count:int = -1


## If a Registry has Subregistries (other Registries as the elements it contains), we can reference them by their name as a key in subregistries dictionary.
## subregistries property is simply a reference to the data property.
var subregistries = {}:
	get: 
		if subregistry_paths.size() > 0: return data
		return {}

var booted_subregistries:int = 0


func _initialized() -> void:
	registry_count += 1
	registry_idx = registry_count
	if registry_idx == 0:
		instance = self
		_pre_setup_main_registry_subregistries()
		_setup_main_registry_subregistries()
		_post_setup_main_registry_subregistries()
	get_mod_folder_paths()
	set_process(false)


func _pre_setup_main_registry_subregistries() -> void: return

## The user/dev may insert subregistry paths before given the default settings with the export variable, or they can override these functions in an extended script.
func _setup_main_registry_subregistries() -> void:
	if subregistry_paths.size() == 0: 
		subregistry_paths.append("res://core/registry/")
		subregistry_paths.append("res://src/registry/")
	return

func _post_setup_main_registry_subregistries() -> void: return


func _start_registry() -> Error:
	var err = await gather_subregistry_paths()
	if subregistry_paths.size() > 0:
		
		if err == OK: 
			err = await create_registries()
		if err != OK and debug: chat(str("Error creating subregistries: " + error_string(err)))
	return OK

func _registry_started() -> Error:
	if debug and instance == self: 
		print(" ")
		chat("All registries started.", Text.COLORS.cyan)
	return OK


func gather_subregistry_paths() -> Error:
	var registry_folder:String = File.get_folder(registry_path)
	if registry_folder.to_lower() != "registry":
		if name == registry_folder:
			chat(str("linking folder to registry: " + registry_folder))
			subregistry_paths.append(File.get_folder(registry_path, true))
	return await _gather_subregistry_paths()

func _gather_subregistry_paths() -> Error: return OK


func _registry_booting() -> Error:
	if not instance == self: registries[name] = self
	return OK

func _boot_finished() -> Error:
	var err = OK
	if debug:
		chat(str("contains subregistries: " + str(subregistries.size() > 0)))	
	
	if subregistries.size() > 0: 
		chat("Booting subregistries...")
		err = await boot_subregistries()
	return err

func create_registries() -> Error:
	chat("Creating Subregistries...", Text.COLORS.white)
	#print(subregistry_paths)
	# remember to load and create active modded registries later
	for path in subregistry_paths:
		await create_registries_recursive(path)
	return OK

func create_registries_recursive(folder_path:String) -> Error:
	if folder_path == REGISTRY_SCRIPT_PATH: return OK
	if File.is_file(folder_path):
		chat(str("Creating Registry from FilePath: " + folder_path), Text.COLORS.yellow)
		await create_subregistry(folder_path)
		return OK
	
	await create_subregistries_from_folder(folder_path)
	var all_folders = File.get_all_directories_from_directory(folder_path, true)
	for folder in all_folders:
		await create_registries_recursive(folder)
	return OK


func create_subregistries_from_folder(folder_path:String, exclude_file_paths:Array[String]=[]) -> Array[Registry]:
	var new_registries: Array[Registry] = []
	var all_filepaths = File.get_all_filepaths_from_directory(folder_path, "", true)
	var main_subregistry_path: String = str(folder_path + File.get_folder(folder_path) + ".gd")
	if all_filepaths.has(main_subregistry_path):
		all_filepaths.erase(main_subregistry_path)
		all_filepaths.push_front(main_subregistry_path)
	for filepath in all_filepaths:
		if exclude_file_paths.has(filepath): continue;
		var r = await create_subregistry(filepath); 
		if r: 
			if new_registries.has(r) or registries.values().has(r):
				chat(str("created existing registry, ignoring: " + folder_path), Text.COLORS.yellow)
			else:
				new_registries.append(r)
	return new_registries


func _get_existing_subregistry(_subregistry_name:String, _from_database:Dictionary={}, _recursive:bool=false) -> Registry:
	return null

func create_subregistry(script_path:String=REGISTRY_SCRIPT_PATH) -> Registry:
	if script_path == registry_path: return self
	var subregistry_name: String = File.get_file_name_from_file_path(script_path)
	var existing:Registry = await _get_existing_subregistry(subregistry_name, data, true)
	if existing: return existing
	chat(str("loading registry file: " + script_path))
	
	var script: GDScript = File.load_gdscript_file(script_path)
	var subregistry : Registry = script.new(subregistry_name)
	
	#add_child(subregistry, true)
	subregistry.registry_path = script_path
	
	await Make.child(subregistry, self)
	
	#subregistries[subregistry_name] = subregistry
	
	#if not subregistry.is_node_ready():
		#await subregistry.ready
	
	await subregistry.start()
	
	return subregistry



func boot_subregistries() -> Error:
	for subregistry in get_children():
		await subregistry.boot_registry()
	chat("All subregistries booted!", Text.COLORS.white)
	return OK


func registry_finished() -> Error:
	if not subregistries.size() > 0: return await boot_finished()
	booted_subregistries += 1
	if booted_subregistries >= get_child_count():
		# we have finished loading all registries
		return await boot_finished()
	return ERR_CANT_RESOLVE
