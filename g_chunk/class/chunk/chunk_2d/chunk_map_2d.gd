#|*******************************************************************
# chunk_map_2d.gd
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

extends ChunkMap

class_name ChunkMap2D

func _get_chunks() -> ChunkMapPool2D: 
	if chunks: return chunks
	return get_fancy_pool("chunks", "chunk_map_pool_2d", [self, false], self)
func _set_chunks(_chunks:ChunkMapPool2D) -> ChunkMapPool2D: return set_pool("chunks", _chunks)

var chunk_size: Vector2i
var canvas_item: CanvasItem

func _init(_name:String="CHUNK_MAP_2D", _key:Variant=_name, _chunk_size:Vector2i=Vector2i.ONE, _canvas_item:CanvasItem=null) -> void:
	super(_name, _key)
	chunk_size = _chunk_size
	canvas_item = _canvas_item
	return

func get_chunk_from_global_position(position:Vector2) -> Chunk2D:
	var chunk_pos:Vector2i = TileMath2D.global_to_grid_pos(position, chunk_size)
	var chunk: Chunk2D
	if chunks.has(chunk_pos):
		chunk = chunks.grab(chunk_pos)
	else:
		chunk = _make_new_chunk(chunk_pos)
	return chunk

func get_chunk_from_grid_position(chunk_pos:Vector2) -> Chunk2D:
	var chunk: Chunk2D
	if chunks.has(chunk_pos):
		chunk = chunks.grab(chunk_pos)
	else:
		chunk = _make_new_chunk(chunk_pos)
	return chunk

func _make_new_chunk(chunk_pos:Vector2i) -> Chunk2D:
	chat(str("Creating new Chunk2D at position: " + str(chunk_pos)), Text.COLORS.yellow)
	var chunk = Chunk2D.new(chunk_pos, self)
	chunks.add(chunk, chunk_pos)
	return chunk

func erase_chunk(chunk:Chunk2D) -> void:
	var chunk_pos: Vector2i = chunk.position
	var spr = chunk.canvas_item
	if spr and is_instance_valid(spr):
		spr.queue_free()
	if chunks.has(chunk_pos): chunks.erase(chunk_pos)



func get_chunk_pool_from_global_position(pool_name: String, position:Vector2, pool_parent:RefInstance=null) -> Pool:
	var chunk: Chunk2D = get_chunk_from_global_position(position)
	if not pool_parent: pool_parent = chunk
	var chunk_pool : ChunkPool2D = chunk.get_fancy_pool(pool_name, "chunk_pool_2d", [chunk], pool_parent)
	return chunk_pool

func get_chunk_pool_from_chunk(pool_name: String, chunk: Chunk2D, pool_parent:RefInstance=null) -> Pool:
	if not pool_parent: pool_parent = chunk
	var chunk_pool : ChunkPool2D = chunk.get_fancy_pool(pool_name, "chunk_pool_2d", [chunk], pool_parent)
	return chunk_pool

func get_chunk_pools_from_chunks(pool_name: String, pool_parent:RefInstance=null, from_chunks: Array=chunks.data.values()) -> Array[Pool]:
	var pools : Array[Pool] = []
	for chunk:Chunk2D in from_chunks:
		var p = pool_parent
		if not p: p = chunk
		var chunk_pool : ChunkPool2D = get_chunk_pool_from_chunk(pool_name, chunk, p)
		pools.append(chunk_pool)
	return pools
