extends Database

class_name Chunk

var chunk_map: ChunkMap


func _init(_name:String="OBJ", _key:Variant=_name, _chunk_map:ChunkMap=null) -> void:
	super(_name, _key)
	chunk_map = _chunk_map
