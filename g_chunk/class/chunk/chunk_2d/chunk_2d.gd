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
