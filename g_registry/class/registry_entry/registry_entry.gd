extends Database

class_name RegistryEntry


static func make_entry(with_entry_name:String) -> RegistryEntry:
	return RegistryEntry.new(with_entry_name)


func setup_entry():
	return _setup_entry()

func _setup_entry():
	pass


func asset_registered(file_name:String) -> Error:
	if debug: print("RegistryEntry: " + name + " | " + " asset registered: " + file_name)
	return OK

func register_asset(file_name:String, asset:Variant) -> Error:
	if debug: print("RegistryEntry: " + name + " | " + " registering asset: " + file_name)
	if await _register_asset(file_name, asset) == OK: return asset_registered(file_name);
	if not data.has(file_name): data[file_name] = asset; return asset_registered(file_name)
	return ERR_ALREADY_EXISTS

func _register_asset(_file_name:String, _asset:Variant) -> Error: return ERR_DATABASE_CANT_READ

func is_entry() -> bool: return true
