extends RegistryStack

## Registry can be used to dynamically load files at runtime, and keep references to files it has loaded.
## All registries can be access globally from Registry.instance
## [br]
## [br]
## Registry depends on the [File] class system.
## [br][br]
## A Registry can be added as a node to a game, and can then be told to search for file paths for any kind of data loaded from files, such as scripts, textures, audio, and other resources.
## [br][br]
## Keep in mind that Registry intends on keying the values it loads into [data] by that loaded file's file name.
class_name Registry


func _clean_functional_tags_from_file_name(file_name:String) -> String:
	file_name = clean_tag_from_file_name(file_name, "example_tag")
	return file_name



static func get_all_registries_from_data(from_data:Dictionary, recursive:bool=false) -> Array[Registry]:
	var all: Array[Registry] = []
	for key in from_data:
		var value = from_data[key]
		if value is Registry:
			if not all.has(value): all.append(value)
			if recursive: 
				var more = get_all_registries_from_data(value.data, true)
				if not more.is_empty(): all.append_array(more)
	return all

static func get_all_registries() -> Array[Registry]:
	if not instance: return []
	return get_all_registries_from_data(registries, true)

func _get_existing_subregistry(subregistry_name:String, from_database:Dictionary={}, recursive:bool=false) -> Registry:
	return search_for_registry(subregistry_name, from_database, recursive)

static func search_for_registry(by_name:String, in_data:Dictionary, recursive:bool=false) -> Registry:
	for key in in_data:
		var value = in_data[key]
		
		if value is Registry:
			if value.name == by_name: return value
			
			if value.subregistries.size() > 0 and recursive:
				var found:Registry = search_for_registry(by_name, value.data, true)
				if found: return found
	return null

static func get_registry(by_name:String, recursive:bool=true) -> Registry:
	for r_key in Registry.instance.subregistries:
		
		var r: Registry = Registry.instance.subregistries[r_key]
		if r.name == by_name: return r
		
		if recursive:
			var found: Registry = search_for_registry(by_name, r.data, recursive); if found: return found;
	return null


static func pull(from_registry_name: String, data_key:Variant, recursive_registry_search:bool = true, recursive_data_search:bool = true) -> Variant:
	var reg: Registry = get_registry(from_registry_name, recursive_registry_search)
	if not reg or reg.db.data_size() == 0: return null
	
	var search: RefData.SEARCH = RefData.SEARCH.SINGLE; if recursive_data_search: search = RefData.SEARCH.DEEP
	var pulled: Variant = reg.find_data(data_key, search)
	return pulled
