class_name FileObjectUtil

static var current_dictionary: Dictionary = {}
static var serialized_objects: Dictionary = {}

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
	
	if current_dictionary.is_empty(): 
		current_dictionary = dict
		dict = current_dictionary
	
	var obj: Object = null
	
	var script: GDScript = null
	if dict.has("SERIALIZED_OBJECT_SCRIPT_PATH"):
		var script_path = dict["SERIALIZED_OBJECT_SCRIPT_PATH"]
		script = load(script_path)
		obj = script.new()
	
	if not script:
		if dict.has("SERIALIZED_OBJECT_CLASS_NAME"):
			var obj_class_name:String = dict["SERIALIZED_OBJECT_CLASS_NAME"]
			if ClassDB.can_instantiate(obj_class_name):
				obj = ClassDB.instantiate(obj_class_name)
			else:
				printerr(str("No ClassName: " + obj_class_name + " in ClassDB!"))
	
	if not obj:
		printerr("No valid script path or ClassName for dictionary to object initialization! Attempting with base object...")
		obj = Object.new()
	
	
	
	dict.set("DESERIALIZED_OBJ", obj)
	
	if obj is Node and dict.get("IS_SERIALIZED_NODE"):
		obj.request_ready()
		obj.name = dict.get("NODE_ACTUAL_NAME")
		if obj is Control and obj.name == "_connection_layer": return null
		dict.set("DESERIALIZED_NODE", obj)
		if dict.has("SERIALIZED_CHILDREN"):
			var children: Dictionary = dict.get("SERIALIZED_CHILDREN")
			for child_name in children:
				if child_name == "IS_SERIALIZED_CHILDREN_LIST": continue
				
				var child_value:Variant = children.get(child_name)
				if not child_value is Dictionary: continue
				
				if child_value.has("IS_NODE_REF"):
					child_value = search_for_deserialized_node(child_value.get("NODE_REF"), current_dictionary)
				else:
					if not child_value.has("IS_SERIALIZED_OBJECT"): continue
					child_value = deserialize_object(child_value)
					if not child_value: continue
				child_value.name = child_name
				obj.add_child(child_value, true)
	
	
	if dict.has("SCRIPT_PROPERTIES_DICT"):
		var script_dict:Dictionary = dict.get("SCRIPT_PROPERTIES_DICT")
		for property_name in script_dict.keys():
			var property_value = script_dict.get(property_name)
			
			if property_value is Dictionary:
				if property_value.has("IS_NODE_REF"):
					var node_ref:Variant = property_value.get("FULL_NODEPATH_REF")
					if not node_ref: node_ref = property_value.get("NODE_REF")
					if not node_ref: continue
					property_value = search_for_deserialized_node(node_ref, current_dictionary)
				elif property_value.has("ONLY_OBJECT_IDENTIFIER"):
					#dict.set("OBJECT_IDENTIFIER", hash(obj))
					var this_obj_id = property_value.get("ONLY_OBJECT_IDENTIFIER")
					var existing:Variant = search_for_object_by_id(this_obj_id)
					if existing != null: 
						property_value = existing.get("DESERIALIZED_OBJ")
					else: property_value = deserialize_value(property_value)
				else:
					property_value = deserialize_value(property_value)
			else:
				property_value = deserialize_value(property_value)
			
			obj.set(property_name, property_value)
		
	
	if dict.has("OBJECT_PROPERTIES_DICT"):
		var prop_dict:Dictionary = dict.get("OBJECT_PROPERTIES_DICT")
		
		var dont_control:bool = false
		if obj is Control:
			dont_control = true
		
		for property_name in prop_dict.keys():
			if dict.has("SCRIPT_PROPERTIES_DICT"):
				if dict.get("SCRIPT_PROPERTIES_DICT").has(property_name): continue
			var property_value = prop_dict.get(property_name)
			
			if dont_control:
				if property_name == "anchors_preset": continue
				if property_name == "layout_mode": continue
				if property_name == "position" or property_name == "size": continue
				pass
			
			if property_value is Dictionary:
				if property_value.has("IS_NODE_REF"):
					var node_ref:Variant = property_value.get("FULL_NODEPATH_REF")
					if not node_ref: node_ref = property_value.get("NODE_REF")
					if not node_ref: continue
					property_value = search_for_deserialized_node(node_ref, current_dictionary)
				elif property_value.has("ONLY_OBJECT_IDENTIFIER"):
					#dict.set("OBJECT_IDENTIFIER", hash(obj))
					var this_obj_id = property_value.get("ONLY_OBJECT_IDENTIFIER")
					var existing:Variant = search_for_object_by_id(this_obj_id)
					if existing != null: 
						property_value = existing.get("DESERIALIZED_OBJ")
					else: property_value = deserialize_value(property_value)
				else:
					property_value = deserialize_value(property_value)
			else:
				property_value = deserialize_value(property_value)
			
			obj.set(property_name, property_value)
	
	if current_dictionary.get("OBJECT_IDENTIFIER") == dict.get("OBJECT_IDENTIFIER"):
		current_dictionary = {}
	
	return obj



