## File is a Static Helper Class to streamline interactions with files, folders, and paths.
## 
## Most of its functionality is in its related Classes:
## [br]
## [FileUtil], [FolderUtil], [FileObjectUtil]
## [br][br]
## Any method in one of the above classes is accessible from this File class.
##[br][br]
##
## [FileUtil] methods help manage FilePath and FileName Strings. [br][br]
## [FileUtil] methods help open, save, and load Files. [br][br]
##
## [FolderUtil] methods help manage Directories, and get FilePath Strings within Directories. [br][br]
##
## [FileObjectUtil] methods help with serializing data to and from Files.
class_name File

static var debug:bool = false

# FOLDER UTILITIES

#region Folder Utilities

static func check_valid_directory(folder_path:String) -> bool: return FolderUtil.check_valid_directory(folder_path)

static func has_files(folder_path:String) -> bool: return FolderUtil.has_files(folder_path)

## Get a FolderName from a Path.
static func get_folder(path:String, full_path:bool=false) -> String: return FolderUtil.get_folder(path, full_path)

#region Directory Elements Methods
## Scan a Directory for Directories, return an Array[String] each Directory's path (or full_path)
static func get_all_directories_from_directory(folder_path:String, full_path:bool=false, recursive:bool=false) -> Array[String]: return FolderUtil.get_all_directories_from_directory(folder_path, full_path, recursive)

## Scan a Directory for files, return an Array of each file's path (or full_path)
## A whitelist can be used to only collect files of certain extensions
static func get_all_filepaths_from_directory(file_path:String, whitelist_extension:String="", full_path:bool=false) -> Array[String]: return FolderUtil.get_all_filepaths_from_directory(file_path, whitelist_extension, full_path)

## Return all FilePaths within a Folder and within every Subfolder, Recursively.
## @experimental: useful?
static func search_for_file_paths_recursively(folder_path:String, as_dictionary:bool=false, extra_folder:bool=true, inlcude_hidden:bool=false) -> Variant: return FolderUtil.search_for_file_paths_recursively(folder_path, as_dictionary, extra_folder, inlcude_hidden)
#endregion

#endregion

# - - - - - - -


# FILE UTILITIES

#region File Utilities


static func is_user_dir(path:String) -> bool: return FileUtil.is_user_dir(path)


#region Slash Methods
## Make a FilePath begin with "/", if it needs to, or remove any path before and containing the first "/", if it has one.
static func begins_with_slash(file_path:String, does:bool=true, backslash:bool=false) -> String: return FileUtil.begins_with_slash(file_path, does, backslash)

## Make a FilePath end with a "/", if it needs to, or remove a "/" from the end of the FilePath.
static func ends_with_slash(file_path:String, does:bool=true, backslash:bool=false) -> String: return FileUtil.ends_with_slash(file_path, does, backslash)

static func no_slashes(file_path:String) -> String:  return FileUtil.no_slashes(file_path)
#endregion


#region FileExtension Methods
## Remove a FileExtension and it's period from a FilePath, if there is one.
static func remove_extension_from_file_path(file_path: String) -> String: return FileUtil.remove_extension_from_file_path(file_path)

## Remove FileExtensions and their periods from FilePaths, where there are ones.
static func remove_extensions_from_file_paths(file_paths: Array[String]) -> Array[String]: return FileUtil.remove_extensions_from_file_paths(file_paths)
#endregion

#region FileName Methods
## Get a FileName from a FilePath, and can optionally get with FileExtension ending.
static func get_file_name_from_file_path(file_path:String, with_extension:bool=false) -> String: return FileUtil.get_file_name_from_file_path(file_path,with_extension)

## Get an Array[String] of FileNames from an Array[String] of FilePaths, and can optionally get with FileExtension endings.
static func get_file_names_from_file_paths(file_paths: Array[String], with_extension:bool=false) -> Array[String]: return FileUtil.get_file_names_from_file_paths(file_paths,with_extension)
#endregion




