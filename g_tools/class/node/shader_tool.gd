#|*******************************************************************
# shader_tool.gd
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

@tool
extends Node
class_name ShaderTool

@export var folder_of_shaders: String = ""
@export var output_folder: String = ""

@export var force_overwrites:bool=false

@export var convert_shaders_to_shader_includes: bool = false:
	set(b):
		convert_shaders_to_shader_includes = b
		if b:
			convert_shaders_to_shader_includes_action()
			await get_tree().create_timer(0.1).timeout
			convert_shaders_to_shader_includes = false

@export var convert_shaders_to_shader_materials: bool = false:
	set(b):
		convert_shaders_to_shader_materials = b
		if b:
			convert_shaders_to_shader_materials_action()
			await get_tree().create_timer(0.1).timeout
			convert_shaders_to_shader_materials = false


func get_shaders() -> Array[Shader]:
	var shaders:Array[Shader] = []
	var file_paths : Array[String] = FileTool.get_all_filepaths_from_directory(folder_of_shaders, "", true)
	for file_path in file_paths:
		if FileTool.is_valid_godot_resource(file_path):
			var file = load(file_path)
			var shader: Shader = null; if file is Shader: shader = file
			if not shader:
				print("error loading shader: " + file_path)
				continue
			shaders.append(shader)
	return shaders

func convert_shaders_to_shader_includes_action():
	var file_paths : Array[String] = FileTool.get_all_filepaths_from_directory(folder_of_shaders, "", true)
	var shaders:Array[Shader] = get_shaders()
	var idx:int = 0
	for shader:Shader in shaders:
		var code: String = shader.code
		code = code.replacen("shader_type canvas_item;", "")
		code = code.replacen("shader_type spatial;", "")
		
		if code.containsn("void fragment() {"):
			var idx1 = code.findn("void fragment() {")
			code = code.replacen("void fragment() {", "")
			var idx2 = code.findn("}", idx)
			var c = code.substr(idx1, (idx2 - idx1) + 1)
			code = code.replacen(c, "")
		
		var inc :ShaderInclude = ShaderInclude.new()
		inc.code = code
		
		var file_path = file_paths.get(idx)
		var fn: String = FileTool.get_file_name_from_file_path(file_path)
		fn = str(fn + ".gdshaderinc")
		
		var fp : String = str(FileTool.ends_with_slash(output_folder) + fn)
		
		if FileAccess.file_exists(fp): 
			if not force_overwrites:
				print("skipping existing shader include file!")
				continue
			else:
				print("overwriting existing shader include file!" + fp)
		
		var err = ResourceSaver.save(inc, fp)
		if err == OK: print("saved new shader include file")
		else: print("error saving shader include file")
	idx += 1


func convert_shaders_to_shader_materials_action():
	var file_paths : Array[String] = FileTool.get_all_filepaths_from_directory(folder_of_shaders, "", true)
	var shaders:Array[Shader] = get_shaders()
	var idx:int = 0
	for shader:Shader in shaders:
		var mat :ShaderMaterial = ShaderMaterial.new()
		mat.shader = shader
		
		var file_path = file_paths.get(idx)
		var fn: String = FileTool.get_file_name_from_file_path(file_path)
		fn = str(fn + ".material")
		
		var fp : String = str(FileTool.ends_with_slash(output_folder) + fn)
		
		if FileAccess.file_exists(fp): 
			if not force_overwrites:
				print("skipping existing shader material file!")
				continue
			else:
				print("overwriting existing shader material file!" + fp)
		
		var err = ResourceSaver.save(mat, fp)
		if err == OK: print("saved new shader material file")
		else: print("error saving shader material file")
		
		idx += 1
