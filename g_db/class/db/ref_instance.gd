#|*******************************************************************
# ref_instance.gd
#*******************************************************************
# This file is part of g_libs.
# 
# g_libs is an open-source software library.
# g_libs is licensed under the MIT license.
# 
# https://github.com/gammasynth/g_libs
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

## [RefInstance] is a debuggable, nameable, keyable, and operatable [RefCounted] Object, with the ability to [method chat]/[method warn]/[method check] for logging/text-output, and [method start] and [method tick] for ordered operations.
##
## [RefInstance] can keep a reference to a [member parent_instance] that owns this instance, if there is one. Ownership of an instance can be an arbitrary scheme by the developer using the [RefInstance], or it will be used to reference a parent [Database] in the case that the instance is within a [Database]'s [member Database.data].[br]
## [br] [br]
## The [method chat] method can be used to print messages by force, or only if [member debug] is true, the [method warn] and [method check] methods are useful for error debugging and catching, and can be used as conditional breakpoints.
## [br] [br]
## Functional processes can be inserted in overridden tick operation functions, by overriding any of the operation methods ([method _start], [method _tick_started], [method _tick], [method _finish_tick]) in an extended class, helping with organized operation order systems.
## [br] [br]
## [RefInstance] is primarily intended to be a foundational base class for the [Database] class to be built upon, and the [RefCounted] class is faster to initialize and is reccommend over this class in most cases.
class_name RefInstance

#region Instance Properties

## The first [RefInstance] instance to be initialized in a runtime will be declared the static [member origin_instance].
static var origin_instance: RefInstance = null
## The first [RefInstance] instance to be initialized in a runtime becomes the [member origin_instance] and will enable this boolean for itself, and all other instances will have this boolean disabled.
var is_origin_instance: bool = false
## After the [method _do_init] runs, [member is_initialized] will be set to true after [method _initialized] has been called. [br]
## During the [method _do_init] method, if [member is_initialized] is already true, [method _initialized] will not be called. [br]
var is_initialized: bool = false

## The signal [signal started] is emitted when the method [method start] is called, it is emitted prior to the execution of an overridden [method _start] method.
signal started

## The signal [signal starting_tick] is emitted every time the method [method tick] is executed, before the rest of the method. By default, if the method [method _start] is not overriden, the [method tick] method will be called upon executing the [method start] method.
signal starting_tick

## The signal [signal finished_tick] is emitted every time the method [method tick] is executed and about to finish execution, and it emits after the [method _finish_tick] method has been executed and completed.
signal finished_tick


#region Debug
## The static member [member debug_all] is used as a global toggle for a state of debug, which takes precedence above whatever toggle state an instance's [member debug] may be at any time.
static var debug_all: bool = false
## The static member [member deep_debug_all] is used as a global toggle for a state of deep debug, which takes precedence above whatever toggle state an instance's [member deep_debug] may be at any time.
static var deep_debug_all: bool = false

## The static member [member allow_chat] is used as a global enabler/disabler for the ability for [method chat] calls to actually print to the primary output and log, and does not affect [method chat] having the capacity to output/call to an assigned [member chat_mirror_callable].
static var allow_chat:bool = true
## The static member [member chat_mirror_callable] is not used by default and is null or empty, the type is [Variant] to allow the value to be null, but if a [Callable] is assigned, then every [method chat] call will call this callable and will pass the chat to this callable.
static var chat_mirror_callable:Variant = null

## The signal [signal debug_toggled] is emitted with the current new debug boolean state every time the member [member debug] is changed/toggled.
signal debug_toggled(b:bool)
## The member [member debug] is used to toggle the current state of debug, for some systems it may be preferrable to initialize an application with debug enabled prior to runtime initialization, rather than enabling it during the runtime.
@export var debug:bool=false: get = get_debug, set = set_debug
## The getting of member [member debug] is overidden via method [method get_debug] to return [member debug] or [member debug_all] in the case where one or both may be true.
func get_debug() -> bool: return debug or debug_all;
## The setting of member [member debug] is overidden via method [method set_debug] so that [signal debug_toggled] can emit upon the change. If member [member debug] is changed on the [member origin_instance], then the change to its [member debug] is also applied to [member debug_all].
func set_debug(_debug:bool) -> void: debug_toggled.emit(_debug); debug = _debug; if origin_instance == self: debug_all = debug;

