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

var console_command_library_names: Array[String]: get = _get_console_command_library_names
func _get_console_command_library_names() -> Array[String]:
	if not console_command_library_names.is_empty(): return console_command_library_names
	return ["console_commands"]


func _init(_console:Console=null, _name:String="console_parser", _key:Variant=_name) -> void:
	super(_name, _key)
	console = _console

func parse_text_line(text_line:String) -> Error:
	if console.operating: 
		# here is where we can introduce a "parse line queue"
		return ERR_BUSY# TODO
	console.operating = true
	
	var err: Error = await _parse_text_line(text_line)
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
	var operated: bool = false
	for library_name:String in console_command_library_names:
		if operated: break
		
		var library: Registry = Registry.get_registry(library_name)
		if not library:
			warn(str("invalid library name, nonexistent registry: " + library_name))
			continue
		
		for command_key in library.data:
			if operated: break
			
			var command_script = library.grab(command_key)
			if not command_script or command_script and command_script is not GDScript:
				warn("null command_script", ERR_FILE_UNRECOGNIZED, false); continue
			
			var command: ConsoleCommand = command_script.new()
			if not command or command is not ConsoleCommand:
				warn("bad command class instance"); continue
			command.console = console
			
			var accepted: bool = await command.try_parse_line(text_line)
			if accepted:
				operated = true
				break
		
	
	if operated: did_operate = true
	
	return OK


func fallback_console_parse(text_line:String) -> Error:
	return await _fallback_console_parse(text_line)

func _fallback_console_parse(_text_line:String) -> Error:
	return OK