static func deserialize_value(value:Variant) -> Variant:
	
	if value is String:
		var test = str_to_var(value)
		var try_keep:bool = true
		if test is Dictionary:
			if test.has("STRING_DATA"):
				value = test.get("STRING_DATA")
				try_keep = false
		
		if try_keep and test != null and test is not String:
			value = test
	
	if value is Dictionary:
		if value.has("IS_SERIALIZED_OBJECT"):
			return deserialize_object(value)
		
		if value.has("IS_COLOR_VALUE"):
			var color:Color = Color.BLACK
			color.r = value.get("R")
			color.r8 = value.get("R8")
			color.g = value.get("G")
			color.g8 = value.get("G8")
			color.b = value.get("B")
			color.b8 = value.get("B8")
			color.a = value.get("A")
			color.a8 = value.get("A8")
			return color
			
		
		if value.has("IS_VECTOR3i_VALUE"):
			var vec: Vector3i = Vector3i.ZERO
			vec.x = value.get("X")
			vec.y = value.get("Y")
			vec.z = value.get("Z")
			return vec
		if value.has("IS_VECTOR3_VALUE"):
			var vec: Vector3 = Vector3.ZERO
			vec.x = value.get("X")
			vec.y = value.get("Y")
			vec.z = value.get("Z")
			return vec
		if value.has("IS_VECTOR2i_VALUE"):
			var vec: Vector2i = Vector2i.ZERO
			vec.x = value.get("X")
			vec.y = value.get("Y")
			return vec
		if value.has("IS_VECTOR2_VALUE"):
			var vec: Vector2 = Vector2.ZERO
			vec.x = value.get("X")
			vec.y = value.get("Y")
			return vec
		
		
		if value.has("IS_IMAGE_VALUE"):
			var w:int = value.get("WIDTH")
			var h:int = value.get("HEIGHT")
			var mips:bool = value.get("MIPMAPS")
			var f:Image.Format = value.get("FORMAT")
			var data:PackedByteArray = PackedByteArray(Marshalls.base64_to_raw(value.get("DATA")))
			var img: Image = Image.create_from_data(w,h,mips,f,data)
			#img.save_png("user://test.png")
			#print(img.get_pixelv(Vector2i.ZERO))
			#print(type_string(typeof(PackedByteArray(str_to_var(value.get("DATA"))))))
			#print(type_string(typeof(value.get("DATA"))))
			#print(type_string(typeof(data)))
			#print(data)
			
			return img
		if value.has("IS_IMAGETEXTURE_VALUE"):
			var tex: ImageTexture = ImageTexture.create_from_image(deserialize_value(value.get("IMAGE")))
			return tex
		
		if value.has("IS_CALLABLE_VALUE"):
			var obj:Object = null
			if value.has("ONLY_OBJECT_IDENTIFIER"):
				var object_id = value.get("ONLY_OBJECT_IDENTIFIER")
				var obj_dict = search_for_object_by_id(object_id)
				if obj_dict is Dictionary and obj_dict.has("DESERIALIZED_OBJ"):
					obj = obj_dict.get("DESERIALIZED_OBJ")
			else: 
				if value.has("OBJECT_ROOT"): 
					obj = deserialize_object(value.get("OBJECT_ROOT"))
			
			if not obj:
				push_error("UNABLE TO DESERIALIZE CALLABLE OBJECT!")
				return null
			
			var method:StringName = value.get("METHOD_NAME")
			var has_method:bool = obj.has_method(method)
			var try_method = obj.get(method)
			var callable = Callable(obj, method)
			print(callable)
			return callable
		
		var dict := {}
		for key in value.keys():
			var entry = value[key]
			var new_key = deserialize_value(key)
			var new_entry = deserialize_value(entry)
			dict[new_key] = new_entry
		return dict
	elif value is Array:
		var arr := []
		for entry in value:
			entry = deserialize_value(entry)
			arr.append(entry)
		value = arr
	return value

