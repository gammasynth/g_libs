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
var command_history_index:int = 0

func _parsing_overflow() -> void: print_out("Busy! Please wait...")

func parse_text_line(text_line:String, force:bool=false) -> Error:
	if not can_accept_entry and not force:
		_parsing_overflow()
		return ERR_BUSY
	command_history.append(text_line)
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
