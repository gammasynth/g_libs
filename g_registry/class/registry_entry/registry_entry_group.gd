#|*******************************************************************
# registry_entry_group.gd
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



extends Database

class_name RegistryEntryGroup


var uses_groups:bool = false

func _init(_group_name:String="group", _uses_groups:bool=false) -> void:
	super(_group_name)
	uses_groups = _uses_groups
	


static func is_subfolder_a_new_group(subfolder_path:String, registry_data:Dictionary={}) -> bool:
	if File.is_file(subfolder_path): return false
	var folder = File.get_folder(subfolder_path)
	var group = await find_group(folder, registry_data)
	if not group: group = await find_group(folder, registry_data, true)
	
	if group: 
		if deep_debug_all: 
			print_rich(Text.color(str(folder + " is existing group or entry"), Text.COLORS.yellow))
		return false
	
	if deep_debug_all: 
		print_rich(Text.color(folder, Text.COLORS.yellow))
	var files = File.get_all_filepaths_from_directory(subfolder_path, "", true)
	for file in files:
		var file_name = File.get_file_name_from_file_path(file)
		if deep_debug_all: 
			print_rich(Text.color(file_name, Text.COLORS.yellow))
		if file_name == folder:
			return false
		if file_name.ends_with("_data.gd") or file_name.ends_with("_data"):
			return false
	#var folders = File.get_all_directories_from_directory(subfolder_path)
	#if folders.is_empty(): return false
	if deep_debug_all: 
		print_rich(Text.color(str(folder + " is new group"), Text.COLORS.yellow))
	return true


static func get_group_from_element_filepath(registry_data:Dictionary, file_path:String, group_folder_paths:Dictionary, directories_to_load:Array[String]) -> RegistryEntryGroup:
	if deep_debug_all: 
		print_rich("RegistryEntryGroup: [color=yellow]" + "doing something probably intensive..." + "[/color]")
	var relevant_groups:Array[String] = []
	for _group_name in group_folder_paths:
		var group_path = group_folder_paths[_group_name]
		var group_local_path = group_path
		for dir in directories_to_load:
			if group_path.contains(dir):
				group_local_path = group_path.substr(dir.length() - 1); 
				break
		#print(file_path)
		#print(group_local_path)
		if file_path.contains(group_local_path):
			#print("match")
			relevant_groups.append(group_path)
	
	var longest_path_length = 0
	var longest_path = null
	for group_path in relevant_groups:
		var length = group_path.length()
		if length > longest_path_length:
			longest_path_length = length
			longest_path = group_path
	
	if longest_path:
		#print("GROUP PATH: " + longest_path)
		var _group_name = File.get_folder(longest_path)
		#print(group_name)
		if registry_data.has(_group_name): 
			return registry_data[_group_name]
		return await find_group(_group_name, registry_data)
	
	# we do not know the group name
	# check if there are other paths we can compare to ?
	print_rich("[color=red]" + "FATAL : No RegistryEntryGroup!" + "[/color]")
	print_rich("[color=red]" + "THIS IS BAD" + "[/color]")
	return null



static func find_group(_group_name:String, database:Variant=null, is_entry:bool=false) -> Variant:
	if database is not Dictionary:
		if Registry.instance != null:
			if not Registry.instance.data.is_empty():
				database = Registry.instance.data
	if database.is_empty(): return null
	for k in database:
		var v = database[k]
		if v is RegistryEntryGroup:
			if k == _group_name and not is_entry: return v;
			var g = await find_group(_group_name, v.data, is_entry)
			if g: return g;
		if v is Registry:
			var g = await find_group(_group_name, v.data, is_entry)
			if g: return g;
		if v is RegistryEntry or v is int and v == 1:
			if is_entry and k == _group_name: return v
	return null
