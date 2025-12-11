#|*******************************************************************
# executive_console.gd
#*******************************************************************
# This file is part of g_libs.
# 
# g_libs is an open-source software library.
# g_libs is licensed under the MIT license.
# https://github.com/gammasynth/g_libs
#*******************************************************************
# Copyright (c) 2025 AD - present; 1447 AH - present, Gammasynth.  
# Gammasynth (Gammasynth Software), Texas, U.S.A.
# 
# This software is licensed under the MIT license.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
#|*******************************************************************


extends FileConsole

## The ExecutiveConsole was made for the OmniConsole extension of it. See https://gammasynth.com/omni
## Be advised, one should uses_threads or uses_piped, but probably not both, but both might work, - 
## - you likely want threads or pipes, else the MainLoop will freeze/block during an unfinished shell execution.
## The shell execution methods will only occur after first checking if the entered/parsed command was already handled,
## execution happens in the parser's fallback_execution, whereas it will first check for an app's commands in registries.
## If you do not plan to be operating shell commands in the OS of your app, you should use Console instead of ExecutiveConsole.
class_name ExecutiveConsole

signal thread_process_started
signal pipe_process_started
signal process_started


@export var uses_threads:bool = false
@export var uses_piped:bool=false

var is_piping:bool = false
var pipe_stdio:FileAccess = null
var pipe_stderr:FileAccess = null
var pipe_pid:int = -1
var pipe_time:float = 0.0

var max_pipe_stdio_read_attempts:int = 100
var max_pipe_stderr_read_attempts:int = 100

var received_pipe_data:bool=false

var monitor_thread:Thread = null

var execution_thread:Thread = null
var execution_mutex:Mutex = Mutex.new()
var thread_time:float = 0.0

var long_process:bool=false

var refresh_during_process:bool=true
var refresh_rate := 0.1
var refresh_delta := 0.0

var uses_process:bool=false
var console_processing:bool=false:
	set(b):
		if b and uses_threads: if uses_process: thread_process_started.emit()
		if b and uses_piped: if uses_process: pipe_process_started.emit()
		console_processing = b

@export var console_cancel_input_names:Array[String] = ["x", "esc", "control+c"]

func _get_parser():
	if parser: return parser
	parser = ExecutiveConsoleParser.new(self)
	return parser

func _init(_name:String="executive_console", _key:Variant=_name) -> void:
	super(_name, _key)
	thread_process_started.connect(process_was_started)
	pipe_process_started.connect(process_was_started)

func cancel_threaded_execution() -> void:
	pass

func process_was_started() -> void: process_started.emit()


func execute(order:String) -> void:
	var output:Array = ["Processing...", " "]
	console_processing = true
	if uses_threads:
		if uses_piped:
			output = perform_execution(order)
		else:
			thread_time = 0.0
			long_process = false
			execution_thread = Thread.new()
			execution_thread.start(execute_threaded.bind(order))
	else: output = perform_execution(order)
	
	var piping:bool = false
	execution_mutex.lock()
	piping = is_piping
	execution_mutex.unlock()
	
	var finish:bool = not piping
	if finish and uses_threads: finish = false
	
	if finish: finish_execution(output)
	else: 
		if piping: can_accept_entry = true
		command_entered_print(output)
		if operating: parser.did_operate = true
		if uses_threads and not uses_process:
			monitor_thread = Thread.new()
			if uses_piped:
				execution_mutex.lock()
				monitor_thread.start(threaded_pipe_loop.bind(pipe_pid, pipe_stdio))
				execution_mutex.unlock()
			else:
				monitor_thread.start(threaded_loop)

func threaded_loop() -> void:
	while execution_thread.is_started() and execution_thread.is_alive():
		if not execution_thread.is_alive(): break

func threaded_pipe_loop(pid:int, stdio:FileAccess) -> void:
	while stdio is FileAccess and stdio.is_open():
		print_pipe_io()
		if not OS.is_process_running(pid): stop_pipe()

func execute_threaded(order:String) -> Array: return perform_execution(order)

func perform_execution(order:String) -> Array:
	var output:Array = []
	if uses_piped: output = perform_piped_execution(current_directory_path, order, uses_threads)
	else: output = perform_classic_execution(order)
	return output

