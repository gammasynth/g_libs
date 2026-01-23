#|*******************************************************************
# file_util.gd
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



class_name FileUtil


static func is_user_dir(path:String) -> bool:
	var is_user_path:bool = false; if path.begins_with("user"): is_user_path = true;
	return is_user_path


#region Slash Methods
## Make a FilePath begin with "/", if it needs to, or remove any path before and containing the first "/", if it has one.
static func begins_with_slash(file_path:String, does:bool=true, backslash:bool=false, any_slash:bool=true) -> String:
	var slash: String = "/"
	var slash2: String = "\\"
	var other_slash = slash2
	if backslash: 
		other_slash = slash
		slash = slash2
	if does: 
		if not file_path.begins_with(slash): file_path = str(slash + file_path);
	else: 
		var slash_index = file_path.rfind(slash)
		if slash_index != -1: file_path = file_path.substr(slash_index + 1)
		elif any_slash: 
			slash_index = file_path.rfind(other_slash)
			if slash_index != -1: file_path = file_path.substr(slash_index + 1)
	return file_path

## Make a FilePath end with a "/", if it needs to, or remove a "/" from the end of the FilePath.
static func ends_with_slash(file_path:String, does:bool=true, backslash:bool=false, any_slash:bool=true) -> String:
	var slash: String = "/"
	var slash2: String = "\\"
	var other_slash = slash2
	if backslash: 
		other_slash = slash
		slash = slash2
	if does:
		if not file_path.ends_with(slash): 
			file_path = str(file_path + slash);
	else: 
		if file_path.right(1) == slash: 
			file_path = file_path.substr(0, file_path.length() - 1)
		if any_slash and file_path.right(1) == other_slash:
			file_path = file_path.substr(0, file_path.length() - 1)
	return file_path

static func no_slashes(file_path:String) -> String: return begins_with_slash(ends_with_slash(file_path, false), false)
#endregion


#region FileExtension Methods
## Remove a FileExtension and it's period from a FilePath, if there is one.
static func remove_extension_from_file_path(file_path: String) -> String:
	var ext:int = file_path.get_extension().length()
	return file_path.substr(0, file_path.length() - (ext + (clamp(ext, 0, 1) * 1)))

## Remove FileExtensions and their periods from FilePaths, where there are ones.
static func remove_extensions_from_file_paths(file_paths: Array[String]) -> Array[String]:
	var new_file_paths: Array[String] = []
	for file_path in file_paths: var new_path = remove_extension_from_file_path(file_path); new_file_paths.append(new_path);
	return new_file_paths
#endregion

#region FileName Methods
## Get a FileName from a FilePath, and can optionally get with FileExtension ending.
static func get_file_name_from_file_path(file_path:String, with_extension:bool=false) -> String:
	if not with_extension: file_path = remove_extension_from_file_path(file_path);
	var file_name = file_path
	var base_dir = file_path.get_base_dir()
	if not base_dir.is_empty(): base_dir = ends_with_slash(base_dir); file_name = file_name.substr(base_dir.length());
	file_name = begins_with_slash(file_name, false)
	return file_name

## Get an Array[String] of FileNames from an Array[String] of FilePaths, and can optionally get with FileExtension endings.
static func get_file_names_from_file_paths(file_paths: Array[String], with_extension:bool=false) -> Array[String]:
	var file_names: Array[String] = []
	for file_path in file_paths: var file_name = get_file_name_from_file_path(file_path, with_extension); file_names.append(file_name);
	return file_names
#endregion



#endregion

#region Primary File Operation Methods
## Returns an opened FileAccess at FilePath, if there is one, or null. Will use encryption when fed a passkey.
static func get_file(file_path:String, passkey:String="", force:bool=false) -> FileAccess:
	if not force and not FileAccess.file_exists(file_path): print("FILE ERROR | " + "file nonexistent: " + file_path); return null;
	var file = null
	if not passkey.is_empty():
		file = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, passkey)
	else:
		file = FileAccess.open(file_path, FileAccess.READ)
	if not force and not file: print("FILE ERROR | " + "file open: " + file_path)
	if force and not file:
		file = FileAccess.open(file_path, FileAccess.WRITE_READ)
	return file
#endregion

#region File Validation

static func is_file(file_path:String) -> bool:
	return FileAccess.file_exists(file_path)

static func is_valid_file(file_path:String, passkey:String="") -> bool:
	var file = get_file(file_path, passkey); if file: return true;
	return false

static func is_import_info_file(file_path) -> bool:
	if file_path.ends_with(".import"): return true
	return false

static func is_valid_gd_script_file(file_path:String) -> bool:
	if file_path.ends_with(".gd"): return true
	if file_path.ends_with(".gdc"): return true
	return false

static func is_valid_godot_resource(file_path:String) -> bool:
	# this will only validate .tscn, .scn, .tres, and .res files, no other filetypes
	if file_path.ends_with(".tscn"): return true
	if file_path.ends_with(".tscn.remap"): return true
	
	if file_path.ends_with(".scn"): return true
	if file_path.ends_with(".tres"): return true
	if file_path.ends_with(".res"):return true
	
	if file_path.ends_with(".theme"):return true
	if file_path.ends_with(".stylebox"):return true
	
	if file_path.ends_with(".material"):return true
	
	if file_path.ends_with(".gdshader"):return true
	if file_path.ends_with(".gdshaderinc"):return true
	
	if file_path.ends_with(".ttf"):return true
	if file_path.ends_with(".otf"):return true
	return false

