extends Pool

class_name ChunkPool

var chunk: Chunk


func _init(_name:String="CHUNK_POOL", _key:Variant=_name, _chunk:Chunk=null) -> void:
	chunk = _chunk
	super(_name, _key)
	
