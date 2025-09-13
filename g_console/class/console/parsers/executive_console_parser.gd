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
