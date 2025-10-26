#|*******************************************************************
# ref_data.gd
#*******************************************************************
# This file is part of g_libs.
# 
# g_libs is an open-source software library.
# g_libs is licensed under the MIT license.
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

extends RefInstance
## RefData is a wrapper class for a Dictionary on top of [RefInstance].  
##   
## The [RefData] class is essentially the [Database] class at this time, or rather the foundation of it, and it may possibly get moved to that namespace in the future.
## A Database is a collection of data which is sorted by keys and/or other methods, and can be managed and searched and indexed.
class_name RefData

## A [member SEARCH] type is used to determine the length of data searching recursion. [br] [br]
## A [member SEARCH.SINGLE] will only check the top-level dictionary for the requested key or value. [br]
## A [member SEARCH.NESTED] will only check the top-level dictionary, and second-level dictionaries within a dictionary, for the requested key or value, and will recurse deeper as long as the key/value has been continuously found. [br]
## A [member SEARCH.DEEP] will check every dictionary for the requested key or value, recursively, until the deepest nested related value related to the searched key or value is found. [br]
enum SEARCH {SINGLE, NESTED, DEEP}


#region Data
## The [member data] is the active dictionary for this instance.
## [br]
## May contain any kind of element keyed with any kind of variant.
## [br][br][br]
## If using this [Database] for a [Registry], read below:[br]
## May contain [Registry], [RegistryEntry], [RegistryEntryGroup], or other data values, keying a value by it's file name without extension is recommended.[br]
## [i](See [method File.get_file_name_from_file_path] and [method File.remove_extension_from_file_path])[/i]
var data:Dictionary = {}

## The [member data_mutex] is used to lock and unlock around accessing the [member data], in order to maintain thread-safety during multi-threaded operations.
var data_mutex: Mutex = Mutex.new()

## The [method keys] will return the key values from the [member data]. [br][br]
## The [param same_keys] argument can be given a true to return the same array from the [method Dictionary.keys] instead of calling [method Array.duplicate] on that resulting array. [br][br]
## The [method keys] is a namespace function that simply calls the [method _keys] function.
func keys(same_keys:bool=false) -> Array: return _keys(same_keys)
## The [method _keys] is called via the [method keys]. [br][br]
## The [method _keys] will return the key values from the [member data]. [br][br]
## The [param same_keys] argument can be given a true to return the same array from the [method Dictionary.keys] instead of calling [method Array.duplicate] on that resulting array. [br][br]
## The [member data_mutex] is locked and unlocked prior to and after accessing the [member data], for thread safety.
func _keys(same_keys:bool=false) -> Array: 
	data_mutex.lock()
	var ks:Array = []
	if same_keys: ks = data.keys()
	else: ks = data.keys().duplicate()
	data_mutex.unlock()
	return ks

## The [method _clear] will call the [method Dictionary.clear] method upon [member data]. [br][br]
## The [method clear] is a namespace function for the [method _clear] function.
func clear() -> void: return _clear()
## The [method _clear] is called via the [method clear]. [br][br]
## The [method _clear] will call the [method Dictionary.clear] method upon [member data]. [br][br]
## The [member data_mutex] is locked and unlocked prior to and after accessing the [member data], for thread safety.
func _clear() -> void: 
	data_mutex.lock()
	data.clear()
	data_mutex.unlock()

## The [method _data_size] will call the [method Dictionary.size] method upon [member data]. [br][br]
## The [method data_size] is a namespace function for the [method _data_size] function.
func data_size() -> int: return _data_size()
## The [method _data_size] is called via the [method data_size]. [br][br]
## The [method _data_size] will call the [method Dictionary.size] method upon [member data]. [br][br]
## The [member data_mutex] is locked and unlocked prior to and after accessing the [member data], for thread safety.
func _data_size() -> int: 
	data_mutex.lock()
	var s:int = data.size()
	data_mutex.unlock()
	return s

## The [method _is_empty] will call the [method Dictionary.is_empty] method upon [member data]. [br][br]
## The [method is_empty] is a namespace function for the [method _is_empty] function.
func is_empty() -> bool: return _is_empty()
## The [method _is_empty] is called via the [method is_empty]. [br][br]
## The [method _is_empty] will call the [method Dictionary.is_empty] method upon [member data]. [br][br]
## The [member data_mutex] is locked and unlocked prior to and after accessing the [member data], for thread safety.
func _is_empty() -> bool: 
	data_mutex.lock()
	var e:bool = data.is_empty()
	data_mutex.unlock()
	return e