## The signal [signal deep_debug_toggled] is emitted with the current new deep debug boolean state every time the member [member deep_debug] is changed/toggled.
signal deep_debug_toggled(b:bool)
## The member [member deep_debug] is used to toggle the current state of deep debug, for some systems it may be preferrable to initialize an application with deep debug enabled prior to runtime initialization, rather than enabling it during the runtime.
@export var deep_debug:bool=false: get = get_deep_debug, set = set_deep_debug
## The getting of member [member deep_debug] is overidden via method [method get_deep_debug] to return [member deep_debug] or [member deep_debug_all] in the case where one or both may be true.
func get_deep_debug() -> bool: return deep_debug or deep_debug_all;
## The setting of member [member deep_debug] is overidden via method [method set_deep_debug] so that [signal deep_debug_toggled] can emit upon the change. If member [member deep_debug] is changed on the [member origin_instance], then the change to its [member deep_debug] is also applied to [member deep_debug_all].
func set_deep_debug(_deep_debug:bool) -> void: deep_debug_toggled.emit(_deep_debug); deep_debug = _deep_debug; if origin_instance == self: deep_debug_all = deep_debug
#endregion

#region Instance Name
## The signal [signal name_changed] is emitted any time that the member [member name] is set/changed.
signal name_changed(new_name: String, old_name: String)

## The member [member name] can be used as a [String] object identifier, whether generic per classtype or unique per instance.
var name : String = "OBJ": set = set_name
## The setting of member [member name] is overriden via method [method set_name], so that the signal [signal name_changed] can be emitted with both the new and the previous names.
func set_name(_name) -> void: var old = name; name = _name; name_changed.emit(_name, old)

## A [member persona] is not a [member name]. If an instance has a [member persona] assigned (it is an empty [String] by default), then the [method chat] will use the [member persona] to identify itself in its chats rather than using its [member name]. An empty [String] can be assigned to be used as a [member persona] as well.
var persona: String:
	get:
		if has_persona: return persona
		return name
	set(s):
		has_persona = true
		persona = s
## The member [member has_persona] is set to true whenever a [member persona] is applied, and this is the member that [method chat] uses to check for the use of a persona. The member [member has_persona] does not disable itself after being enabled on an instance, but it can be manually disabled after enabled.
var has_persona: bool = false
#endregion

#region Instance Key
## A [member key] is a [Variant] object identifier, and without changing the instance constructor behavior or manually assigning a [member key] value, the key will default to being the same as the [String] [member name] value.
@export var key: Variant = null: get = _get_key, set = _set_key
## The getting of member [member key] is overidden via the method [method _get_key], and simply returns the member [member key] by default. This method [method _get_key] can be overidden in an extended class to add additional behaviors.
func _get_key() -> Variant: return key
## The setting of member [member key] is overidden via the method [method _set_key], and simply sets the member [member key] by default and also attempts to apply the new [member key] to the member [member name] if the new key value is a [String] or if the new key value is able to be constructed into a [String]. This method [method _set_key] can be overidden in an extended class to add additional behaviors or to change or remove its existing behavior.
func _set_key(_key) -> void: key = _key; if _key is String or str(_key) is String and str(_key).length() > 0: name = str(_key)

## An instance of [RefInstance] can be assigned a [member parent_instance] value, but this value is typically used for a [Database] to reference another [Database] that it is inside of, via the [member Database.data].
var parent_instance: RefInstance: get = _get_parent_instance
## The getting of member [member parent_instance] is overidden via method [method _get_parent_instance], which by default simply returns the value of member [member parent_instance], this method can be overidden in an extended class to add additional behavior.
func _get_parent_instance() -> RefInstance: return parent_instance
#endregion

#endregion


## The [method _init] can be overridden in a new class that extends from [RefInstance], the new overidding function can change the function's parameters/argumentation, and it is reccommended to use the method super(_name, _key) to call this origin initializer function.
func _init(_name:String="OBJ", _key:Variant=_name) -> void: _do_init(_name, _key)

func _do_init(_name:String="OBJ", _key:Variant=_name) -> void:
	if origin_instance == null: 
		origin_instance = self
		is_origin_instance = true
	
	name = _name
	key = _key
	
	if not is_initialized: _initialized()
	is_initialized = true

