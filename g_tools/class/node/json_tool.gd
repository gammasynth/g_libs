#|*******************************************************************
# json_tool.gd
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
@tool
extends Node
class_name JsonTool

@export var data : Dictionary = {}
@export_global_file() var json_file = ""
@export var new_file_path:String = ""
@export var encryption_key : String = ""

@export_tool_button("Read Json Data from File") var read_data_action: Callable = read_data
@export_tool_button("Write Json Data to File") var write_data_action: Callable = write_data

func validate_path(path:Variant) -> bool:
	if typeof(path) == 0 or not path or (path is String and path.is_empty()): return false
	return true

func read_data() -> void: 
	var path = json_file; if not validate_path(path): path = new_file_path
	if not validate_path(path):
		print("JsonTool | Error: No valid path!")
		return
	
	data = FileUtilTool.load_dict_file(path, encryption_key)
	print("JsonTool | Loaded file!")
	print(data)

func write_data() -> void: 
	var path = json_file; if not validate_path(path): path = new_file_path
	if not validate_path(path):
		print("JsonTool | Error: No valid path!")
		return
	
	var err:Error = FileUtilTool.save_dict_file(data, path, encryption_key)
	if err == OK: print("JsonTool | Saved file!" )
	else: print(str("Err == " + str(err) + " " + error_string(err)))
	