static func is_valid_image_resource(file_path:String) -> bool:
	# this will only validate .png resources, no other file type
	if file_path.ends_with(".png"): return true
	if file_path.ends_with(".svg"): return true
	if file_path.ends_with(".bmp"): return true
	if file_path.ends_with(".jpeg"): return true
	return false



static func is_valid_audio_resource(file_path:String) -> bool:
	# this will only validate .mp3 resources, no other file type
	if file_path.ends_with(".mp3"): return true
	return false

static func is_valid_image_or_audio_resource(file_path:String) -> bool:
	if is_valid_image_resource(file_path): return true
	if is_valid_audio_resource(file_path): return true
	return false

static func is_valid_resource(file_path:String) -> bool:
	if not is_valid_file(file_path): return false
	if not is_user_dir(file_path):
		if is_valid_image_resource(file_path): return true
		if is_valid_audio_resource(file_path): return true
		if is_valid_godot_resource(file_path): return true
		if is_valid_gd_script_file(file_path): return true
	return false
#endregion


#region Load and Save Text Files
## Find a text-based File from a FolderPath + FileName in the filesystem, and return it's contents as a String. Will use encryption when fed a passkey.
static func load_text_file_at_path_by_name(folder_path:String, file_name:String, passkey:String = "") -> String:
	folder_path = ends_with_slash(folder_path)
	if not FolderUtil.check_valid_directory(folder_path): return ""
	return load_text_file(str(folder_path + file_name), passkey)


## Find a text-based File from a FilePath in the filesystem, and return it's contents as a String.
static func load_text_file(file_path:String, passkey:String = "", dire:bool=false) -> String:
	file_path = str(file_path)
	if not FileAccess.file_exists(file_path): print(str("file nonexistent: " + file_path)); return ""
	var file = get_file(file_path, passkey)
	if file == null:
		if dire: assert(false, str("file load failed: " + error_string(FileAccess.get_open_error()) + " @" + file_path))
		return ""
	return file.get_as_text()


## Save text to a File at FolderPath + FileName, uses encryption if fed a passkey.
static func save_text_file_at_path_by_name(file_text:String, folder_path:String, file_name:String, passkey:String = "") -> Error:
	if not FolderUtil.check_valid_directory(folder_path): return ERR_FILE_BAD_PATH
	return save_text_file(file_text, str(folder_path + file_name), passkey)


#static func validate_folders_in_path(file_path:String) -> Error:
	#if file_path.begins_with("user://"):
		#var is_file_path:bool = true; if file_path.get_extension().is_empty() or file_path.ends_with("/")  or file_path.ends_with("\\"): is_file_path = false
		#var dir: DirAccess = DirAccess.open("user://")
		#var folder: String
		#
		#if not is_file_path: folder = file_path
		#else: folder = get_folder(file_path, true)
		#print(folder)
		#
		#if not dir.dir_exists(folder):
			#var next_folder:String = get_folder(folder, true)
			#var next_folder_slashless: String = ends_with_slash(next_folder, false)
			#print(next_folder)
			#print(next_folder_slashless)
			#print(" ")
			#if next_folder_slashless.containsn("/") or next_folder_slashless.containsn("\\"):
				#validate_folders_in_path(next_folder)
			#dir.make_dir(folder)
		#
	#else:
		##TODO
		## PLES IMPLEMENT OTHER DIR FILE SAVING
		#Cast.warn("file manager unimplemented save dir!", ERR_UNAVAILABLE, true, true)
		#return ERR_BUG
	#return OK

## Save text to a File at FilePath, uses encryption if fed a passkey.
static func save_text_file(file_text:String, file_path:String, passkey:String = "", dire:bool=false) -> Error:
	file_path = str(file_path)
	if dire: print(file_path)
	
	
	#validate_folders_in_path(file_path)
	
	#var file = get_file(file_path, passkey, true)
	var file: FileAccess
	if passkey.is_empty():
		file = FileAccess.open(file_path, FileAccess.WRITE)
	else:
		file = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, passkey)
	if file == null: 
		if dire: assert(false, str("file save failed: " + error_string(FileAccess.get_open_error()) + " @" + file_path))
		return ERR_FILE_CANT_WRITE
	
	if dire: print(file_text)
	file.store_string(file_text)
	#file.close()
	if dire: print(error_string(FileAccess.get_open_error()))
	if dire: print("saved file.")
	return OK
#endregion

#region FileSize Methods
## Returns an int FileSize of a File at FilePath
static func get_size_of_file_from_file_path(file_path:String) -> int:
	var file:FileAccess = get_file(file_path)
	if file: return file.get_length();
	return 0

## Returns an Array[int] of FileSizes from an Array[String] of FilePaths
static func get_sizes_of_files_from_file_paths(file_paths:Array[String]) -> Array[int]:
	var all_sizes: Array[int] = []
	for file_path in file_paths: var file_size: int = get_size_of_file_from_file_path(file_path); all_sizes.append(file_size);
	return all_sizes

## Returns an int total of all FileSizes from an Array[String] of FilePaths
static func get_total_size_of_files_from_file_paths(file_paths:Array[String]) -> int:
	var total_size: int = 0
	var all_sizes: Array[int] = get_sizes_of_files_from_file_paths(file_paths)
	for size in all_sizes:
		total_size += size;
	return total_size
#endregion
