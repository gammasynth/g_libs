class_name FileObjectUtil

#region File Object Serialization
static func string_to_vector2(string := "") -> Vector2:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")
		return Vector2(int(array[0]), int(array[1]))
	return Vector2.ZERO




static func deserialize_object(dict:Dictionary) -> Object:
	
	var obj: Object = null
	
	var script: GDScript = null
	if dict.has("SERIALIZED_OBJECT_SCRIPT_PATH"):
		var script_path = dict["SERIALIZED_OBJECT_SCRIPT_PATH"]
		script = load(script_path)
		obj = script.new()
	
	if not script:
		if dict.has("SERIALIZED_OBJECT_CLASS_NAME"):
			var obj_class_name:String = dict["SERIALIZED_OBJECT_SCRIPT_PATH"]
			if ClassDB.can_instantiate(obj_class_name):
				obj = ClassDB.instantiate(obj_class_name)
			else:
				printerr(str("No ClassName: " + obj_class_name + " in ClassDB!"))
	
	if not obj:
		printerr("No valid script path or ClassName for dictionary to object initialization! Attempting with base object...")
		obj = Object.new()
	
	for property_name in dict.keys():
		var property_value = dict[property_name]
		obj.set(property_name, deserialize_value(property_value))
	return obj



static func deserialize_value(value:Variant) -> Variant:
	if value is Dictionary:
		if value.has("IS_SERIALIZED_OBJECT"):
			return deserialize_object(value)
		
		var dict := {}
		for key in value.keys():
			key = deserialize_value(key)
			var entry = value[key]
			entry = deserialize_value(entry)
			dict[key] = entry
		value = dict
	elif value is Array:
		var arr := []
		for entry in value:
			entry = deserialize_value(entry)
			arr.append(entry)
		value = arr
	
	return value

static func is_value_serializable(value:Variant) -> bool:
	if value is Object or value is Array or value is Dictionary:
		return true
	return false

static func serialize_value(value:Variant) -> Variant:
	if value is Object:
		value = serialize_object(value)
	elif value is Array:
		var arr := []
		for entry in value:
			if is_value_serializable(entry):
				entry = serialize_value(entry)
			arr.append(entry)
	elif value is Dictionary:
		var dict: Dictionary = {}
		for key in value.keys():
			var entry = value[key]
			if is_value_serializable(key):
				key = serialize_value(key)
			if is_value_serializable(entry):
				entry = serialize_value(entry)
			dict[key] = entry
		value = dict
	return value

static func serialize_object(obj:Object) -> Dictionary:
	var dict : Dictionary = {}
	var script: GDScript = obj.get_script()
	
	dict["IS_SERIALIZED_OBJECT"] = true
	
	if script:
		var script_path: String = script.get_path()
		if not script_path.is_empty(): 
			dict["SERIALIZED_OBJECT_SCRIPT_PATH"] = script_path
	
	var obj_class_name: String = obj.get_class()
	if not obj_class_name.is_empty(): 
		dict["SERIALIZED_OBJECT_CLASS_NAME"] = obj_class_name
	
	#print('Properties of "%s":' % [ resource_script.resource_path ])
	for property_info in script.get_script_property_list():
		var property: String = property_info.name
		var value = obj.get(property)
		
		value = serialize_value(value)
		
		dict[property] = value
		#print(' %s = %s' % [ property_name, property_value ])
	return dict
#endregion


#region File Object Saving and Loading

static func load_dict_file_at_path_by_name(file_path:String, file_name:String, passkey:String = "key") -> Dictionary:
	return load_dict_file(str(file_path + file_name), passkey)

## Uses load_text_file to load a String from a Text-Based File in the FileSystem
## Uses JSON.parse to convert the loaded String into a Dictionary
static func load_dict_file(file_path:String, passkey:String = "", dire: bool = false) -> Dictionary:
	file_path = str(file_path)
	var file_dict: Dictionary = {}
	# Grab the String text from loading the file
	var text_file:String = FileUtil.load_text_file(file_path, passkey)
	# Check if the String is empty
	if text_file.is_empty(): 
		if dire: assert(false, "dictionary load failed empty file: " + file_path)
		return {}
	# Parse the String with JSON
	var json = JSON.new()
	var error = json.parse(text_file)
	# Check if String was Parsed without Error
	if error == OK: file_dict = json.data;
	else: 
		if dire: assert(false, str("dictionary load failed, bad JSON parse: " + json.get_error_message(), " in ", text_file, " at line ", json.get_error_line(), ", in file_path: " + file_path))
		return {}
	# Check if the parsed string is not a Dictionary
	if not file_dict is Dictionary: 
		if dire: assert(false, str("dictionary load failed", "file is not dictionary: " + file_path))
		return {}
	# Return the loaded Dictionary if successful
	return file_dict