## The [method _has] uses the in keyword as an operator upon the [member data].
## The [method has] is a namespace function for the [method _has] function, which passes the [param key_entry] argument.
func has(key_entry:Variant) -> bool: return _has(key_entry)
## The [method _has] is called by [method has], and receives its argument from that function.[br][br]
func _has(key_entry:Variant) -> bool: 
	# TODO implement data_mutex locking somehow whilst still using grab(key_entry) to determine 0 or null value
	# TODO implement checking for null value alongside checking for zero to return a false has()
	var does:bool = key_entry in data
	if does:
		var v: Variant = grab(key_entry)
		if v is int and v == 0: return false
	return does

## The [method add] is essentially a [method Dictionary.set] function, with verbosity and the ability to force. [br][br]
## If one wants to change/override the [method add], they should instead override the [method _add], as this method [method add] is only a namespace for [method _add], which passes the [param value], [param at_key], [param force], and [param verbose] arguments.
func add(value:Variant, at_key:Variant=null, force:bool=false, verbose:bool=false) -> bool: return _add(value, at_key, force, verbose)
## The [method _add] is called by [method add], and receives its arguments from that function.[br][br]
## If the [method _add] is only given a [param value] argument, and no other arguments, and the [param value] is of classtype [RefInstance], the method will attempt to use a [member RefInstance.key] instead of the [param at_key]. [br][br]
## The method will try to use an internal [RefInstance] if the [param value] classtype is of [Object] and it does [method Object.has_method] have a function named "get_database". [br][br]
## The parameter [param verbose] is enabled by default, which produces [method chat]s related to the [method _add], but becomes disabled if the instance is not in [member deep_debug] or [member deep_debug all]. [br][br]
## If the resulting [param at_key] or [member RefInstance.key] already exists, and the [param force] is not true, the [param value] will not be added. [br][br]
## If the [param value] is a [RefInstance] or is an [Object] that contains a [member Database.db] property, the [member RefInstance.parent_instance] property of such will be set to the instance that performed the [method _add].
## [br][br]
## The [member data_mutex] is locked and unlocked prior to and after accessing the [member data], for thread safety.
func _add(value:Variant, at_key:Variant=null, force:bool=false, verbose:bool=true) -> bool:
	var is_ref: bool = value is RefInstance
	var is_node_ref: bool = !is_ref and value is Object and value.has_method("get_database")
	
	## TODO CHECK why is verbose and at_key in same condition?
	if verbose or at_key == null:
		
		if is_ref: if not at_key: at_key = value.key
		if is_node_ref: if not at_key: at_key = value
		if at_key == null: warn(str("can't add null-keyed value: " + str(value))); return false
		
		if verbose and not deep_debug: verbose = false
		if verbose: 
			if is_ref or is_node_ref: 
				var obj_name:String = Info.get_script_name(value)
				chatd(str("adding " + obj_name + "(" + str(value.name) + ") at key " + str(at_key) + "..."))
			else: chatd(str("adding variant at key " + str(at_key)))
		
		if not force and has(at_key) : 
			warnd(str("data already has key! can't add " + str(at_key))); 
			return false
	
	data_mutex.lock()
	#data[at_key] = value
	data.set(at_key, value)
	#data.get_or_add(at_key, value)
	data_mutex.unlock()
	
	if is_ref:
		if not value.parent_instance: value.parent_instance = self
	if is_node_ref:
		if not value.db.parent_instance: value.db.parent_instance = self
	
	if verbose: chatd(str("added " + str(at_key) + "."))
	return true

## The [method erase] can be given a [Variant] [param at_key] to find and remove from [member data].[br][br]
## If one wants to change/override [method erase], they should instead override [method _erase], as [method erase] is only a namespace for [method _erase] which passes the [param at_key] [Variant].
func erase(at_key:Variant) -> bool: return _erase(at_key)
## The [method _erase] is called by [method erase], and it simply passes the [Variant] [param at_key] to the [method Dictionary.erase] method upon the [member data] [Dictionary].
## [br][br]
## The [member data_mutex] is locked and unlocked prior to and after accessing the [member data], for thread safety.
func _erase(at_key:Variant) -> bool: 
	data_mutex.lock()
	var erased: bool = data.erase(at_key)
	data_mutex.unlock()
	return erased

## @experimental
func erase_value(value:Variant, at_key:Variant=null) -> bool: return _erase_value(value, at_key)
## @experimental
func _erase_value(value:Variant, at_key:Variant=null) -> bool:
	# TODO implement mutex locking!
	if not value and not at_key: return true
	
	if not at_key and value is Object:
		if value is RefData: at_key = value.key
		elif value is Node and value.has_method("get_database"): at_key = value.db.key
	
	if has(at_key): 
		var v: Variant = data.get(at_key)
		if value == v: 
			return erase(at_key)
	
	var values: Array = data.values()
	if values.has(value):
		var idx: int = values.find(value)
		var ks: Array = data.keys()
		if idx >= ks.size(): return false
		var k = ks[idx]
		return erase(k)
	
	return false

