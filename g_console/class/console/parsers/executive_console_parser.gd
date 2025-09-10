extends FileConsoleParser
class_name ExecutiveConsoleParser

func _fallback_console_parse(text_line:String) -> Error:
	if try_parse_cd(text_line): did_operate = true
	else:
		console.print_out(str(text_line))
		console.execute(text_line)
		# console executes on thread, so did_operate/operated will set in a later function after the thread
	return OK