func _initialized() -> void: return

#region Instance Tick Operation
## The [method start] can be used as an entry point for a class's intended operation whether one-pass or repeating functionality. [br]
## If one wants to insert functionality into the [method start] function, they should override the [method _start] method. [br]
## The signal [signal started] will fire prior to the calling and execution of the [method _start] method. [br]
## The method [method _start] is called via an await keyword in case of asynchronicity. [br]
## The [method start] returns the error that [method _start] returns, which by default is OK.
func start() -> Error: 
	started.emit()
	return await _start()
## The [method start] method is the intended origin method to be called for operation, and this method [method _start] is called by the [method start] method. [br]
## If a class extending from [RefInstance] does not override the [method _start], then by default, the [method _start] will only call the method [method tick]. [br]
## The [method _start] returns the Error code returned from [method tick] by default, and should return an Error code if overridden.
func _start() -> Error: return await tick()

## The [method tick] method is a trisected operation, one that is typically meant to be reoccurring or to loop at some arbitrary interval. [br] [br]
## Without overriding any of the following methods in an extended class ([method _tick_started], [method _tick], [method _finish_tick]) and also not passing in any [Callable]s for the following parameters ([param start_tick_callable], [param tick_callable], [param finish_tick_callable]), the method [method tick] will essentially do nothing except emit its [signal starting_tick] and [signal finished_tick] signals, and possibly [method chat].
## [br] 
## [br]
## The order of operation is that signal [signal starting_tick] is fired, then [method _tick_started] is called, then the method [method _tick] is called, then the method [method _finish_tick] is called, and the signal [signal finished_tick] is fired after the functionalities' execution has been finished, before the function returns.
## [br] [br]
## Each of these segmented methods ([method _tick_started], [method _tick], [method _finish_tick]) can be replaced individually via feeding in any of the parameters ([param start_tick_callable], [param tick_callable], [param finish_tick_callable]) [Callable]s as arguments. A fed [Callable] argument takes precedence over an overridden sub-tick method.
## [br] [br]
## Each of the three segmented functions/[Callable]s should return an Error as OK if the function is successful, and each of these Error codes will be passed to the method [method check] named according to their functional segment.
## [br] [br]
## Each functional segment is called via an await keyword, in case of asynchronicity. [br] 
## [br]
## An easy option for making a [method tick] method reoccurring or looping could be to, for example, override the [method _finish_tick] function or pass in a [Callable] function as an argument with code to trigger another call to the [method tick].
## [br] Example: [br]
## [codeblock]
## func _finish_tick() -> Error:
##     return tick()
## [/codeblock][br]
## The [method tick] returns an Error code, which will be from whatever last called interal overridden function and/or inserted [Callable] argument/parameter has returned, therefore any internal function should also return an Error code, and the [method tick] will stop upon catching a non-OK Error code with each [method check].
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
# TODO add something to remove "unneccessary await" warning in the tick function above.
## The [method _tick_started] method is called from the [method tick] function, at the beginning of it, but this function [method _tick_started] is called after [signal starting_tick] has been fired.
func _tick_started() -> Error: return OK
## The [method _tick] method is called from the [method tick] function, at the middle of it.
func _tick() -> Error: return OK
## The [method _tick_started] method is called from the [method tick] function, at the end of it, prior to the emission of the [signal finished_tick] signal.
func _finish_tick() -> Error: return OK
#endregion

