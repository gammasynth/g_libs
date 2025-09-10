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
