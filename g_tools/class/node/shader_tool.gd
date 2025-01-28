@tool
extends Node
class_name ShaderTool

@export var folder_of_shaders: String = ""
@export var shader_include_output_folder: String = ""

@export var convert_shaders_to_shader_includes: bool = false:
	set(b):
		convert_shaders_to_shader_includes = b
		if b:
			convert_shaders_to_shader_includes_action()
			await get_tree().create_timer(0.1).timeout
			convert_shaders_to_shader_includes = false

func convert_shaders_to_shader_includes_action():
	var file_paths : Array[String] = FileTool.get_all_filepaths_from_directory(folder_of_shaders, "", true)
	for file_path in file_paths:
		if FileTool.is_valid_godot_resource(file_path):
			var shader: Shader = load(file_path)
			if not shader:
				print("error loading shader: " + file_path)
				continue
			
			var code: String = shader.code
			code = code.replacen("shader_type canvas_item;", "")
			code = code.replacen("shader_type spatial;", "")
			
			if code.containsn("void fragment() {"):
				var idx = code.findn("void fragment() {")
				code = code.replacen("void fragment() {", "")
				var idx2 = code.findn("}", idx)
				var c = code.substr(idx, (idx2 - idx) + 1)
				code = code.replacen(c, "")
			
			var inc :ShaderInclude = ShaderInclude.new()
			inc.code = code
			
			var fn: String = FileTool.get_file_name_from_file_path(file_path)
			fn = str(fn + ".gdshaderinc")
			
			var fp : String = str(FileTool.ends_with_slash(shader_include_output_folder) + fn)
			
			if FileAccess.file_exists(fp): 
				print("skipping existing shader include file!")
				continue
			
			var err = ResourceSaver.save(inc, fp)
			if err == OK: print("saved new shader include file")
			else: print("error saving shader include file")
