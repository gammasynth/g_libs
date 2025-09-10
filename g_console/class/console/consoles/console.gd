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
		if b: 
			can_accept_entry = false
			operation_started.emit()
		else: 
			can_accept_entry = true
			operation_finished.emit()
		operating = b
var can_accept_entry:bool=true

var command_history:Array[String] = []
var command_history_index:int = 0

func _parsing_overflow() -> void: print_out("Busy! Please wait...")

func parse_text_line(text_line:String, force:bool=false) -> Error:
	if not can_accept_entry and not force:
		_parsing_overflow()
		return ERR_BUSY
	command_history.append(text_line)
	return await parser.parse_text_line(text_line)

func print_out(text:Variant) -> void:
	var output = text_edit
	if not text_edit and not rich_label or text_edit and not is_instance_valid(text_edit) or rich_label and not is_instance_valid(rich_label): 
			warn("no text edit or rich label to output to!", ERR_BUG, true, true); return
	
	if rich_label and is_instance_valid(rich_label): output = rich_label
	
	if text is Array:
		for element in text:
			print_out(element)
	else:
		if output.text.is_empty(): output.text = text
		else: output.text = str(output.text + "\n" + text)
		line_count += 1

func clear_console_history():
	if text_edit and is_instance_valid(text_edit): text_edit.text = ""
	if rich_label and is_instance_valid(rich_label): rich_label.text = ""
	line_count = 0