## Use JSON.stringify to convert a Dictionary into a String and save_text_file to save the String to a Text-Based File in the FileSystem.
static func save_dict_file_at_path_by_name(file_dict:Dictionary, file_path:String, file_name:String, passkey:String = "") -> Error:
	var json_string = JSON.stringify(file_dict, "    ", false)
	var save_error: Error = FileUtil.save_text_file_at_path_by_name(json_string, file_path, file_name, passkey)
	return save_error

## Use JSON.stringify to convert a Dictionary into a String and save_text_file to save the String to a Text-Based File in the FileSystem.
static func save_dict_file(file_dict:Dictionary, file_path:String, passkey:String = "") -> Error:
	var json_string = JSON.stringify(file_dict, "    ", false)
	var save_error: Error = FileUtil.save_text_file(json_string, file_path, passkey)
	return save_error

## Load all GDScript objects from Directory
#static func load_all_gdscript_classes_from_directory(file_path:String) -> Array[GDScript]: 
	#var all_loaded_objects: Array[Object] = load_all_objects_from_directory(file_path)
	#var all_gdscript_classes: Array[GDScript] = []
	#for object in all_loaded_objects:
		#if object is GDScript:
			#all_gdscript_classes.append(object)
		#else:
			#file_error("Load error: LOAD_ALL_GD_FROM_DIR, Bad Object: Not GDScript Object!")
			#file_error(str(object))
			#File.file_loading_error()
	#
	#return all_gdscript_classes

## Load a Directory at file_path and return any files found as Dictionary of loaded Objects.
## This will ignore SubDirectories, and will only search in the root of given file_path.
## The Dictionary's keys will be each value's corresponding file name.
static func load_all_gdscript_classes_from_directory_with_filenames(folder_path:String, keep_file_extensions:bool=false) -> Dictionary: 
	var all_scripts: Dictionary = {}
	var dir = DirAccess.open(folder_path)
	if not dir: return all_scripts#Core.system_event("script dictionary load failed", str("nonexistent directory: " + folder_path), 1); return all_scripts
	# Use DirAccess to list through the Directory's contents as FileName Strings
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			# if current File in list is valid and not a SubDirectory, load as Object and add to the Dictionary
			var loaded_object = load_object_from_file_path_and_name(folder_path, file_name)
			if loaded_object != null:
				var script_name = file_name
				# Remove any file extensions, if any, and if not disabled
				if not keep_file_extensions:
					script_name = FileUtil.remove_extension_from_file_path(script_name)
				# add the Object to the Dictionary by FileName
				all_scripts[script_name] = loaded_object
		file_name = dir.get_next()
	# Return the Dictionary of named Objects
	return all_scripts

## Load a Directory at folder_path and return any files found as Array[Object] list of loaded Objects
## This will ignore SubDirectories, and will only search in the root of given file_path
static func load_all_objects_from_directory(folder_path:String) -> Array[Object]: 
	var all_objects: Array[Object] = []
	var dir = DirAccess.open(folder_path)
	if not dir: return all_objects#Core.system_event("objects array load failed", str("nonexistent directory: " + folder_path), 1); return all_objects
	# Use DirAccess to list through the Directory's contents as FileName Strings
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			# if current File in list is valid and not a SubDirectory, load as Object and add to the Array list
			var loaded_object = load_object_from_file_path_and_name(folder_path, file_name)
			if loaded_object != null:
				all_objects.append(loaded_object)
		file_name = dir.get_next()
	return all_objects

