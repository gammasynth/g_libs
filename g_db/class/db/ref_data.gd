#|*******************************************************************
# ref_data.gd
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

extends RefInstance

## RefData is a wrapper for a Dictionary on top of RefInstance.
class_name RefData

enum SEARCH {SINGLE, NESTED, DEEP}


#region Data
## data is the active dictionary for this instance.
## [br]
## May contain any kind of element keyed with any kind of variant.
## [br][br]
## If using this Database for a Registry, read below:
## May contain [Registry], [RegistryEntry], [RegistryEntryGroup], or other data values, keying a value by it's file name without extension is recommended.
## [i](See [File.get_file_name_from_file_path] and [File.remove_extension_from_file_path])[/i]
var data:Dictionary = {}

var data_mutex: Mutex = Mutex.new()


func keys() -> Array: return _keys()
func _keys() -> Array: return data.keys()

func clear() -> void: return _clear()
func _clear() -> void: 
	data_mutex.lock()
	data.clear()
	data_mutex.unlock()

func data_size() -> int: return _data_size()
func _data_size() -> int: return data.size()

func is_empty() -> bool: return _is_empty()
func _is_empty() -> bool: return data.is_empty()

func has(key_entry:Variant) -> bool: return _has(key_entry)
func _has(key_entry:Variant) -> bool: 
	var does:bool = key_entry in data
	if does:
		var v: Variant = grab(key_entry)
		if v is int and v == 0: return false
	return does


func add(value:Variant, at_key:Variant=null, force:bool=false, verbose:bool=false) -> bool: return _add(value, at_key, force, verbose)
func _add(value:Variant, at_key:Variant=null, force:bool=false, verbose:bool=true) -> bool:
	var is_ref: bool = value is RefInstance
	var is_node_ref: bool = !is_ref and value is Object and value.has_method("get_database")
	
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
	data[at_key] = value
	#data.get_or_add(at_key, value)
	data_mutex.unlock()
	
	if is_ref:
		if not value.parent_instance: value.parent_instance = self
	if is_node_ref:
		if not value.db.parent_instance: value.db.parent_instance = self
	
	if verbose: chatd(str("added " + str(at_key) + "."))
	return true


func erase(at_key:Variant) -> bool: return _erase(at_key)
func _erase(at_key:Variant) -> bool: 
	data_mutex.lock()
	var erased: bool = data.erase(at_key)
	data_mutex.unlock()
	return erased

func erase_value(value:Variant, at_key:Variant=null) -> bool: return _erase_value(value, at_key)
func _erase_value(value:Variant, at_key:Variant=null) -> bool:
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


func deep_search(at_key:Variant) -> Variant:
	for k in data:
		var v = data[k]
		
		if v is Object:
			if v is Node and v.has_method("get_database"): v = v.db
			if v is RefData and v.data_size() > 0:
				var r = v.deep_search(at_key)
				if r: return r
		
		if k == at_key: return v
	return null

func find_data(at_key:Variant, search:SEARCH=SEARCH.DEEP) -> Variant:
	if search == SEARCH.DEEP:
		return deep_search(at_key)
	
	if data.has(at_key): 
		var value = data.get(at_key)
		if search == SEARCH.NESTED and value is Object:
			var v : RefData
			if value is RefData: v = value
			elif value is Node and value.has_method("get_database"): v = value.db
			
			if v and v is RefData and v.data_size() > 0:
				var r: Variant = v.find_data(at_key, search)
				if r != null: return r
		return value
	return null


func grab(at_key:Variant) -> Variant: return _grab(at_key)
func _grab(at_key:Variant) -> Variant: return find_data(at_key, SEARCH.SINGLE)






func tick(start_tick_callable:Variant=null, tick_callable:Variant=null, finish_tick_callable:Variant=null, tick_elements:bool=false, tick_elements_recursive:bool=false) -> Error:
	starting_tick.emit()
	var err : Error 
	if tick_callable is Callable: err = await start_tick_callable.call()
	else: err = await _tick_started()
	check("starting tick", err)
	
	if tick_elements:
		for k in data:
			var element = data[k]
			if element is Database:
				var subtick:bool = false; if tick_elements_recursive: subtick = true
				err = await element.tick(tick_callable, finish_tick_callable, subtick)
				if err != OK: return err
	
	if tick_callable is Callable: err = await tick_callable.call()
	else: err = await _tick()
	check("during tick", err)
	
	if finish_tick_callable is Callable: err = await finish_tick_callable.call()
	else: err = await _finish_tick()
	check("finishing tick", err)
	finished_tick.emit()
	return err
