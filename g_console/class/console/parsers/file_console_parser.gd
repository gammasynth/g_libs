#|*******************************************************************
# file_console_parser.gd
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




extends ConsoleParser

class_name FileConsoleParser


func _fallback_console_parse(text_line:String) -> Error:
	if try_parse_cd(text_line): did_operate = true
	return OK


func try_parse_cd(text_line:String) -> bool:
	var parsed:String = text_line
	if text_line.begins_with("cd "): parsed = text_line.substr(3)
	
	#if text is a full absolute path on the filesystm
	if DirAccess.dir_exists_absolute(parsed):
		console.print_out(text_line)
		console.open_directory(parsed)
		return true
	
	# if text is the parent folder
	var branch_above:String = try_text_line_for_above_folder(parsed)
	if not branch_above.is_empty():
		console.print_out(text_line)
		console.open_directory(branch_above)
		return true
	
	# if text is a folder name within the current directory
	var subfolder:String = try_text_line_for_subfolder(parsed)
	if not subfolder.is_empty(): 
		console.print_out(text_line)
		console.open_directory(str(console.current_directory_path + subfolder))
		return true
	
	return false

func try_text_line_for_above_folder(text_line:String) -> String:
	var cp:String = console.current_directory_path
	
	cp = cp.to_lower()
	text_line = text_line.to_lower()
	
	while true:
		while cp.right(1) == "/" or cp.right(1) == "\\": cp = File.ends_with_slash(cp, false)
		
		if not cp.containsn("/") and not cp.containsn("\\"): return ""
		
		var slash_index:int = cp.rfind("/")
		if slash_index == -1: slash_index = cp.rfind("\\")
		if slash_index == -1: return ""
		
		cp = cp.left(slash_index)
		var above_folder_name:String = File.no_slashes(cp).replacen(":","").to_snake_case()
		var line_name: String = File.no_slashes(text_line).to_snake_case()
		
		
		if line_name == above_folder_name:
			cp = File.ends_with_slash(cp)
			if DirAccess.dir_exists_absolute(cp):
				return cp
	
	return ""

func try_text_line_for_subfolder(text_line) -> String:
	var folder_paths: Array[String] = File.get_all_directories_from_directory(console.current_directory_path, true)
	
	text_line = text_line.to_lower()
	
	var folder_name: String = File.no_slashes(text_line).to_snake_case()
	for fp: String in folder_paths:
		var fn:String = File.no_slashes(fp).to_snake_case().to_lower()
		if folder_name == fn:
			fn = str(File.no_slashes(fp) + "/")
			return fn
	
	return ""
