extends PanelContainer

## DatabaseNode is a wrapper class for a Node to use a Database
class_name DatabasePanelContainer

@export var debug:bool=false:
	get: return db.debug
	set(b): db.debug = b

@export var deep_debug:bool=false:
	get: return db.deep_debug
	set(b): db.deep_debug = b


var db : Database
func get_database() -> Database: return db


## data is the actively loaded database as a dictionary, which actually exists in db under data. 
var data:Dictionary:
	get: return db.data
	set(d):
		db.data = d


var parent_node: Node = null
var parent_node_is_database: bool = false

var parent_database_node: Node = null
var is_nested_database : bool = false


func _create_database(params:Array=[name]) -> Database:
	return Database.new.callv(params)

#region Godot Node Initialization and SceneTree Readying
func _init(_name:String="NODE_OBJ", _key:Variant=_name) -> void:
	
	if _name == "NODE_OBJ":
		if not name.is_empty():
			_name = name
			_key = _name
	
	if _name != "NODE_OBJ":
		name = _name
	
	db = _create_database()
	db.key = _key
	
	db.name_changed.connect(func(n1, _n2): name = n1)
	
	await _initialized()
	return
func _initialized() -> void: return


func _ready() -> void:
	find_database_node_parent()
	if not name.is_empty() and name != "NODE_OBJ":
		if db.name == "NODE_OBJ":
			db.name = name
		if db.key == "NODE_OBJ":
			db.key = name
	
	await _ready_up()
	return
func _ready_up() -> Error: return OK


func is_node_parent_database(node:Node) -> bool:
	if not node: return false
	if not node.has_method("get_database"): return false
	
	if node == parent_node: parent_node_is_database = true
	
	parent_database_node = node
	is_nested_database = true
	if not node.is_node_ready():
		node.ready.connect(func(): parent_database_node.db.add(self, name))
	else:
		parent_database_node.db.add(self, name)
	return true

func find_database_node_parent():
	parent_node = get_parent()
	if is_node_parent_database(parent_node): return
	
	# this node's parent node is not a database
	# check parents recursively until we find a database or a window (window could be the root)
	# will use safety of max iterations
	var max_i: int = 10000
	var i: int = 0
	var local_parent: Node = parent_node
	
	while not is_nested_database and i < max_i:
		i += 1
		
		if not local_parent: return
		if not local_parent.has_method("get_parent"): return
		
		local_parent = local_parent.get_parent()
		if not is_node_parent_database(local_parent):
			if local_parent is Window:
				return
	return
#endregion



#region Instance Tick Operation
func start() -> Error:
	var err : Error = OK
	err = await _pre_start()
	err = await _start()
	err = await _post_start()
	return err

func _pre_start() -> Error: return OK
func _start() -> Error: return await db.tick(_tick_started, _tick, _finish_tick)
func _post_start() -> Error: return OK


func _tick_started() -> Error: return OK
func _tick() -> Error: return OK
func _finish_tick() -> Error: return OK
#endregion


#region RefData Dictionary Data Handling

func data_size() -> int: return db.data_size()
func find_data(key:String, search:Database.SEARCH=Database.SEARCH.SINGLE) -> Variant: return db.find_data(key, search)
func grab(at_key:Variant) -> Variant: return db.grab(at_key)
#endregion


#region Chat / Warn / Check
func chat(text:String, clr:Variant=-1, force:bool=false, return_ok:bool=false) -> Variant:return db.chat(text, clr, force, return_ok)
func chatd(text:String, clr:Variant=Text.COLORS.gray, return_ok:bool=false) -> Variant: return db.chatd(text, clr, return_ok)

func warn(text: String = "WARNING", err: Error = ERR_PRINTER_ON_FIRE, is_error:bool=true, can_break:bool=false) -> void: db.warn(text, err, is_error, can_break)
func warnd(text: String = "WARNING", err: Error = ERR_PRINTER_ON_FIRE, is_error:bool=true, can_break:bool=false) -> void: db.warnd(text, err, is_error, can_break)

func check(text: String = "function_name", err: Error = OK) -> void: db.check(text, err)
func checkd(text: String = "function_name", err: Error = OK) -> void: db.checkd(text, err)
#endregion