func perform_piped_execution(at_path:String, order:String, blocking:bool=false) -> Array:
	execution_mutex.lock()
	received_pipe_data = false
	
	var output:Array = []# output and stderr from command run
	if is_piping and pipe_pid != -1 and pipe_stdio is FileAccess and pipe_stdio.is_open():
		if not pipe_stdio.store_line(order): print("CANT SEND NEW COMMAND!")
		pipe_stdio.flush()# This appears to not work, both these lines. Console pipe doesnt react to additional commands.
		execution_mutex.unlock()
		return [order]
	
	var output_dictionary:Dictionary = {}
	#
	# TODO IMPLEMENT OTHER OS TERMINALS
	if OS.get_name() == "Windows":
		var args:Array = [
			"/C", 
			str("cd " + at_path + " && " + order)#,
			#str("cd " + current_directory_path + " && " + "echo.>OMNI_OPERATED.oco")# BUG track files as args doesnt work this current setup way
			]
		output_dictionary = OS.execute_with_pipe("CMD.exe", args, blocking)
	elif OS.get_name() == "Linux":
		var args:Array = [
			"-c",
			str("cd " + at_path + " && " + order)#,
			#str("cd " + current_directory_path + " && " + "touch OMNI_OPERATED.oco")# BUG track files as args doesnt work this current setup way
			]
		output_dictionary = OS.execute_with_pipe("/bin/sh", args, blocking)
	elif OS.get_name() == "Android":
		var args:Array = [
			"-c",
			str("cd " + at_path + " && " + order)#,
			#str("cd " + current_directory_path + " && " + "touch OMNI_OPERATED.oco")# BUG track files as args doesnt work this current setup way
			]
		# TODO PLS implement Android give system perms
		output_dictionary = OS.execute_with_pipe("/system/bin/sh", args, blocking)
	else:
		var args:Array = [
			"-c",
			str("cd " + at_path + " && " + order)#,
			#str("cd " + current_directory_path + " && " + "touch OMNI_OPERATED.oco")# BUG track files as args doesnt work this current setup way
			]
		# TODO TEST IF THIS IS SUFFICIENT FOR OTHER SYSTEMS TODO TEST
		output_dictionary = OS.execute_with_pipe("/bin/sh", args, blocking)
	
	#- "stdio" - FileAccess to access the process stdin and stdout pipes (read/write).
	#- "stderr" - FileAccess to access the process stderr pipe (read only).
	#- "pid" - Process ID as an int, which you can use to monitor the process (and potentially terminate it with kill()).
	
	if output_dictionary == null or output_dictionary is Dictionary and output_dictionary.size() == 0:
		stop_pipe()
		return [" ", "Command failed, or nothing happened."]
	
	execution_mutex.lock()
	pipe_stdio = output_dictionary.get("stdio")
	pipe_stderr = output_dictionary.get("stderr")
	pipe_pid = output_dictionary.get("pid")
	#print("COMMAND PID: " + str(pipe_pid))
	#print("COMMAND RUNNING: " + str(OS.is_process_running(pipe_pid)))
	is_piping = true
	if pipe_stdio is FileAccess and pipe_stdio.is_open(): pass
	else: stop_pipe()
	output = [" ", "Processing..."]
	execution_mutex.unlock()
	return output

func perform_classic_execution(order:String, open_console:bool=false, read_stderr:bool=true) -> Array:
	var output:Array = []# output and stderr from command run
	var args:Array = ["-c", order]
	# TODO IMPLEMENT OTHER OS TERMINALS
	if OS.get_name() == "Windows":
		var this_command_arg:String = str("cd " + current_directory_path + " && " + order)
		args = ["/C", this_command_arg]
		OS.execute("CMD.exe", args, output, read_stderr, open_console)
	elif OS.get_name() == "Linux":
		OS.execute("/bin/sh", args, output, read_stderr, open_console)
	elif OS.get_name() == "Android":
		# TODO PLS implement Android give system perms
		OS.execute("/system/bin/sh", args, output, read_stderr, open_console)
	else:
		# TODO TEST IF THIS IS SUFFICIENT FOR OTHER SYSTEMS TODO TEST
		OS.execute("/bin/sh", args, output, read_stderr, open_console)
	#
	return output

## Runnable Execution will create a new seperate OS process/program/window for the command terminal.
## Returns the int pid of the new terminal process, if created and valid.
func perform_runnable_execution(order:String) -> int:
	var new_pid:int = -1# output and stderr from command run
	var args:Array = ["-c", order]
	# TODO IMPLEMENT OTHER OS TERMINALS
	if OS.get_name() == "Windows":
		args = ["/C", str("cd " + current_directory_path + " && " + order)]#
		new_pid = OS.create_process("CMD.exe", args, true)
	elif OS.get_name() == "Linux":
		new_pid = OS.create_process("/bin/sh", args, true)
	elif OS.get_name() == "Android":
		# TODO PLS implement Android give system perms
		new_pid = OS.create_process("/system/bin/sh", args, true)
	else:
		# TODO TEST IF THIS IS SUFFICIENT FOR OTHER SYSTEMS TODO TEST
		new_pid = OS.create_process("/bin/sh", args, true)
	#
	return new_pid

