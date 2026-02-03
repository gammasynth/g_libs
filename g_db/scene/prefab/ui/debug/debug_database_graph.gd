#|*******************************************************************
# debug_database_graph.gd
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




extends MarginContainer
class_name DebugDatabaseGraph

signal set_parent_ref

var debug_database: DebugDatabase = null:
	set(o):
		debug_database = o
		set_parent_ref.emit()

var database:Variant = null


@onready var graph_info: PopupMenu = $"VBox/MenuBar/Graph Info"


@onready var scroll_container: ScrollContainer = $VBox/HSplit/ScrollContainer
@onready var control_tree: ControlTree = $VBox/HSplit/ScrollContainer/DebugDatabaseTree


@onready var vpc: SubViewportContainer = $VBox/HSplit/VPC
@onready var vp: SubViewport = $VBox/HSplit/VPC/VP

@onready var canvas: Node2D = $VBox/HSplit/VPC/VP/Canvas

@onready var camera_2d: Camera2D = $VBox/HSplit/VPC/VP/Canvas/Camera2D
@export var cam_speed : float = 100.0

var line_size: int = 4
var details:bool = true

var all_instance_keys: Array = []

func _process(delta: float) -> void:
	
	if not debug_database: return
	
	if not debug_database.get_parent().has_focus(): return
	
	if not visible: return
	
	if not vpc.has_focus(): return
	
	var input: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var s: float = cam_speed
	if Input.is_action_pressed("shift"): s *= 10
	if Input.is_action_pressed("control"): s *= 10
	camera_2d.global_position += input * s * delta
	
	var zoom : Vector2 = Vector2.ZERO
	var zoom_amount: Vector2 = Vector2(0.25, 0.25)#; if shifting: zoom_amount = Vector2(1.1, 1.1)
	if Input.is_action_just_pressed("scroll_up"):
		zoom = camera_2d.zoom + zoom_amount
	if Input.is_action_just_pressed("scroll_down"):
		zoom = camera_2d.zoom - zoom_amount
	
	if zoom != Vector2.ZERO:
		zoom = zoom.clampf(0.25, 1)
		camera_2d.zoom = zoom
	


func new_child_instance(parent_inst: InstanceVisualizerControl, new_inst: InstanceVisualizerControl):
	var real_line_size: int = line_size
	if not details: real_line_size = 1
	
	var y_offset: float = float(parent_inst.subinstances.size()) * (real_line_size * 2)
	y_offset += 1.0
	
	var pos = parent_inst.global_position
	pos.x += parent_inst.margin.size.x
	if details: pos.y += parent_inst.margin.size.y * 0.5
	else: pos.y += parent_inst.margin.size.y * 0.75
	pos.y += -y_offset
	
	var new_pos = new_inst.global_position
	new_pos.x += new_inst.margin.size.x * 0.5
	
	var mid_pos = Vector2(new_pos.x, pos.y)
	
	var line1:Line2D = await Make.child(Line2D.new(), canvas)
	
	line1.width = real_line_size
	line1.add_point(pos)
	line1.add_point(mid_pos)
	
	var line2: Line2D = await Make.child(Line2D.new(), canvas)
	
	line2.width = real_line_size
	line2.add_point(mid_pos)
	line2.add_point(new_pos)
	
	return OK

func draw_database_tree() -> Error:
	
	if not database:
		print("error: " + name + "no database! deleting node...")
		queue_free()
		return OK
	
	#Cast.clear_children(control)
	Make.clear_children(canvas, [camera_2d])
	
	all_instance_keys.clear()
	
	var main_inst: InstanceVisualizerControl = await InstanceVisualizerControl.instance_visualizer(database, true, canvas, self, Vector2(50, 100))
	
	control_tree.update_tree(main_inst)
	
	return OK


func _on_graph_info_index_pressed(_index: int) -> void:
	pass


func _on_graph_info_id_pressed(id: int) -> void:
	var txt:String = graph_info.get_item_text(id)
	match txt:
		"details":
			details = !details
			graph_info.set_item_checked(id, details)