#static func is_value_serializable(value:Variant) -> bool:
	#if not value: return false
	#if not is_instance_valid(value): return false
	#if value is Object or value is Array or value is Dictionary:
		#return true
	#return false

static func serialize_value(value:Variant) -> Variant:
	
	if value is bool or value is int or value is float or value is String: return value
	
	if value is Dictionary:
		var dict: Dictionary = {}
		for key in value.keys():
			var entry = value[key]
			key = serialize_value(key)
			entry = serialize_value(entry)
			dict[key] = entry
		value = dict
	elif value is Array:
		var arr := []
		for entry in value:
			entry = serialize_value(entry)
			arr.append(entry)
	elif value is Color:
		var dict: Dictionary = {}
		dict.set("IS_COLOR_VALUE", true)
		dict.set("R", value.r)
		dict.set("R8", value.r8)
		dict.set("G", value.g)
		dict.set("G8", value.g8)
		dict.set("B", value.b)
		dict.set("B8", value.b8)
		dict.set("A", value.a)
		dict.set("A8", value.a8)
		value = dict
	elif value is Vector3i:
		var dict: Dictionary = {}
		dict.set("IS_VECTOR3i_VALUE", true)
		dict.set("X", value.x)
		dict.set("Y", value.y)
		dict.set("Z", value.z)
		value = dict
	elif value is Vector3:
		var dict: Dictionary = {}
		dict.set("IS_VECTOR3_VALUE", true)
		dict.set("X", value.x)
		dict.set("Y", value.y)
		dict.set("Z", value.z)
		value = dict
	elif value is Vector2i:
		var dict: Dictionary = {}
		dict.set("IS_VECTOR2i_VALUE", true)
		dict.set("X", value.x)
		dict.set("Y", value.y)
		value = dict
	elif value is Vector2:
		var dict: Dictionary = {}
		dict.set("IS_VECTOR2_VALUE", true)
		dict.set("X", value.x)
		dict.set("Y", value.y)
		value = dict
	elif value is Image:
		var dict: Dictionary = {}
		dict.set("IS_IMAGE_VALUE", true)
		dict.set("MIPMAPS", value.has_mipmaps())
		dict.set("WIDTH", value.get_width())
		dict.set("HEIGHT", value.get_height())
		dict.set("FORMAT", value.get_format())
		dict.set("DATA", Marshalls.raw_to_base64(value.get_data()))
		#print(var_to_str(value.get_data()))
		value = dict
	elif value is ImageTexture:
		var dict: Dictionary = {}
		dict.set("IS_IMAGETEXTURE_VALUE", true)
		dict.set("IMAGE", serialize_value(value.get_image()))
		value = dict
	elif value is Object:
		value = serialize_object(value)
	elif value is Callable:
		# try to serialize callable
		if not value.is_valid():
			push_error("TRIED TO SERIALIZE NON-VALID CALLABLE!")
			push_error(str(value))
			return null
		
		var callable_dict:Dictionary = {}
		callable_dict.set("IS_CALLABLE_VALUE", true)
		#var args = []
		#for arg in value.get_bound_arguments():
			#args.append(arg)
		
		var object:Object = value.get_object()
		
		if not object: 
			push_error("TRIED TO SERIALIZE NON-OBJECT CALLABLE!")
			return null
		
		var object_id:int = object.get_instance_id()
		var existing:Variant = search_for_object_by_id(object_id)
		if existing != null: callable_dict.set("ONLY_OBJECT_IDENTIFIER", object_id)
		else: 
			var value_dict: Dictionary = {}
			callable_dict.set("OBJECT_ROOT", value_dict)
			value_dict = serialize_object(object, value_dict)
			callable_dict.set("OBJECT_ROOT", value_dict)
		callable_dict.set("METHOD_NAME", value.get_method())
		
		value = callable_dict
		#return value
	else:
		if value != null and value is not bool and value is not int and value is not float and value is not String:
			#print(str("UNSERIALIZED TYPE: " + type_string(typeof(value)) + " | " + str(value)))
			value = var_to_str({"STRING_DATA" : value})
	return value

