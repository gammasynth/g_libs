#|*******************************************************************
# help.gd
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


extends ConsoleCommand


func _setup_command() -> void:
	is_base_command = true
	has_args = false
	keywords = ["help"]
	command_description = "Lists other relevant commands."
	return


func _perform_command(text_line:String) -> bool:
	# In the case that a user is using the console to stdin a line, we should escape the console help command.
	if console is ExecutiveConsole and (console as ExecutiveConsole).console_processing: return false
	
	console.print_out("command: help")
	
	for command in console.parser.all_commands:
		if command.keywords.is_empty(): continue
		if not command.is_base_command: continue
		
		var this_keywords:String = ""
		var kidx:int=0
		for keyword:String in command.keywords:
			if kidx == 0: this_keywords = str(this_keywords + keyword)
			else: this_keywords = str(this_keywords + "/" + keyword)
			kidx+=1
		console.print_out([str(this_keywords + " :> | " + command.command_description), " "])
		
	
	return true
