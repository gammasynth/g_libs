extends Pool

class_name ChunkMapPool

var chunk_map : ChunkMap

func _init(_name:String="CHUNK_MAP_POOL", _key:Variant=_name, _chunk_map:ChunkMap=null) -> void:
	chunk_map = _chunk_map
	super(_name, _key)
	return
