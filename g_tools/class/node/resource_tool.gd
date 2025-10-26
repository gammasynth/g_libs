#|*******************************************************************
# resource_tool.gd
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


@tool
extends Node
class_name ResourceTool

@export var resource_control_type: Resource = null

@export var operation_path: String = "res://"

@export var resource_save_path: String = "res://src/resources/resource_folder/file_name.ext"

@export var create_animated_texture: bool = false:
	set(b):
		create_animated_texture = b
		if b:
			do_create_animated_texture()
			await get_tree().create_timer(0.5)
			create_animated_texture = false



func do_create_animated_texture() -> void:
	var image_file_paths: Array[String] = FileTool.get_all_filepaths_from_directory(operation_path, "", true)
	
	
	for fp:String in image_file_paths:
		if fp.ends_with("import"): image_file_paths.erase(fp)
	
	var fp_count:int = image_file_paths.size()
	
	if not image_file_paths or fp_count == 0 or fp_count > AnimatedTexture.MAX_FRAMES: 
		print("ResourceTool | Cant save AnimatedTexture!")
		return
	
	var anim_tex: AnimatedTexture = AnimatedTexture.new()
	
	anim_tex.frames = fp_count
	
	var idx: int = 0
	for fp: String in image_file_paths:
		var img: Texture2D = load(fp)
		if not img: continue
		
		anim_tex.set_frame_texture(idx, img)
		idx += 1
	
	ResourceSaver.save(anim_tex, resource_save_path)
	print("ResourceTool | Saved resource successfully.")