## The [method deep_search] is a recursive search function upon the [member data].[br][br]
## The [method deep_search] will search every nested RefData to find the deepest nested key value searched for.
func deep_search(at_key:Variant) -> Variant:
	# TODO implement mutex locking!
	for k in data:
		var v = data[k]
		
		if v is Object:
			if v is Node and v.has_method("get_database"): v = v.db
			if v is RefData and v.data_size() > 0:
				var r = v.deep_search(at_key)
				if r: return r
		
		if k == at_key: return v
	return null

## The [method find_data] method is able to be used as a [method Dictionary.get] function upon [member data] if given the [member SEARCH.SINGLE], for the [param search] argument.[br][br]
## The [member SEARCH.NESTED] functionality needs to be improved, as it only searches a double-layer deep at this time.[br][br]
## The [member SEARCH.DEEP] as an argument for [param search] will return a [method deep_search], instead of continuing the [method find_data].
func find_data(at_key:Variant, search:SEARCH=SEARCH.DEEP) -> Variant:
	# TODO implement mutex locking!
	if search == SEARCH.DEEP:
		return deep_search(at_key)
	
	if data.has(at_key): 
		var value = data.get(at_key)
		# TODO improve nested as it should continuously search for nested keys until it finds the deepest in consequtive keying, not just one folder.
		if search == SEARCH.NESTED and value is Object:
			var v : RefData
			if value is RefData: v = value
			elif value is Node and value.has_method("get_database"): v = value.db
			
			if v and v is RefData and v.data_size() > 0:
				var r: Variant = v.find_data(at_key, search)
				if r != null: return r
		return value
	return null

## The [method grab] is essentially a [method Dictionary.get] call via the method [method find_data] and the [method find_data] is called with a [member SEARCH.SINGLE] argument. [br][br]
## If an extended class needs to modify/override the [method grab], the method [method _grab] should be overridden instead, as [method grab] is only a namespace for [method _grab] which passes the [param at_key] argument.
func grab(at_key:Variant) -> Variant: return _grab(at_key)
## The [method _grab] method is called by the [method grab] method, it simply calls the [method find_data] method with [member SEARCH.SINGLE] by default.
func _grab(at_key:Variant) -> Variant: return find_data(at_key, SEARCH.SINGLE)
# TODO implement mutex locking!

## The [method tick] method is an override of the [method RefInstance.tick] method, which is the same as the [method RefInstance.tick] method, but this override adds ticking of elements inside the [member data] if [param tick_elements] is true. [br][br]
## See the method [method RefInstance.tick] for more information about how the [method tick] operates and is used. [br][br]
## If [param tick_elements] is true, every element (value, not key) within [member data] that is of or extended from [RefInstance] will also have their [method tick] method called via an await keyword and arguments may or may not be passed to them via [method callv]. [br][br]
## If [param tick_elements] and [param tick_elements_recursive] are true, every element in [member data] that has [method tick] called will also pass in a true for that function's [param tick_elements] and [param tick_elements_recursive], if the element is or is extending from [RefData]. [br][br]
## If [param tick_elements] and [param recurse_callables] are true, every element in [member data] that has [method tick] called will also pass in this method's [param start_tick_callable] & [param tick_callable] & [param finish_tick_callable] parameters as arguments for each element's [method tick] function via the [method callv].
func tick(start_tick_callable:Variant=null, tick_callable:Variant=null, finish_tick_callable:Variant=null, tick_elements:bool=false, tick_elements_recursive:bool=false, recurse_callables:bool=false) -> Error:
	starting_tick.emit()
	var err : Error 
	if tick_callable is Callable: err = await start_tick_callable.call()
	else: err = await _tick_started()
	check("starting tick", err)
	
	if tick_elements:
		# TODO improve mutex locking layout
		data_mutex.lock()
		for k in data:
			var element = data[k]
			if element is RefInstance:
				var subtick:bool = false; if tick_elements_recursive: subtick = true
				var args : Array = []; if recurse_callables: args = [start_tick_callable, tick_callable, finish_tick_callable]
				if element is RefData:
					if args.is_empty(): args = [null, null, null]
					args.append(subtick)
					args.append(subtick)
				err = await element.tick.callv(args)
				if err != OK: return err
		data_mutex.unlock()
	
	if tick_callable is Callable: err = await tick_callable.call()
	else: err = await _tick()
	check("during tick", err)
	
	if finish_tick_callable is Callable: err = await finish_tick_callable.call()
	else: err = await _finish_tick()
	check("finishing tick", err)
	finished_tick.emit()
	return err

# TODO remove the redundant await warning as the same issue in RefInstance.tick() 
