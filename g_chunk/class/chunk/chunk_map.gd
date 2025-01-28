extends Database

class_name ChunkMap

var chunks: Pool: get = _get_chunks, set = _set_chunks

func _get_chunks(): return get_fancy_pool("chunks", "chunk_map_pool", [self], self)
func _set_chunks(_chunks): return set_pool("chunks", _chunks)

func _init(_name:String="CHUNK_MAP", _key:Variant=_name) -> void:
	super(_name, _key)
	return
