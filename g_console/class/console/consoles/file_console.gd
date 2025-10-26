#|*******************************************************************
# file_console.gd
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


extends Console
## The FileConsole was made for the OmniConsole extension of it. See https://gammasynth.com/omni
## FileConsole is a console that tracks a set directory path, it can change directory path, but not execute commands.
class_name FileConsole

signal directory_focus_changed(new_current_path:String)
var current_directory_path: String = "C:/"

func _get_parser():
	if parser: return parser
	parser = FileConsoleParser.new(self)
	return parser


func open_directory(at_path:String=current_directory_path, force:bool=false, print_dir:bool=false) -> void: 
	if not can_change_directory():
		if force: pass
		else: return
	_open_directory(at_path, print_dir)
func _open_directory(at_path:String=current_directory_path, print_dir:bool=false) -> void: change_directory(at_path, print_dir)

func change_directory(at_path:String=current_directory_path, print_dir:bool=false, emit:bool=true) -> void: _change_directory(at_path, print_dir, emit)
func _change_directory(at_path:String=current_directory_path, print_dir:bool=false, emit:bool=true) -> void: 
	
	current_directory_path = File.ends_with_slash(at_path)
	current_directory_path = current_directory_path.replace("\\", "/")
	
	if print_dir: print_out("cd " + at_path)
	if emit: directory_focus_changed.emit(current_directory_path)

func can_change_directory() -> bool: return _can_change_directory()
func _can_change_directory() -> bool: return true

func refresh() -> void: _refresh()
func _refresh() -> void: change_directory(current_directory_path, false, false)
