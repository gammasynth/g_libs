extends RefCounted

class_name ConsoleCommand

var console: Console

var is_base_command: bool = false
var has_args: bool = false

var keyword: String = ""

var command_description: String = ""

func _init() -> void:
	_setup_command()

func _setup_command() -> void:
	is_base_command = false
	has_args = false
	keyword = ""
	command_description = ""
	return


func try_parse_line(text_line:String) -> bool:
	
	if text_line.is_empty(): return false
	
	if not is_base_command: return false
	
	if await _try_parse_line(text_line): return true
	
	if not keyword.is_empty() and text_line.to_lower().begins_with(keyword.to_lower()):
		if await _perform_command(text_line): return true
	
	return false


func _try_parse_line(_text_line:String) -> bool:
	return false


func _perform_command(_text_line:String) -> bool:
	return false