func get_pipe_io() -> Array:
	execution_mutex.lock()
	var lines:Array = []
	var pipe_read_attempts:int = 0
	var failed_stdio:bool=false
	var failed_stderr:bool=false
	
	while !pipe_stdio.eof_reached():
		var line = pipe_stdio.get_line()
		if line.is_empty(): 
			pipe_read_attempts += 1
			if pipe_read_attempts > max_pipe_stdio_read_attempts:
				failed_stdio = true
				break
		else: lines.append(line)
	
	pipe_read_attempts = 0
	while !pipe_stderr.eof_reached():
		var line = pipe_stderr.get_line()
		if line.is_empty(): 
			pipe_read_attempts += 1
			if pipe_read_attempts > max_pipe_stderr_read_attempts:
				failed_stderr = true
				break
		else: lines.append(line)
	
	#if failed_stdio and failed_stderr: stop_pipe()
	#print("COMMAND RUNNING: " + str(OS.is_process_running(pipe_pid)))
	#var lines_cleaned:Array = []
	if not lines.is_empty(): 
		#for line:String in lines:
			#lines_cleaned.append(line)
			#for rni in line.count(("\r\n" as String)):
				#lines_cleaned.append(" ")
				##print("SPECIAL CHARACTERS")
			#for ni in line.count(("\n" as String)):
				#lines_cleaned.append(" ")
				##print("SPECIAL CHARACTERS")
		received_pipe_data = true
		pipe_time = 0.0
	execution_mutex.unlock()
	return lines

func print_pipe_io() -> void: print_out(get_pipe_io())

func process(delta: float) -> void:# this can be called externally for threaded operations, you must call it, this function is not called on its own
	if not console_processing: return
	
	if refresh_during_process:
		refresh_delta += delta
		if refresh_delta >= refresh_rate: 
			refresh.call_deferred()
			refresh_delta = 0.0
	
	if uses_piped:
		print_pipe_io()
		# Read errors from stderr
		#while !stderr.eof_reached():
			#var line = stderr.get_line()
			#if line != "":
				#print("Error: ", line)
	
	if uses_threads and not uses_piped:
		if execution_thread == null: return
		
		if execution_thread.is_started():
			thread_time += 1.0 * delta
			if execution_thread.is_alive():
				if thread_time >= 3.0:
					if not long_process: 
						# there is no way to fix this, you can not cancel an execution that is unfinished without piping
						print_out([" ", "Process is running or may be stuck, close program to force close the operation.", " "])
						long_process = true
					# try uses_piped to avoid this situation
					# TODO make a better alternative for unpiped threaded executions
			else:
				var output:Array = execution_thread.wait_to_finish()
				finish_execution(output)
				return
	
	execution_mutex.lock()
	if uses_piped and console_processing and is_piping:
		if pipe_stdio is FileAccess and pipe_stdio.is_open():
			if not OS.is_process_running(pipe_pid): stop_pipe()
			else:
				pipe_time += 1.0 * delta
				#if received_pipe_data:
					#if pipe_time > 1.0: # pipe_time is reset to 0 every time received_pipe_data reads an io line, so this is 2.5s of empty console post-command
						# TEST this may not be sufficient for long-running processes such as servers
						#stop_pipe()
				
				if is_piping and pipe_time > 2.5:
					if not long_process: 
						# give app a console_cancel Input
						var keys_msg:String = ""
						for key_name:String in console_cancel_input_names:
							keys_msg = str(keys_msg + key_name + ", ")
						print_out([" ", "Process is running or may be stuck, use " + keys_msg + " or close program to force close the operation.", " "])
						long_process = true
			
		else: stop_pipe()
	
	if not is_piping: 
		if uses_threads:
			print_pipe_io()
			var output:Array = execution_thread.wait_to_finish()
			finish_execution(output)
		else: finish_execution([" ", "Process terminated.", " "])
	execution_mutex.unlock()


func force_stop_pipe() -> void:
	stop_pipe()
	if operating or console_processing: finish_execution([" ", "Killed pipe process.", " "])

func stop_pipe() -> void:
	if not uses_piped: return#??
	if not is_piping: return
	execution_mutex.lock()
	pipe_time = 0.0
	long_process = false
	if pipe_pid != -1: OS.kill(pipe_pid)
	pipe_pid = -1
	
	if pipe_stdio and pipe_stdio.is_open(): pipe_stdio.close()
	if pipe_stderr and pipe_stderr.is_open(): pipe_stderr.close()
	
	is_piping = false
	execution_mutex.unlock()

func finish_execution(output:Array) -> void:
	command_entered_print(output)
	console_processing = false
	if operating: 
		parser.did_operate = false
		operating = false
	refresh_delta = 0.0
	refresh()

func command_entered_print(output:Array, print_command:bool=true) -> void:
	chat(str(output), -1, true)
	if print_command and not uses_piped: print_out(command_history.get(command_history.size() - 1))
	print_out(output)
