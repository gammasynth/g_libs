extends Database

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
	return ConsoleParser.new(self)

var line_count:int = 0

var operating: bool = false:
	set(b):
		if b: 
			can_accept_entry = false
			operation_started.emit()
		else: operation_finished.emit()
		operating = b
var can_accept_entry:bool=true

var command_history:Array[String] = []
var command_history_index:int = 0


func parse_text_line(text_line:String) -> Error:
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