## Load a Directory at folder_path and return any Files found as Dictionary of loaded Objects.
## This will ignore SubDirectories, and will only search in the root of given file_path.
## The Dictionary's keys will be each value's corresponding file name
static func load_all_objects_from_directory_with_filenames(folder_path:String, keep_file_extensions:bool=false) -> Dictionary: 
	var objects_dict: Dictionary = {}
	var dir = DirAccess.open(folder_path)
	if not dir: return {}#Core.system_event("objects dictionary load failed", str("nonexistent directory: " + folder_path), 1); return {}
	# Use DirAccess to list through the Directory's contents as FileName Strings
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			# if current File in list is valid and not a SubDirectory, load as Object and add to the Dictionary
			var loaded_object = load_object_from_file_path_and_name(folder_path, file_name)
			if loaded_object != null:
				var object_name = file_name
				# Remove any file extensions, if any, and if not disabled
				if not keep_file_extensions:
					object_name = FileUtil.remove_extension_from_file_path(object_name)
				# add the Object to the Dictionary by FileName
				objects_dict[object_name] = loaded_object
		file_name = dir.get_next()
	# Return the Dictionary of named Objects
	return objects_dict

## Load and return an Object from a File at folder_path + file_name, if there is one, only useable for local project resources.
static func load_object_from_file_path_and_name(folder_path:String, file_name:String) -> Object:
	var file_path:String = str(folder_path + file_name)
	return load_object_from_file(file_path)

## Load and return an Object from a File at file_path, if there is one, only useable for local project resources.
static func load_object_from_file(file_path:String) -> Object:
	file_path = str(file_path)
	var loaded_object = load(file_path)
	#if not loaded_object is Object: Core.system_event("object load failed", str("not an Object instance: " + file_path), 1)
	return loaded_object


## Load and return a GDScript File at folder_path + file_name, if there is one, only useable for local project resources.
static func load_gdscript_from_file_path_and_name(folder_path:String, file_name:String, from_user:bool=false) -> GDScript:
	return load_gdscript_file(str(folder_path + file_name), from_user)

## Load and return a GDScript File at file_path, if there is one, only useable for local project resources.
static func load_gdscript_file(file_path:String, from_user:bool=false) -> GDScript:
	file_path = str(file_path)
	var loaded_object
	if from_user:
		var text:String = FileUtil.load_text_file(file_path)
		var script := GDScript.new()
		script.set_source_code(text)
		script.reload()
		loaded_object = script
	else:
		loaded_object = load(file_path)
		#print_rich(str("[color=cyan]" + str(loaded_object) + "[/color]"))
	#if not loaded_object is GDScript: Core.system_event("script load failed", str("not a GDScript instance: " + file_path), 1)
	return loaded_object


static func load_image(file_path:String) -> Texture2D:
	if not FileUtil.get_file(file_path): return null
	if not FileUtil.is_user_dir(file_path): return load(file_path)
	var img:Image = Image.load_from_file(file_path)
	var img_tex: ImageTexture = ImageTexture.create_from_image(img)
	return img_tex

## ONLY MP3 LOADING IS CURRENTLY SUPPORTED!
## @experimental
static func load_audio(file_path:String) -> AudioStreamMP3:
	if not FileUtil.get_file(file_path): return null
	if not FileUtil.is_user_dir(file_path): return load(file_path)
	var file = FileAccess.open(file_path, FileAccess.READ)
	var buffer = file.get_buffer(file.get_len())
	file.close()
	var stream = AudioStreamMP3.new()
	stream.data = buffer
	return stream


static func try_load_file(file_path:String, only_user_files:bool=false) -> Variant:
	if only_user_files and not FileUtil.is_user_dir(file_path): return null
	var _is_godot_resource:bool = false
	var is_image_resource:bool = false
	var is_audio_resource:bool = false
	var is_script_resource:bool = false
	
	var is_valid:bool = true
	
	if FileUtil.is_valid_godot_resource(file_path): _is_godot_resource = true
	elif FileUtil.is_valid_image_resource(file_path): is_image_resource = true;
	elif FileUtil.is_valid_audio_resource(file_path): is_audio_resource = true;
	elif FileUtil.is_valid_gd_script_file(file_path): is_script_resource = true;
	else: is_valid = false;
	
	if not is_valid: return null
	
	if is_image_resource: return load_image(file_path)
	elif is_audio_resource: return load_audio(file_path)
	elif is_script_resource: return load_gdscript_file(file_path)
	else: return null

#endregion
