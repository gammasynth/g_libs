#|*******************************************************************
# load_tracker.gd
#*******************************************************************
# This file is part of g_libs.
# 
# g_libs is an open-source software library.
# g_libs is licensed under the MIT license.
# 
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



class_name LoadTracker

signal work_event(new_work_text:String, new_work_desc:String)
signal progressed(value:int)
signal finished

var parent_loader:LoadTracker=null
var subloaders:Array[LoadTracker]=[]

var loading_screen:Control=null

var progress_bar: ProgressBar=null
var event_text: RichTextLabel=null
var description_text: RichTextLabel=null

var additive_load:bool = false

var connected_workers:int = 0
var started_workers:int = 0
var finished_workers:int = 0

var final_value:int = 1
var current_value:int = 0


func add_subloader(subloader:LoadTracker)-> void:
	subloader.parent_loader=self
	if not subloaders.has(subloader): subloaders.append(subloader)
	connected_workers += 1
	
	subloader.progressed.connect(push_progress)
	subloader.work_event.connect(push_work_text)
	subloader.finished.connect(worker_finished)

#region Worker Connection Functions
func worker_started(): started_workers += 1

func worker_worked(amt):
	handle_work_step(amt)

func worker_finished(verbose:bool = false):
	finished_workers += 1
	if verbose: print("LoadTracker | workers finished: " + str(finished_workers))
	#while finished_workers > connected_workers:
		#finished_workers -= 1
	try_finish()
#endregion


func try_finish() -> void:
	if connected_workers > 0:
		if finished_workers == connected_workers: finished.emit()
	else:
		if current_value >= final_value - 1: finish()
		else:
			var diff:int = abs(final_value - current_value)
		#if diff > 1:
			#pass
			##print("cant finish loader with finished workers! value: " + str(current_value) + " max: " + str(final_value))
		#else:
			print("Invalid loading balance, LoadTracker off on finish by " + str(diff) + " bytes!")
			finish()

func finish() -> void:
	current_value = final_value + 1
	await fix_progress_bar()
	if RenderingServer.render_loop_enabled: await RenderingServer.frame_post_draw
	finished.emit()

func handle_work_step(work_amount:int, verbose:bool = false) -> Error:
	await push_progress(work_amount)
	if verbose: print("LoadTracker | work step " + str(work_amount))
	return OK

#func modify_final_value_due_to_subloader(new_subloader_final_value:int, old_subloader_final_value:int) -> void:
	#var old_final_value:int = final_value
	#final_value -= old_subloader_final_value
	#final_value += new_subloader_final_value
	#if parent_loader: parent_loader.modify_final_value_due_to_subloader(final_value, old_final_value)
	#await fix_progress_bar()
#
#func modify_current_value_due_to_subloader(new_subloader_current_value:int, old_subloader_current_value:int) -> void:
	#var old_current_value:int = current_value
	#current_value -= old_subloader_current_value
	#current_value += new_subloader_current_value
	#if parent_loader: parent_loader.modify_current_value_due_to_subloader(current_value, old_current_value)
	#await fix_progress_bar()
#
#func modify_final_value(new_final_value:int) -> void:
	#if parent_loader: parent_loader.modify_final_value_due_to_subloader(new_final_value, final_value)
	#final_value = new_final_value
	#await fix_progress_bar()

func setup_subloader(new_subloader_final_value:int):
	final_value += new_subloader_final_value
	if parent_loader: parent_loader.setup_subloader(new_subloader_final_value)
	
	await fix_progress_bar()

func setup_loader(new_final_value:int) -> Error:
	final_value += new_final_value
	if parent_loader: parent_loader.setup_subloader(new_final_value)
	await fix_progress_bar()
	return OK

func fix_progress_bar(at:int=current_value, at_max:int=final_value, fix:bool=false):
	if loading_screen:
		#if not progress_bar.is_node_ready(): await progress_bar.ready
		#if additive_load:
			##progress_bar.value = 0
			#progress_bar.max_value += float(at_max)# + 10000000
			#progress_bar.value += float(at)
		#else:
		progress_bar.value = float(at)
		progress_bar.max_value = float(at_max)# + 10000000
		if RenderingServer.render_loop_enabled: await RenderingServer.frame_post_draw
		if fix and progress_bar and progress_bar.indeterminate: 
			progress_bar.indeterminate = false
			if RenderingServer.render_loop_enabled: await RenderingServer.frame_post_draw
	return


func push_work_text(work_text:String, work_desc:String="") -> Error:
	work_event.emit(work_text, work_desc)
	if loading_screen:
		event_text.text = work_text
		description_text.text = work_desc
		if RenderingServer.render_loop_enabled: await RenderingServer.frame_post_draw
	return OK



func push_progress(value:int) -> Error:
	current_value += value
	progressed.emit(value)
	await fix_progress_bar(current_value, final_value, true)
	#try_finish()
	return OK
