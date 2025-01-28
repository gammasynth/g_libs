extends Database

class_name Console

signal operation_started
signal operation_finished

var line_edit: LineEdit
var text_edit: TextEdit

var parser: ConsoleParser: get = _get_parser
func _get_parser():
	if parser: return parser
	return ConsoleParser.new(self)

var line_count:int = 0


var operating: bool = false:
	set(b):
		if b: operation_started.emit()
		else: operation_finished.emit()
		operating = b


func parse_text_line(text_line:String) -> Error:
	return await parser.parse_text_line(text_line)

func print_out(text:Variant) -> void:
	if not text_edit or text_edit and not is_instance_valid(text_edit): warn("no text edit!", ERR_BUG, true, true); return
	
	if text is Array:
		for element in text:
			print_out(element)
	else:
		if text_edit.text.is_empty(): text_edit.text = text
		else: text_edit.text = str(text_edit.text + "\n" + text)
		line_count += 1

func clear_console_history():
	if text_edit and is_instance_valid(text_edit): text_edit.text = ""
	line_count = 0
