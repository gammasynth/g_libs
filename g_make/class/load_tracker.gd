class_name LoadTracker

signal finished

var progress_bar: ProgressBar
var event_text: RichTextLabel
var description_text: RichTextLabel

var additive_load:bool = true

var connected_workers:int = 0
var finished_workers:int = 0

#region Worker Connection Functions
func worker_started(total_workload:int, verbose:bool = false):
	if verbose: print("LoadTracker | total workers: " + str(connected_workers))
	setup_loader(total_workload)

func worker_worked(amt):
	handle_work_step(amt)

func worker_finished(verbose:bool = false):
	finished_workers += 1
	if verbose: print("LoadTracker | workers finished: " + str(finished_workers))
	while finished_workers > connected_workers:
		finished_workers -= 1
	if connected_workers > 0 and finished_workers == connected_workers:
		finished.emit()
#endregion


func handle_work_step(work_amount:int, verbose:bool = false) -> Error:
	await push_progress(work_amount)
	if verbose: print("LoadTracker | work step " + str(work_amount))
	await RenderingServer.frame_post_draw
	return OK


func setup_loader(final_value:int) -> Error:
	if not progress_bar.is_node_ready(): await progress_bar.ready
	if additive_load:
		#progress_bar.value = 0
		progress_bar.max_value += final_value# + 10000000
	else:
		progress_bar.value = 0
		progress_bar.max_value = final_value# + 10000000
	await RenderingServer.frame_post_draw
	return OK


func push_work_text(work_text:String, work_desc:String="") -> Error:
	event_text.text = work_text
	description_text.text = work_desc
	await RenderingServer.frame_post_draw
	return OK



func push_progress(value:int) -> Error:
	progress_bar.value += value
	await RenderingServer.frame_post_draw
	return OK
