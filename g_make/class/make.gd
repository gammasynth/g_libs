#|*******************************************************************
# make.gd
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


class_name Make



static func child(node:Node, parent:Node, await_ready:bool=true) -> Node:
	if parent: 
		parent.add_child(node, true)
		if await_ready and not node.is_node_ready(): await node.ready
		#if parent.has_method("get_database") and node.has_method("get_database"):
			#var p: Database = parent.db
			#var c: Database = node.db
			#p.add(c, c.name)
		return node
	push_error("no parent for node: " + str(node))
	node.queue_free()
	return null



static func unique_canvas_item_child(canvas_item:CanvasItem, for_database:Database=null, await_ready:bool=false) -> CanvasItem:
	if for_database: for_database.chat("making unique child canvas item...")
	var canvas_script:GDScript = canvas_item.get_script()
	var canvas: CanvasItem
	if not canvas_script: canvas = ClassDB.instantiate(canvas_item.get_class())
	else: canvas = canvas_script.new()
	
	var n: String = ""
	if for_database:
		n = for_database.name
		n = str(n + "_")
	
	canvas.name = str(n+"canvas")
	
	if await_ready:
		await Make.child(canvas, canvas_item)
	else:
		canvas_item.add_child(canvas)
	
	return canvas


static func text_label(label_text:String, label_name:String="RichTextLabel", parent:Node=null, fit_content:bool=true, custom_minimum_size:Vector2=Vector2.ZERO, word_wrap:bool=false) -> RichTextLabel:
	var label : RichTextLabel = RichTextLabel.new()
	label.name = label_name
	
	label = await child(label, parent)
	
	label.bbcode_enabled = true
	label.fit_content = fit_content
	label.custom_minimum_size = custom_minimum_size
	if not word_wrap: label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	label.text = label_text
	
	return label

enum FADE_TYPES {OUT, IN, OUT_AND_IN, IN_AND_OUT}

static func fade(node:CanvasItem, duration:float = 1.0, disable_controls:bool=true, type:FADE_TYPES=FADE_TYPES.OUT) -> Tween:
	match type:
		FADE_TYPES.OUT:
			return fade_out(node, duration, disable_controls)
		FADE_TYPES.IN:
			return fade_in(node, duration, disable_controls)
		FADE_TYPES.OUT_AND_IN:
			var tween:Tween = fade_out(node, duration, disable_controls)
			tween.tween_callback(
				fade_in.bind(node, duration, disable_controls)
				).set_delay(duration)
		FADE_TYPES.IN_AND_OUT:
			var tween:Tween = fade_in(node, duration, disable_controls)
			tween.tween_callback(
				fade_out.bind(node, duration, disable_controls)
				).set_delay(duration)
			return tween
	return null

static func fade_out(node:CanvasItem, duration:float = 1.0, disable_controls:bool=true) -> Tween:
	return do_fade(node, Color(0.0, 0.0, 0.0, 0.0), duration, disable_controls)

static func fade_in(node:CanvasItem, duration:float = 1.0, disable_controls:bool=true) -> Tween:
	return do_fade(node, Color(1.0, 1.0, 1.0, 1.0), duration, disable_controls)


static func do_fade(node:CanvasItem, to_color:Color=Color(0.0, 0.0, 0.0, 0.0), duration:float = 1.0, disable_controls:bool=true, trans:Tween.TransitionType=Tween.TRANS_BACK, ease:Tween.EaseType=Tween.EASE_OUT) -> Tween:
	if not node or not is_instance_valid(node): push_error("Make.fade_out(): node is already null or invalid instance!"); return null
	
	if disable_controls: disable_control(node)
	
	var tween: Tween = node.create_tween().set_parallel()
	tween.tween_property(node, "modulate", to_color, duration).set_trans(trans).set_ease(ease)
	return tween

static func fade_delete(node:CanvasItem, duration:float = 1.0, disable_controls:bool=true) -> void:
	if not node or not is_instance_valid(node): return push_error("Make.fade_delete(): node is already null or invalid instance!")
	
	var tween:Tween = fade(node, duration, disable_controls)
	tween.tween_callback(node.queue_free).set_delay(duration)




static func disable_control(node:Control, recursive:bool=true) -> void:
	if not node or not is_instance_valid(node): return push_error("disable_control(): node is null or invalid instance!")
	
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE; node.focus_mode = Control.FOCUS_NONE
	
	if recursive:
		var kids := node.get_children()
		for kid in kids: if kid and is_instance_valid(kid) and kid is Control: disable_control(kid)

static func clear_children(node:Node, excluding_children:Array[Node]=[]) -> void:
	for kid in node.get_children():
		if excluding_children.has(kid): continue
		node.remove_child(kid)
		kid.queue_free()
	return
