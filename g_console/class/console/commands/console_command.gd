#|*******************************************************************
# console_command.gd
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



extends RefCounted

class_name ConsoleCommand

var console: Console

var is_base_command: bool = false
var has_args: bool = false

var keywords: Array[String] = []

var command_description: String = ""

func _init(_console:Console=null) -> void:
	console = _console
	_setup_command()

func _setup_command() -> void:
	is_base_command = false
	has_args = false
	keywords = []
	command_description = ""
	return


func try_parse_line(text_line:String) -> bool:
	
	if text_line.is_empty(): return false
	
	if not is_base_command: return false
	
	if await _try_parse_line(text_line): return true
	
	if not keywords.is_empty():
		for keyword:String in keywords:
			if text_line.to_lower().begins_with(keyword.to_lower()):
				if await _perform_command(text_line): return true
	
	return false


func _try_parse_line(text_line:String) -> bool:
	return false


func _perform_command(text_line:String) -> bool:
	return false