#region Primary File Operation Methods
## Returns an opened FileAccess at FilePath, if there is one, or null. Will use encryption when fed a passkey.
static func get_file(file_path:String, passkey:String="", force:bool=false) -> FileAccess: return FileUtil.get_file(file_path, passkey, force)
#endregion

#region File Validation
static func is_file(file_path:String) -> bool: return FileUtil.is_file(file_path)

static func is_valid_file(file_path:String, passkey:String="") -> bool: return FileUtil.is_valid_file(file_path, passkey)

static func is_import_info_file(file_path) -> bool: return FileUtil.is_import_info_file(file_path)

static func is_valid_gd_script_file(file_path:String) -> bool: return FileUtil.is_valid_gd_script_file(file_path)

static func is_valid_godot_resource(file_path:String) -> bool: return FileUtil.is_valid_godot_resource(file_path)

static func is_valid_image_resource(file_path:String) -> bool: return FileUtil.is_valid_image_resource(file_path)

static func is_valid_audio_resource(file_path:String) -> bool: return FileUtil.is_valid_audio_resource(file_path)

static func is_valid_image_or_audio_resource(file_path:String) -> bool: return FileUtil.is_valid_image_or_audio_resource(file_path)

static func is_valid_resource(file_path:String) -> bool: return FileUtil.is_valid_resource(file_path)
#endregion

#region Load and Save Text Files
## Find a text-based File from a FolderPath + FileName in the filesystem, and return it's contents as a String. Will use encryption when fed a passkey.
static func load_text_file_at_path_by_name(folder_path:String, file_name:String, passkey:String = "") -> String: return FileUtil.load_text_file_at_path_by_name(folder_path, file_name, passkey)

## Find a text-based File from a FilePath in the filesystem, and return it's contents as a String.
static func load_text_file(file_path:String, passkey:String = "", dire:bool=debug) -> String: return FileUtil.load_text_file(file_path, passkey, dire)

## Save text to a File at FolderPath + FileName, uses encryption if fed a passkey.
static func save_text_file_at_path_by_name(file_text:String, folder_path:String, file_name:String, passkey:String = "") -> Error: return FileUtil.save_text_file_at_path_by_name(file_text, folder_path, file_name, passkey)

## Save text to a File at FilePath, uses encryption if fed a passkey.
static func save_text_file(file_text:String, file_path:String, passkey:String = "", dire:bool=debug) -> Error: return FileUtil.save_text_file(file_text, file_path, passkey, dire)
#endregion

#region FileSize Methods
## Returns an int FileSize of a File at FilePath
static func get_size_of_file_from_file_path(file_path:String) -> int: return FileUtil.get_size_of_file_from_file_path(file_path)

## Returns an Array[int] of FileSizes from an Array[String] of FilePaths
static func get_sizes_of_files_from_file_paths(file_paths:Array[String]) -> Array[int]: return FileUtil.get_sizes_of_files_from_file_paths(file_paths)

## Returns an int total of all FileSizes from an Array[String] of FilePaths
static func get_total_size_of_files_from_file_paths(file_paths:Array[String]) -> int: return FileUtil.get_total_size_of_files_from_file_paths(file_paths)
#endregion

#endregion

# - - - - - - -


# FILE OBJECT UTILITIES


#region File Object Utilities

#region Serialization

static func string_to_vector2(string := "") -> Vector2: return FileObjectUtil.string_to_vector2(string)

static func recursively_serialize_object(instance: Object) -> Dictionary: return FileObjectUtil.recursively_serialize_object(instance)

static func initialize_resource_from_dictionary(resource_obj:Resource, resource_dict:Dictionary) -> Resource: return FileObjectUtil.initialize_resource_from_dictionary(resource_obj, resource_dict)

static func convert_resource_to_dictionary(resource_obj:Resource) -> Dictionary: return FileObjectUtil.convert_resource_to_dictionary(resource_obj)
#endregion


#region File Object Saving and Loading

