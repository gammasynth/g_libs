#|*******************************************************************
# file_item.gd
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

extends RefCounted
class_name FileItem

signal selected
signal deselected

var file_name: String = ""
var file_path: String = ""
var file_type: FileType = null

var is_selected:bool = false:
	set(b):
		if b: selected.emit()
		else: deselected.emit()
		is_selected = b

var cut_state:bool = false

func _init(_file_path:String="", _file_type:FileType=null) -> void:
	file_path = _file_path
	
	file_type = _file_type
	if not file_type: file_type = FileType.get_file_type_from_path(file_path)
	
	if file_type.is_folder:
		file_name = File.begins_with_slash(File.ends_with_slash(file_path, false), false)
	else:
		file_name = File.get_file_name_from_file_path(file_path, true)
