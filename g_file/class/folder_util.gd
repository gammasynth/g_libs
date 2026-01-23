#|*******************************************************************
# folder_util.gd
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



class_name FolderUtil


#region File Related String Methods

static func check_valid_directory(folder_path:String) -> bool:
	var dir = DirAccess.open(folder_path)
	if dir: return true
	return false

static func has_files(folder_path:String) -> bool:
	var files = get_all_filepaths_from_directory(folder_path)
	return not files.is_empty()

## Get a FolderName from a Path.
static func get_folder(path:String, full_path:bool=false) -> String:
	#if FileAccess.file_exists(path):# we wont use this because what if its a file path but not a currently existing file
	if not path.get_extension().is_empty():# we will consider a path with a ".extension" of any kind to be a "file"
		var file_name = FileUtil.get_file_name_from_file_path(path, true)
		path = path.left(path.length() - file_name.length())
	var folder_name:String = path; 
	if not full_path:
		folder_name = FileUtil.ends_with_slash(folder_name, false);
		folder_name = FileUtil.begins_with_slash(folder_name, false)# this will not only remove the slash before the folder name, but also the path.
	return folder_name

#region Directory Elements Methods
## Scan a Directory for Directories, return an Array[String] each Directory's path (or full_path)
static func get_all_directories_from_directory(folder_path:String, full_path:bool=false, recursive:bool=false, blacklist_folder_names:Array=[]) -> Array[String]:
	var filepaths: Array[String] = []
	
	folder_path = FileUtil.ends_with_slash(folder_path)
	
	var dir = DirAccess.open(folder_path)
	if not dir: return [];
	# Use DirAccess to list through the Directory's contents as FileName Strings
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var last_fn:String = file_name
	var idx:int = 0
	while file_name != "" and idx < 3:
		if blacklist_folder_names.has(file_name): 
			file_name = dir.get_next();
			continue
		if dir.current_is_dir():
			# if current Directory in list is valid and not a File, collect Directory path for list
			var fp: String = FileUtil.ends_with_slash(str(folder_path + file_name))
			if full_path: file_name = fp
			
			filepaths.append(file_name); 
			
			if recursive: filepaths.append_array(get_all_directories_from_directory(fp, full_path, recursive))
			
		last_fn = file_name
		file_name = dir.get_next();
		if last_fn == file_name: idx += 1
		else: idx = 0
	# Return the Array list of Directory Path Strings
	return filepaths



## Scan a Directory for files, return an Array of each file's path (or full_path)
## A whitelist can be used to only collect files of certain extensions
static func get_all_filepaths_from_directory(file_path:String, whitelist_extension:String="", full_path:bool=false, blacklist_file_names:Array=[]) -> Array:
	var filepaths: Array[String] = []
	var dir = DirAccess.open(file_path); if not dir: return [];
	# Use DirAccess to list through the Directory's contents as FileName Strings
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if blacklist_file_names.has(file_name): 
			file_name = dir.get_next()
			continue
		if blacklist_file_names.has(FileUtil.get_file_name_from_file_path(file_name)): 
			file_name = dir.get_next()
			continue
		if not dir.current_is_dir(): 
			var allowed_file = true
			var fp:String = str(file_path + file_name)
			# ?????????????
			if blacklist_file_names.has(fp): 
				file_name = dir.get_next()
				continue
			var ext: String = file_name.get_extension()
			if blacklist_file_names.has(fp.substr(0, fp.find(ext))): 
				file_name = dir.get_next()
				continue
			if blacklist_file_names.has(file_name.substr(0, file_name.find(ext))): 
				file_name = dir.get_next()
				continue
			# if current File in list is valid and not a SubDirectory, collect filepath for list
			if not whitelist_extension.is_empty() and ext != whitelist_extension: allowed_file = false
			if allowed_file: 
				if full_path: filepaths.append(fp)
				else: filepaths.append(file_name)
		file_name = dir.get_next()
	# Return the Array list of FilePath Strings
	return filepaths

## Return all FilePaths within a Folder and within every Subfolder, Recursively.
## @experimental: useful?
static func search_for_file_paths_recursively(folder_path:String, as_dictionary:bool=false, extra_folder:bool=true, include_hidden:bool=false, blacklist_folder_names:Array=[], blacklist_file_names:Array=[]) -> Variant:#, is_absolute_path:bool=false) -> Dictionary:
	var this_directory_dict: Dictionary = {}
	var this_directory_folder_dict: Dictionary = {}
	var this_directory_file_dict: Dictionary = {}
	
	var all_file_paths: Array[String] = []
	var all_file_names: Array[String] = []
	
	var subfolder_full_paths: Array[String] = get_all_directories_from_directory(folder_path, true, false, blacklist_folder_names)
	var subfolder_paths: Array[String] = get_all_directories_from_directory(folder_path, false, false, blacklist_folder_names)
	
	for subfolder_path in subfolder_paths:
		if blacklist_folder_names.has(subfolder_path): continue
		var subfolder_allowed = true
		var subfolder_hidden = false
		if subfolder_path.find(".") != -1:
			subfolder_hidden = true# TODO having a period at beginning may deem hidden, but not period anywhere
		if include_hidden == false:
			if subfolder_hidden == true:
				subfolder_allowed = false
		if subfolder_allowed:
			var subfolder_directory
			var subfolder_full_path: String = str(subfolder_full_paths[subfolder_paths.find(subfolder_path)] + "/")
			subfolder_directory = search_for_file_paths_recursively(subfolder_full_path, as_dictionary, false, include_hidden, blacklist_folder_names, blacklist_file_names)
			if as_dictionary: this_directory_folder_dict[subfolder_full_path] = subfolder_directory
			else:
				all_file_paths.append_array(subfolder_directory)
				all_file_names.append_array(FileUtil.get_file_names_from_file_paths(subfolder_directory))
	
	
	all_file_paths.append_array(get_all_filepaths_from_directory(folder_path, "", true, blacklist_file_names))
	all_file_names.append_array(FileUtil.get_file_names_from_file_paths(all_file_paths))
	
	for fp in all_file_paths:
		var fn: String = all_file_names[all_file_paths.find(fp)]
		this_directory_file_dict[fn] = fp
	
	this_directory_dict["FOLDERS"] = this_directory_folder_dict
	this_directory_dict["FILES"] = this_directory_file_dict
	if as_dictionary:
		if extra_folder:
			return {folder_path : this_directory_dict}
		else:
			return this_directory_dict
	else:
		return all_file_paths