static func load_dict_file_at_path_by_name(file_path:String, file_name:String, passkey:String = "key") -> Dictionary: return FileObjectUtil.load_dict_file_at_path_by_name(file_path, file_name, passkey)

## Uses load_text_file to load a String from a Text-Based File in the FileSystem
## Uses JSON.parse to convert the loaded String into a Dictionary
static func load_dict_file(file_path:String, passkey:String = "", dire: bool = false) -> Dictionary: return FileObjectUtil.load_dict_file(file_path, passkey, dire)

## Use JSON.stringify to convert a Dictionary into a String and save_text_file to save the String to a Text-Based File in the FileSystem.
static func save_dict_file_at_path_by_name(file_dict:Dictionary, file_path:String, file_name:String, passkey:String = "") -> Error: return FileObjectUtil.save_dict_file_at_path_by_name(file_dict, file_path, file_name, passkey)

## Use JSON.stringify to convert a Dictionary into a String and save_text_file to save the String to a Text-Based File in the FileSystem.
static func save_dict_file(file_dict:Dictionary, file_path:String, passkey:String = "") -> Error: return FileObjectUtil.save_dict_file(file_dict, file_path, passkey)

## Load all GDScript objects from Directory
#static func load_all_gdscript_classes_from_directory(file_path:String) -> Array[GDScript]:  return FileObjectUtil.

## Load a Directory at file_path and return any files found as Dictionary of loaded Objects.
## This will ignore SubDirectories, and will only search in the root of given file_path.
## The Dictionary's keys will be each value's corresponding file name.
static func load_all_gdscript_classes_from_directory_with_filenames(folder_path:String, keep_file_extensions:bool=false) -> Dictionary:  return FileObjectUtil.load_all_gdscript_classes_from_directory_with_filenames(folder_path, keep_file_extensions)

## Load a Directory at folder_path and return any files found as Array[Object] list of loaded Objects
## This will ignore SubDirectories, and will only search in the root of given file_path
static func load_all_objects_from_directory(folder_path:String) -> Array[Object]:  return FileObjectUtil.load_all_objects_from_directory(folder_path)

## Load a Directory at folder_path and return any Files found as Dictionary of loaded Objects.
## This will ignore SubDirectories, and will only search in the root of given file_path.
## The Dictionary's keys will be each value's corresponding file name
static func load_all_objects_from_directory_with_filenames(folder_path:String, keep_file_extensions:bool=false) -> Dictionary:  return FileObjectUtil.load_all_objects_from_directory_with_filenames(folder_path, keep_file_extensions)

## Load and return an Object from a File at folder_path + file_name, if there is one, only useable for local project resources.
static func load_object_from_file_path_and_name(folder_path:String, file_name:String) -> Object: return FileObjectUtil.load_object_from_file_path_and_name(folder_path, file_name)

## Load and return an Object from a File at file_path, if there is one, only useable for local project resources.
static func load_object_from_file(file_path:String) -> Object: return FileObjectUtil.load_object_from_file(file_path)


## Load and return a GDScript File at folder_path + file_name, if there is one, only useable for local project resources.
static func load_gdscript_from_file_path_and_name(folder_path:String, file_name:String, from_user:bool=false) -> GDScript: return FileObjectUtil.load_gdscript_from_file_path_and_name(folder_path, file_name, from_user)

## Load and return a GDScript File at file_path, if there is one, only useable for local project resources.
static func load_gdscript_file(file_path:String, from_user:bool=false) -> GDScript: return FileObjectUtil.load_gdscript_file(file_path, from_user)


static func load_image(file_path:String) -> Texture2D: return FileObjectUtil.load_image(file_path)

## ONLY MP3 LOADING IS CURRENTLY SUPPORTED!
## @experimental
static func load_audio(file_path:String) -> AudioStreamMP3: return FileObjectUtil.load_audio(file_path)


static func try_load_file(file_path:String, only_user_files:bool=false) -> Variant: return FileObjectUtil.try_load_file(file_path, only_user_files)

#endregion
#endregion
