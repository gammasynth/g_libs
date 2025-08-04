extends RefCounted

## RefInstance is a debuggable, nameable, keyable RefCounted Object, with the ability to chat/warn/check and start and tick.
##
## RefInstance can keep a reference to a [parent_instance] that owns this instance, if there is one.[br]
## [br]
## [chat] can be used to print messages by force or only if [debug], [warn] and [check] is useful for error debugging.
## [br]
## Functional processes can be inserted in overridden tick functions, helping with order systems.
class_name RefInstance

#region Instance Properties

static var origin_instance: RefInstance = null
var is_origin_instance: bool = false

signal started

signal starting_tick
signal finished_tick


#region Debug
signal debug_toggled(b:bool)

static var debug_all: bool = false
static var deep_debug_all: bool = false

static var allow_chat:bool = true
static var chat_mirror_callable:Variant = null

@export var debug:bool=false: get = get_debug, set = set_debug
func get_debug() -> bool: return debug or debug_all;
func set_debug(_debug:bool) -> void: debug_toggled.emit(_debug); debug = _debug; if origin_instance == self: debug_all = debug;

signal deep_debug_toggled(b:bool)
@export var deep_debug:bool=false: get = get_deep_debug, set = set_deep_debug
func get_deep_debug() -> bool: return deep_debug or deep_debug_all;
func set_deep_debug(_deep_debug:bool) -> void: deep_debug_toggled.emit(_deep_debug); deep_debug = _deep_debug; if origin_instance == self: deep_debug_all = deep_debug
#endregion

#region Instance Name
signal name_changed(new_name: String, old_name: String)

var name : String = "OBJ": set = set_name
func set_name(_name) -> void: var old = name; name = _name; name_changed.emit(_name, old)

var persona: String:
	get:
		if has_persona: return persona
		return name
	set(s):
		has_persona = true
		persona = s
var has_persona: bool = false
#endregion

#region Instance Key
@export var key: Variant = null: get = _get_key, set = _set_key
func _get_key() -> Variant: return key
func _set_key(_key) -> void: key = _key; if _key is String or str(_key) is String and str(_key).length() > 0: name = _key

var parent_instance: RefInstance: get = _get_parent_instance
func _get_parent_instance() -> RefInstance: return parent_instance
#endregion

#endregion



func _init(_name:String="OBJ", _key:Variant=_name) -> void:
	if origin_instance == null: origin_instance = self; is_origin_instance = true
	
	name = _name
	key = _key

#region Instance Tick Operation
func start() -> Error: 
	started.emit()
	return await _start()
func _start() -> Error: return await tick()


func tick(start_tick_callable:Variant=null, tick_callable:Variant=null, finish_tick_callable:Variant=null) -> Error:
	starting_tick.emit()
	var err : Error 
	if tick_callable is Callable: err = await start_tick_callable.call()
	else: err = await _tick_started()
	check("starting tick", err)
	
	if tick_callable is Callable: err = await tick_callable.call()
	else: err = await _tick()
	check("during tick", err)
	
	if finish_tick_callable is Callable: err = await finish_tick_callable.call()
	else: err = await _finish_tick()
	check("finishing tick", err)
	finished_tick.emit()
	return err

func _tick_started() -> Error: return OK
func _tick() -> Error: return OK
func _finish_tick() -> Error: return OK
#endregion

#region Instance Debugging and Console
## [chat] will output named prints, with color, by force or by [debug].
func chat(text:String, clr:Variant=Text.COLORS.gray, force:bool=false, return_ok:bool=false) -> Variant:
	if not debug and not force: return
	
	if text.is_empty() or text == " ":
		pass
	elif text.begins_with("^&"):
		text = text.substr(2)
	else:
		if not persona.is_empty(): text = str(persona + " | " + text)
	
	if clr is int and clr == -1: pass
	else: text = Text.color(text, clr)
	
	if chat_mirror_callable is Callable:
		chat_mirror_callable.call(text)
	
	if allow_chat:
		print_rich(text)
	
	if return_ok: return OK
	return null

## [chatd] will force a [chat] during [deep_debug].
func chatd(text:String, clr:Variant=Text.COLORS.gray, return_ok:bool=false) -> Variant: return chat(text, clr, deep_debug, return_ok)

## [warn] can be called with just text to [chat] a red message. [br] [br]
## If [warn] is called with an Error code passed as a second parameter, it will: [br]
## - Not print anything if err == OK [br]
## - Append the string converstion of the Error code to the end of the text using [error_string]. [br] [br]
## By default, the text "Error " is added to the beginning of the text message, if [is_error], otherwise, the text will be yellow.
## The editor debuggger can be given a breakpoint pause from the warn message using [can_break].
func warn(text: String = "WARNING", err: Error = ERR_PRINTER_ON_FIRE, is_error:bool=true, can_break:bool=false) -> void:
	var force: bool = err != OK; if force and err != ERR_PRINTER_ON_FIRE: text = str(text + ": " + error_string(err))
	var color = Text.COLORS.orange; if is_error and err == ERR_PRINTER_ON_FIRE: color = Text.COLORS.red
	
	if err == ERR_PRINTER_ON_FIRE: err = OK
	if err == OK and not force: is_error = false
	
	if is_error: text = str("Error " + text)
	else: 
		color = Text.COLORS.yellow
		force = debug
	if force: 
		if can_break:
			if is_error:
				push_error(str(name + " | ERROR | " + text))
			elif err != OK:
				push_warning(str(name + " | WARNING | " + text))
		else:
			chat(text, color, force)
	if is_error and can_break: breakpoint

## [warnd] will do a warning only during [deep_debug].
func warnd(text: String = "WARNING", err: Error = ERR_PRINTER_ON_FIRE, is_error:bool=true, can_break:bool=false) -> void: if deep_debug: warn(text, err, is_error, can_break)

func check(text: String = "function_name", err: Error = OK) -> void: warn(text, err, true, true)

func checkd(text: String = "function_name", err: Error = OK) -> void: if deep_debug: warn(text, err, true, true)

#endregion
