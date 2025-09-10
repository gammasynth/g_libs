extends Console
## The FileConsole was made for the OmniConsole extension of it. See https://gammasynth.com/omni
## FileConsole is a console that tracks a set directory path, it can change directory path, but not execute commands.
class_name FileConsole

signal directory_focus_changed(new_current_path:String)
var current_directory_path: String = "C:/"

func _get_parser():
	if parser: return parser
	parser = FileConsoleParser.new(self)
	return parser


func open_directory(at_path:String=current_directory_path, force:bool=false, print_dir:bool=false) -> void: 
	if not can_change_directory():
		if force: pass
		else: return
	_open_directory(at_path, print_dir)
func _open_directory(at_path:String=current_directory_path, print_dir:bool=false) -> void: change_directory(at_path, print_dir)

func change_directory(at_path:String=current_directory_path, print_dir:bool=false, emit:bool=true) -> void: _change_directory(at_path, print_dir, emit)
func _change_directory(at_path:String=current_directory_path, print_dir:bool=false, emit:bool=true) -> void: 
	current_directory_path = at_path
	
	if print_dir: print_out("cd " + at_path)
	if emit: directory_focus_changed.emit(at_path)

func can_change_directory() -> bool: return _can_change_directory()
func _can_change_directory() -> bool: return true

func refresh() -> void: _refresh()
func _refresh() -> void: change_directory(current_directory_path, false, false)
