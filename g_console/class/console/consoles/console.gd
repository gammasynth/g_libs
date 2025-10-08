#|*******************************************************************
# console.gd
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

extends Database
## The Console was made for the OmniConsole extension of it. See https://gammasynth.com/omni
## A console can optionally use a line_edit as a GUI input, and optionally use a text_edit or rich_label as a GUI output.
## An extended console class can be given a custom ConsoleParser extended class, via overriding the _get_parser function.
## To add commands for a console, enable the Registry system for an app, and add Scripts extended from the ConsoleCommand class into a folder named "commands".
## The Registry system will then handle loading of your command scripts, and a default ConsoleParser can then use those loaded commands.
class_name Console

signal operation_started
signal operation_finished

var line_edit: LineEdit

# outputs
var text_edit: TextEdit
var rich_label: RichTextLabel
#var label: Label

var parser: ConsoleParser: get = _get_parser
func _get_parser():
	if parser: return parser
	parser = ConsoleParser.new(self)
	return parser

var line_count:int = 0

var operating: bool = false:
	set(b):
		var was_operating:bool = operating
		operating = b
		if b: 
			can_accept_entry = false
			if not was_operating: operation_started.emit()
		else: 
			can_accept_entry = true
			if was_operating: operation_finished.emit()

var can_accept_entry:bool=true

var main_log:String = ""
var last_print:String = ""

# TODO
var command_history:Array[String] = []
var command_history_index:int = -1

enum CONSOLE_HISTORY_TRAVEL_TYPES {NONE, BACKWARD, FORWARD, EARLIEST, LATEST}

func travel_console_history(travel_type:CONSOLE_HISTORY_TRAVEL_TYPES=CONSOLE_HISTORY_TRAVEL_TYPES.NONE) -> String:
	if command_history_index == -1: command_history_index = command_history.size()
	var next_line:String = ""
	if command_history.size() == 0: return next_line
	match travel_type:
		CONSOLE_HISTORY_TRAVEL_TYPES.BACKWARD:
			command_history_index -= 1
			if command_history_index < 0:
				command_history_index = 0
			next_line = command_history.get(command_history_index)
		CONSOLE_HISTORY_TRAVEL_TYPES.FORWARD:
			command_history_index += 1
			if command_history_index > command_history.size() - 1:
				command_history_index = command_history.size() - 1
			next_line = command_history.get(command_history_index)
		CONSOLE_HISTORY_TRAVEL_TYPES.EARLIEST: 
			command_history_index = 0
			next_line = command_history.get(command_history_index)
		CONSOLE_HISTORY_TRAVEL_TYPES.LATEST: 
			command_history_index = command_history.size() - 1
			next_line = command_history.get(command_history_index)
			command_history_index = -1
	return next_line

func _parsing_overflow() -> void: print_out("Busy! Please wait...")

func parse_text_line(text_line:String, force:bool=false) -> Error:
	if not can_accept_entry and not force:
		_parsing_overflow()
		return ERR_BUSY
	if not command_history.has(text_line):
		command_history.append(text_line)
		command_history_index = -1
	return await parser.parse_text_line(text_line)

func print_out(printable:Variant) -> void:
	if printable is Array: for element:Variant in printable: print_out(element)
	#elif printable is Dictionary: # TODO MAYBE ADD DICTIONARY PARSING IDK< JSUT STRING EM
		#for keyat:Variant in printable: 
			#var value:Variant = printable.get(keyat)
			#print_out(element)
	elif printable is String: print_out_text(printable)
	else: print_out_text(str(printable))

func print_out_text(text:String) -> void:
	var output = text_edit
	var warning:String = "no text edit or rich label to output to!"
	var do_warning:bool=false
	if not text_edit and not rich_label: do_warning = true
	if text_edit and not is_instance_valid(text_edit) or rich_label and not is_instance_valid(rich_label): do_warning = true
	if do_warning: warn(warning, ERR_BUG, true, true); return
	
	if rich_label and is_instance_valid(rich_label): output = rich_label
	# if both a textedit and rich label are assigned, only richlabel will be used  TODO improve this
	
	if output.text.is_empty(): output.text = text
	else: output.text = str(output.text + "\n" + text)
	
	if main_log.is_empty(): main_log = text
	else: main_log = str(main_log + "\n" + text)
	
	last_print = text
	line_count += 1

func clear_console_history():
	if text_edit and is_instance_valid(text_edit): text_edit.text = ""
	if rich_label and is_instance_valid(rich_label): rich_label.text = ""
	line_count = 0
