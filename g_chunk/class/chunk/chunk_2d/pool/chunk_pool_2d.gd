extends ChunkPool

class_name ChunkPool2D

var position_offset : Vector2


func _init(_name:String="CHUNK_POOL_2D", _key:Variant=_name, _chunk:Chunk2D=null, _premax_list:bool=true) -> void:
	super(_name, _key, _chunk)
	
	#if premax_list and chunk:
		#var size : Vector2 = chunk.size
		#var op: Callable = func(tile:Vector2i):
			#var pos: Vector2 = Vector2(tile)
			#if not chunk.is_position_in_chunk(pos): return
			#add(0, pos)
		#TileMath2D.operate_in_square(size.x, size.y, op, chunk.position)
	
	return
