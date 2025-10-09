#|*******************************************************************
# ref_instance.gd
#*******************************************************************
# This file is part of g_libs. 
# g_libs is an open-source software codebase.
# g_libs is licensed under the MIT license.
#*******************************************************************
# Copyright (c) 2025 AD - present; 1447 AH - present, Gammasynth.  
# Gammasynth (Gammasynth Software), Texas, U.S.A.
# 
# This software is licensed under the MIT license.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
#|*******************************************************************

extends RefCounted

## RefInstance is a debuggable, nameable, keyable, and operatable RefCounted Object, with the ability to [method chat]/[method RefInstance.warn]/[method RefInstance.check] and [method RefInstance.start] and [method RefInstance.tick].
##
## RefInstance can keep a reference to a [parent_instance] that owns this instance, if there is one.[br]
## [br]
## The [method RefInstance.chat] method can be used to print messages by force or only if [member RefInstance.debug] is true, the [method RefInstance.warn] and [method RefInstance.check] methods are useful for error debugging and catching.
## [br]
## Functional processes can be inserted in overridden tick operation functions, by overriding any of the operation methods ( [method RefInstance._start], [method RefInstance._tick_started], [method RefInstance._tick], [method RefInstance._finish_tick] ) in an extended class, helping with organized operation order systems.
##[br]
## [RefInstance] is primarily intended to be a foundational base class for the [Database] class to be built upon, and the [RefCounted] class is faster to initialize and reccommend over this class in most cases.
class_name RefInstance

#region Instance Properties

## The first RefInstance instance to be initialized in a runtime will be declared the static origin_instance.
static var origin_instance: RefInstance = null
## The first RefInstance instance to be initialized will enable this for itself, and all other instances will have this disabled.
var is_origin_instance: bool = false

## The signal [signal RefInstance.started] is emitted when the method [method RefInstance.start] is called, prior to the execution of an overridden[method RefInstance._start] method.
signal started

## The signal [signal RefInstance.starting_tick] is emitted every time the method [method RefInstance.tick] is executed, by default, if the method [method RefInstance._start] is not overriden, the [method RefInstance.tick] method will be called upon executing the [method RefInstance.start] method.
signal starting_tick

## The signal [signal RefInstance.finished_tick] is emitted every time the method [method RefInstance.tick] is executed and about to finish execution, by default, and it emits after the [method RefInstance._finish_tick] method is executed and completed.
signal finished_tick


#region Debug
## The static member [member RefInstance.debug_all] is used as a global toggle for a state of debug, which takes precedence above whatever toggle state an instance's [member RefInstance.debug] may be.
static var debug_all: bool = false
## The static member [member RefInstance.deep_debug_all] is used as a global toggle for a state of deep_debug, which takes precedence above whatever toggle state an instance's [member RefInstance.deep_debug] may be.
static var deep_debug_all: bool = false

## The static member [member RefInstance.allow_chat] is used as a global enabler for the ability for [method RefInstance.chat] calls to actually print to the primary output and log, and does not affect [method RefInstance.chat] having the capacity to output/call to an assigned [member RefInstance.chat_mirror_callable].
static var allow_chat:bool = true
## The static member [member RefInstance.chat_mirror_callable] is not used by default and is null or empty, the type is Variant to allow the value to be null, but if a [Callable] is assigned, then every [method RefInstance.chat] call will call this callable and will pass the chat to this callable. [br]The overriding
static var chat_mirror_callable:Variant = null

## The signal [signal RefInstance.debug_toggled] is emitted with the current new debug boolean state every time the member [member RefInstance.debug] is changed/toggled.
signal debug_toggled(b:bool)
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
	if origin_instance == null: 
		origin_instance = self
		is_origin_instance = true
	
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
	
	var empty:bool=false
	if text.is_empty() or text == " ":
		empty = true
	elif text.begins_with("^&"):
		text = text.substr(2)
	else:
		if not persona.is_empty(): text = str(persona + " | " + text)
	
	if not empty:
		if clr is int and clr == -1: pass
		else: text = Text.color(text, clr)
	
	if chat_mirror_callable is Callable:
		chat_mirror_callable.call(text)
	
	if allow_chat:
		print_rich(text)
	
	if return_ok: return OK
	return null

## [chatf] will force a [chat] without needing to send a true boolean.
func chatf(text:String, clr:Variant=-1) -> Variant: return chat(text, clr, true)

## [chatd] will force a [chat] during [deep_debug].
func chatd(text:String, clr:Variant=Text.COLORS.gray, return_ok:bool=false) -> Variant: 
	if deep_debug: return chat(text, clr, deep_debug, return_ok)
	else: return 

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