#region Instance Debugging and Console
## The [method chat] method will output named prints, with color, by [param force] or by [member debug]. [br]
## If [member debug] and [member debug_all] and [param force] are all false, the [method chat] will do nothing except return immediately.
## [br] [br]
## The coloring of the text is handled via the [method Text.color] method, which receives the [param text] and [param clr] parameters as arguments.
## [br] [br]
## The [param clr] should be of type [member Text.COLORS], but can also be an [int] of value -1 to skip the action of coloring.
## [br] [br]
## The [String][member persona] is concatenated to the beginning of the [param text], except if [param text] [method String.is_empty] or the [param text] is one space character or if [param text] [method String.begins_with] the characters "^&".
## [br] [br]
## If [param text] [method String.is_empty] or the [param text] is one space character, the text will not be colored via [method Text.color], to reduce unnecessary script function calls.
## [br] [br]
## If a static [member chat_mirror_callable] has been assigned and the value is [Callable], every [method chat] will call [member chat_mirror_callable] and will pass the handled/named/colored [param text] to the function as an argument, regardless of whatever value [member allow_chat] has at a time.
## [br] [br]
## If [member allow_chat] is true, [method print_rich] will be called with the handled/named/colored [param text] passed as an argument, after [member chat_mirror_callable] has been checked/called. [br]
## The method [method print_rich] is used instead of [method print] to handle and serve the BBCode color formatting that may be inserted around [param text].
## [br] [br]
## If the parameter [param return_ok] is given a true as an argument, the [method chat] will return an [Error] OK instead of returning null.
func chat(text:String, clr:Variant=Text.COLORS.gray, force:bool=false, return_ok:bool=false) -> Variant:
	if not debug and not force: 
		if return_ok: return OK
		else: return null
	
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

## The [method chatf] method will force a [method chat] without needing to send a true boolean argument and without needing [member debug] or [member debug_all] enabled.
func chatf(text:String, clr:Variant=-1) -> Variant: return chat(text, clr, true)

## The [method chatd] method will force a [method chat] during [member deep_debug] or [member deep_debug_all] without needing to send a true boolean argument and without needing [member debug] or [member debug_all] enabled.
func chatd(text:String, clr:Variant=Text.COLORS.gray, return_ok:bool=false) -> Variant: 
	if deep_debug: return chat(text, clr, deep_debug, return_ok)
	else: return 

## The [method warn] method can be called with just text to force [method chat] a red message. [br] [br]
## The [method warn] is primarily used for error catching and possibly breakpointing during [method chat]s.
## [br] [br]
## If [method warn] is called with an Error code passed as a second parameter, it will: [br]
## - Not print anything if err == OK [br]
## - Append the string converstion of the Error code to the end of the text using [method error_string]. [br] [br]
## By default, the text "Error " is added to the beginning of the text message, if [param is_error], otherwise, the text will be yellow.[br] [br]
## The editor debuggger can be given a breakpoint pause from the warn message using [param can_break].[br] [br]
## If [param err] is ERR_PRINTER_ON_FIRE, the [method error_string] will not be appended to [param text], and the text will be red in color, else the color will be orange if [param is_error].[br] [br]
## The breakpoint functionality will only break if both [param is_error] and [param can_break] are both true, but [param is_error] will set itself false prior to the break if [param err] is OK or ERR_PRINTER_ON_FIRE.
## [br] [br]
## The [method chat] called from [method warn] will only be forced if [param err] is not OK or ERR_PRINTER_ON_FIRE, but if [param is_error] is false the forcing will default to whatever [member debug] or [member debug_all] is.
## [br] [br]
## If the [method warn] is attempting to force the [method chat] and [param can_break] is true, then instead of [method chat], the method [method push_error] will be used if [param is_error], or else the method [method push_warning] will be used if the [param err] is not OK or ERR_PRINTER_ON_FIRE.
## [br] [br]
## If one wants the actual keyword function breakpoint to be called when using [param can_break], ensure that [param is_error] is true and that the [param err] is a value other than Error OK or ERR_PRINTER_ON_FIRE.
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

## The [method warnd] method will perform a [method warn] only during [member deep_debug] or [member deep_debug_all].
func warnd(text: String = "WARNING", err: Error = ERR_PRINTER_ON_FIRE, is_error:bool=true, can_break:bool=false) -> void: if deep_debug: warn(text, err, is_error, can_break)

## The [method check] method is a [method warn] that is used specifically for non-OK Error code catching and breakpointing. [br][br]
## Simply send in a [String] [param text] and a non-OK and non-ERR_PRINTER_ON_FIRE Error code as an [param err] to have a [method warn] perform a forced [method chat] and also hit a breakpoint.
func check(text: String = "function_name", err: Error = OK) -> void: warn(text, err, true, true)

## The [method checkd] method is a [method check] that will only occur if [member deep_debug] or [member deep_debug_all].
func checkd(text: String = "function_name", err: Error = OK) -> void: if deep_debug: warn(text, err, true, true)
#endregion
