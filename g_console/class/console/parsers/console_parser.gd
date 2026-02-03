#|*******************************************************************
# console_parser.gd
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




extends Database

class_name ConsoleParser

var console:Console

var started_operating:bool=false
var did_operate: bool = false:
	set(b):
		did_operate = b
		if b and console.operating: 
			did_operate = false
			console.operating = false

var console_command_library_names: Dictionary[String, Array]: get = _get_console_command_library_names

var all_commands:Array[ConsoleCommand] = []
var loaded_commands:bool = false
var need_reload_commands:bool = false

func _get_console_command_library_names() -> Dictionary[String, Array]:
	if not console_command_library_names.is_empty(): return console_command_library_names
	return {"console_commands" : ["commands"]} # String Registry name : Array[String] [RegistryEntry names]


func _init(_console:Console=null, _name:String="console_parser", _key:Variant=_name) -> void:
	super(_name, _key)
	console = _console

func parse_text_line(text_line:String) -> Error:
	if not console.can_accept_entry: 
		# here is where we can introduce a "parse line queue"
		return ERR_BUSY# TODO
	console.operating = true
	
	var err: Error = await _default_parsing_order(text_line)
	
	return err

func _default_parsing_order(text_line:String) -> Error:
	var err: Error = OK
	
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


func _parse_text_line(_text_line:String) -> Error: 
	# override this function in an extended parser to change the primary parsing functionality
	#
	# set the bool did_operate to true when you do handle a text/command
	#
	# if you do not set did_operate to true, 
	# then the default and/or fallback parses will try to run after this function
	return OK


func default_console_parse(text_line:String) -> Error:
	return await _default_console_parse(text_line)


func _default_console_parse(text_line:String) -> Error:
	if loaded_commands:
		if need_reload_commands: load_commands_from_registry()
	else: load_commands_from_registry()
	
	for command:ConsoleCommand in all_commands:
		var accepted: bool = await command.try_parse_line(text_line)
		if accepted:
			did_operate = true
			break
	return OK


func load_commands_from_registry() -> void:
	all_commands.clear()
	for registry_name:String in console_command_library_names:
		
		var registry: Registry = Registry.get_registry(registry_name)
		if not registry:
			warn(str("invalid library name, nonexistent Registry: " + registry_name))
			continue
		
		var library_names:Array = console_command_library_names.get(registry_name)
		for library_name:String in library_names:
			var library:RegistryEntry = registry.grab(library_name)
			if not library:
				warn(str("invalid library name, nonexistent RegistryEntry: " + library_name))
				continue
			
			for command_key in library.data:
				var command_script = library.grab(command_key)
				if not command_script or command_script and command_script is not GDScript:
					warn("null command_script", ERR_FILE_UNRECOGNIZED, false); continue
				
				var command: ConsoleCommand = command_script.new(console)
				if not command or command is not ConsoleCommand:
					warn("bad command class instance"); continue
				
				all_commands.append(command)



func fallback_console_parse(text_line:String) -> Error:
	return await _fallback_console_parse(text_line)

func _fallback_console_parse(_text_line:String) -> Error:
	return OK
