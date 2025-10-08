#|*******************************************************************
# chunk_2d.gd
#*******************************************************************
# This file is part of g_libs. 
# g_libs is an open-source software codebase.
# g_libs is licensed under the MIT license.
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

extends Chunk

class_name Chunk2D

var canvas_item: CanvasItem:
	get: 
		if not canvas_item:
			if not chunk_map.canvas_item: return null
			var canvas = await Make.unique_canvas_item_child(chunk_map.canvas_item, self)
			canvas_item = canvas
		return canvas_item

var position: Vector2i

var size: Vector2i:
	get: return chunk_map.chunk_size


var chunk_physics_thread: Thread = Thread.new()


func position_to_name() -> String: return str("Chunk" + str(position))

func _get_database_name(_dn) -> String: return position_to_name()

func _init(_position:Vector2i=Vector2i.ZERO, _chunk_map:ChunkMap2D=null) -> void:
	position = _position
	super(position_to_name(), position, _chunk_map)
	
	if debug: draw_chunk_borders()
	return


func is_position_in_chunk(at_position:Vector2) -> bool:
	if TileMath2D.global_to_grid_pos(at_position, size) == position: return true
	return false



func draw_chunk_borders():
	if not canvas_item:
		warn("cant draw chunk, no canvas item"); return
	
	var spr: Node2D = Node2D.new()
	canvas_item.add_child(spr)
	if not spr.is_node_ready(): await spr.ready
	
	spr.z_index = 100
	var pos:Vector2 = position * size
	var offset:Vector2 = size
	pos = pos - (offset * 0.5)
	
	var rect = Rect2(pos, (size))
	#var font = preload("res://core/assets/font/Fraunces_9pt_Soft-Thin.ttf")
	var font = ThemeDB.fallback_font
	var f : Callable = func():
		spr.draw_rect(rect, Color.CYAN, false)
		var p = Vector2i(pos) + Vector2i(1,1)
		spr.draw_string(font, p, str(position), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.CYAN)
		#p += Vector2i(0,8)
		#var e: String = str("e: " + str())
		#spr.draw_string(font, p, e, 0, -1, 8)
	spr.draw.connect(f)
	spr.queue_redraw()
