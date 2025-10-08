#|*******************************************************************
# executive_console_parser.gd
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

extends FileConsoleParser
class_name ExecutiveConsoleParser

func _default_parsing_order(text_line:String) -> Error:
	var err: Error = OK
	
	# We inject behavior here specifically for executive consoles.
	if (console as ExecutiveConsole).console_processing: 
		# this means that a process is actively running, and this is another command being sent to it.
		err = await fallback_console_parse(text_line)
		warn("fallback_console_parse", err)
		return err
	
	
	if console.operating and not did_operate:
		err = await _parse_text_line(text_line)
		warn("_parse_text_line", err)
	
	if console.operating and not did_operate:
		err = await default_console_parse(text_line)
		warn("default_console_parse", err)
	
	if console.operating and not did_operate:
		err = await fallback_console_parse(text_line)
		warn("fallback_console_parse", err)
	
	return err

func _fallback_console_parse(text_line:String) -> Error:
	if try_parse_cd(text_line): did_operate = true
	else:
		console.print_out([str(text_line)])#, " "])
		console.execute(text_line)
		# console executes on thread, so did_operate/operated will set in a later function after the thread
	return OK