static func serialize_object(obj:Object, obj_dict:Dictionary={}) -> Dictionary:
	var dict : Dictionary = obj_dict
	var script: GDScript = obj.get_script()
	
	if current_dictionary.is_empty():
		current_dictionary = dict
		dict = current_dictionary
	
	var local_current_dictionary = current_dictionary
	
	var obj_id:int = obj.get_instance_id()
	if serialized_objects.has(obj_id):return  serialized_objects.get(obj_id)
	
	dict.set("OBJECT_IDENTIFIER", obj_id)
	if not serialized_objects.has(obj_id): serialized_objects.set(obj_id, dict)
	
	dict.set("IS_SERIALIZED_OBJECT", true)
	
	if script:
		var script_path: String = script.get_path()
		if not script_path.is_empty(): 
			dict.set("SERIALIZED_OBJECT_SCRIPT_PATH", script_path)
	
	var obj_class_name: String = obj.get_class()
	if not obj_class_name.is_empty(): 
		dict.set("SERIALIZED_OBJECT_CLASS_NAME", obj_class_name)
	
	if obj is Node:
		dict.set("NODE_ACTUAL_NAME", obj.name)
		dict.set("IS_SERIALIZED_NODE", true)
		dict.set("FULL_NODEPATH_REF", obj.get_path())
		
		var children: Dictionary = {}
		dict.set("SERIALIZED_CHILDREN", children)
		var kids = obj.get_children()
		for child in kids:
			var existing:Variant = search_for_object_by_id(child.get_instance_id())
			if existing != null: 
				children.set(child.name, {"IS_NODE_REF" : true, "NODE_REF" : existing.get("FULL_NODEPATH_REF")})
			else: 
				var child_dict:Dictionary = {}
				children.set(child.name, child_dict)
				child_dict = serialize_object(child, child_dict)
				children.set(child.name, child_dict)
		children.set("IS_SERIALIZED_CHILDREN_LIST", true)
		
	
	
	
	#print('Properties of "%s":' % [ resource_script.resource_path ])
	if script:
		var script_dict:Dictionary = {}
		dict.set("SCRIPT_PROPERTIES_DICT", script_dict)
		serialize_script_properties(script, obj, script_dict)
		dict.set("SCRIPT_PROPERTIES_DICT", script_dict)
		#print(' %s = %s' % [ property_name, property_value ])
		
	
	var prop_dict:Dictionary = {}
	dict.set("OBJECT_PROPERTIES_DICT", prop_dict)
	for property_info in obj.get_property_list():
		
		var property: String = property_info.name
		if property == "script": continue
		if property == "multiplayer": continue
		if dict.has("SCRIPT_PROPERTIES_DICT"):
			if dict.get("SCRIPT_PROPERTIES_DICT").has(property): continue
		
		var value = obj.get(property)
		if value is Transform2D or value is Transform3D: continue
		
		if value is Node:
			var existing:Variant = search_for_object_by_id(value.get_instance_id())
			if existing != null: 
				value = {"IS_NODE_REF" : true, "NODE_REF" : existing.get("FULL_NODEPATH_REF")}
				prop_dict.set(property, value)
			else: 
				var value_dict: Dictionary = {}
				prop_dict.set(property, value_dict)
				value_dict = serialize_object(value, value_dict)
				prop_dict.set(property, value_dict)
		elif value is Object:
			#dict.set("OBJECT_IDENTIFIER", hash(obj))
			var this_obj_id = value.get_instance_id()
			var existing:Variant = search_for_object_by_id(this_obj_id)
			if existing != null: value = {"ONLY_OBJECT_IDENTIFIER" : this_obj_id}
			else: 
				var value_dict: Dictionary = {}
				prop_dict.set(property, value_dict)
				value_dict = serialize_object(value, value_dict)
				prop_dict.set(property, value_dict)
				#if type_string(typeof(value)) == "Nil": continue
				#value = serialize_value(value)
				#prop_dict.set(property, value)
		else: 
			if type_string(typeof(value)) == "Nil": continue
			value = serialize_value(value)
			prop_dict.set(property, value)
	
	
	if current_dictionary.get("OBJECT_IDENTIFIER") == obj.get_instance_id():
		current_dictionary = {}
		serialized_objects.clear()
	return dict
