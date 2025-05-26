extends Console

class_name ExecutiveConsole

signal directory_focus_changed(new_current_path:String)

var current_directory_path: String = "C:/":
	set(path):
		current_directory_path = path
		directory_focus_changed.emit(path)

func _get_parser():
	if parser: return parser
	return ExecutiveConsoleParser.new(self)


func execute(order:String) -> void:
	var output = []
	OS.execute("CMD.exe", ["/C", str("cd " + current_directory_path + " && " + order)], output, true, false)
	chat(output, -1, true)
	print_out(order)
	print_out(output)


func open_directory(at_path:String=current_directory_path) -> void: current_directory_path = at_path
