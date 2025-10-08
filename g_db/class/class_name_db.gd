#|*******************************************************************
# class_name_db.gd
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

extends Database
## ???????????????????????????????????????????????????
class_name ClassNameDB

static var instance: ClassNameDB

static var classes: Dictionary = {}:
	get:
		if not instance: push_error("no instance on classes get!"); return {}
		return instance.data

static var replacement_class_database:Database
static var replacement_class_dictionary:Dictionary

static var fallback_class_database:Database
static var fallback_class_dictionary:Dictionary

static func _static_init() -> void:
	instance = ClassNameDB.new()


#static func get_class_script(class_string_name:String="", registry_name:String="", registry_entry_name:String="", deep_search:bool=false) -> GDScript:
	#if class_string_name.is_empty(): return null
	#if registry_name.is_empty(): deep_search = true
	#if not Registry.instance:
		#warnf("Can't make_instance because there is no Registry! Turn on enable_registry_system in your Core node, if using one.")
		#return null
	#var search: RefData.SEARCH = RefData.SEARCH.SINGLE; if deep_search: search = RefData.SEARCH.DEEP
	#var registry: Registry = Registry.instance; if registry_name: registry = Registry.get_registry(registry_name, deep_search)
	#if not registry:
		#if registry_name.length() > 0: registry_name = str(": " + registry_name)
		#else: registry_name = "!"
		#warnf(str("Can't find Registry" + registry_name))
		#return null
	#
	#var data_parent = registry
	#if not registry_entry_name.is_empty():
		#if registry.data.has(registry_entry_name):
			#data_parent = registry.data.get(registry_entry_name)
	#
	#var class_script: GDScript = data_parent.find_data(class_string_name, search)
	#if not class_script:
		#warnf(str("Can't find class_name: " + class_string_name + ", in Registry: " + registry.name))
		#return null
	##if deep_debug: chatf("loaded class: " + str(class_string_name), -1, true)
	#return class_script

#
#static func instantiate(class_string_name:String="", params:Array=[], registry_name:String="", registry_entry_name:String="", deep_search:bool=false) -> Object:
	#var class_script: GDScript = get_class_script(class_string_name, registry_name, registry_entry_name, deep_search)
	#return class_script.new.callv(params)

static func try_pull_class_script_from_data(class_string_name:String, from:Variant) -> GDScript:
	if not from: return null
	
	if from is Database:
		if from.has(class_string_name):
			var value: Variant = from.find_data(class_string_name); if value is GDScript: return value
			print(Text.color("ClassNameDB | " + class_string_name + " in " + from.name + " is not GDScript! type: " + type_string(typeof(value)), Text.COLORS.yellow))
			value = from.grab(class_string_name); if value is GDScript: return value
			print(Text.color("ClassNameDB | " + class_string_name + " in " + from.name + " is still not GDScript! type: " + type_string(typeof(value)), Text.COLORS.red)); return null
		
	
	if from is Dictionary:
		if from.has(class_string_name):
			var value = from.get(class_string_name); if value is GDScript: return value
			print(Text.color("ClassNameDB | " + class_string_name + " in " + str(from) + " is not GDScript! type: " + type_string(typeof(value)), Text.COLORS.red)); return null
	
	return null


static func try_instantiate(class_string_name:String="", params:Array=[]) -> Object:
	
	var class_script: GDScript = null
	
	if not class_script: class_script = try_pull_class_script_from_data(class_string_name, replacement_class_database)
	if not class_script: class_script = try_pull_class_script_from_data(class_string_name, replacement_class_dictionary)
	
	if not class_script: class_script = try_pull_class_script_from_data(class_string_name, instance)
	
	if not class_script: class_script = try_pull_class_script_from_data(class_string_name, fallback_class_database)
	if not class_script: class_script = try_pull_class_script_from_data(class_string_name, fallback_class_dictionary)
	
	if class_script:
		
		var obj: Object
		if params.size() > 0:
			obj = class_script.new.callv(params)
		else:
			obj = class_script.new()
		
		return obj
		
	else:
		
		if ClassDB.can_instantiate(class_string_name):
			var obj: Object = ClassDB.instantiate(class_string_name)
			
			if params.size() > 0:
				var script: GDScript = obj.get_script()
				if script:
					obj = script.new.callv(params)
			
			return obj
	
	return null