#endregion

static func serialize_script_properties(script:Script, obj:Object, script_dict:Dictionary) -> Dictionary:
	for property_info in script.get_script_property_list():
		var property: String = property_info.name
		var value = obj.get(property)
		if property == "multiplayer": continue
		if value is Transform2D or value is Transform3D: continue
		
		if value is Node:
			var existing:Variant = search_for_object_by_id(value.get_instance_id())
			if existing != null: value = {"IS_NODE_REF" : true, "NODE_REF" : existing.get("FULL_NODEPATH_REF")}
			else: 
				var value_dict: Dictionary = {}
				script_dict.set(property, value_dict)
				value_dict = serialize_object(value, value_dict)
				script_dict.set(property, value_dict)
		elif value is Object:
			#dict.set("OBJECT_IDENTIFIER", hash(obj))
			var this_obj_id = value.get_instance_id()
			var existing:Variant = search_for_object_by_id(this_obj_id)
			if existing != null: value = {"ONLY_OBJECT_IDENTIFIER" : this_obj_id}
			else: 
				var value_dict: Dictionary = {}
				script_dict.set(property, value_dict)
				value_dict = serialize_object(value, value_dict)
				script_dict.set(property, value_dict)
				#if type_string(typeof(value)) == "Nil": continue
				#value = serialize_value(value)
				#script_dict.set(property, value)
		else: 
			if type_string(typeof(value)) == "Nil": continue
			value = serialize_value(value)
			script_dict.set(property, value)
	
	var base_script:Script = script.get_base_script()
	if base_script:
		var base_script_dict:Dictionary = {}
		base_script_dict = serialize_script_properties(base_script, obj, base_script_dict)
		script_dict.merge(base_script_dict)
	
	return script_dict

static func search_for_deserialized_node(nodepath:NodePath, dict:Dictionary=current_dictionary) -> Variant:
	if dict.has("FULL_NODEPATH_REF"):
		if NodePath(dict.get("FULL_NODEPATH_REF")) == NodePath(nodepath):
			if dict.has("DESERIALIZED_NODE"):
				return dict.get("DESERIALIZED_NODE")
			else:
				print("FOUND NODE BUT IT IS NOT DESERIALIZED!")
	for key in dict:
		var value = dict.get(key)
		if value is Dictionary:
			var search: Variant = search_for_deserialized_node(nodepath, value)
			if search != null:
				return search
	return null

#static func search_for_serialized_node(node_name:StringName, dict:Dictionary=current_dictionary) -> Variant:
	#if dict.has("SERIALIZED_CHILDREN"):
		#var found:Variant = search_for_serialized_node(node_name, dict.get("SERIALIZED_CHILDREN"))
		#if found != null: return found
	#else:
		#if dict.has("IS_SERIALIZED_CHILDREN_LIST"):
			#for key in dict:
				#var entry = dict.get(key)
				#if key == node_name and entry is Dictionary and entry.has("IS_SERIALIZED_NODE"): return entry
	#return null

static func search_for_object_by_id(obj_id:int, dict:Dictionary=current_dictionary) -> Variant:#, searched_dictionaries:Array=[]) -> Variant:
	var current_serialized_objects = serialized_objects
	if current_serialized_objects.has(obj_id): return current_serialized_objects.get(obj_id)
	#searched_dictionaries.append(dict.hash())
	if dict.has("OBJECT_IDENTIFIER"):
		if dict.get("OBJECT_IDENTIFIER") == obj_id:
			return dict
		#if dict.has("SERIALIZED_CHILDREN"):
			#var found:Variant = search_for_object_by_id(obj_id, dict.get("SERIALIZED_CHILDREN"))
			#if found != null: return found
	for key in dict:
		var val = dict.get(key)
		if val is Dictionary:
			#if searched_dictionaries.has(val.hash()): continue
			var found:Variant = search_for_object_by_id(obj_id, val)#, searched_dictionaries)
			if found != null: return found
	
	return null

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
