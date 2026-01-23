#|*******************************************************************
# chunk_map_pool_2d.gd
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



extends ChunkMapPool

class_name ChunkMapPool2D

var access_chunks:bool=true
var contains_pools:bool = true

var last_scanned_chunk: Chunk2D = null

var index_size:int = 0

func _init(_name:String="CHUNK_MAP_POOL_2D", _key:Variant=_name, _chunk_map:ChunkMap2D=null, _access_chunks:bool=true, _contains_pools:bool=true) -> void:
	super(_name, _key, _chunk_map)
	access_chunks = _access_chunks
	contains_pools = _contains_pools
	return



func get_pool_name(pool_name_suffix:String="") -> String:
	return str(parent_instance.name + "/" + name + pool_name_suffix)


func _data_size() -> int: return index_size

func _keys(same_keys:bool=false, pool_name_suffix:String="") -> Array:
	if pool_name_suffix.length() > 0 and not pool_name_suffix.begins_with("/"): pool_name_suffix = str("/"+pool_name_suffix)
	var pool_name:String = get_pool_name(pool_name_suffix)
	if access_chunks:
		if contains_pools:
			var chunk_pools: Array[Pool] = chunk_map.get_chunk_pools_from_chunks(pool_name)#, parent_instance)
			var ks : Array = []
			for p in chunk_pools:
				for k in p.keys():
					ks.append(k)
			return ks
		else:
			for chunk_pos:Vector2 in chunk_map.chunks.data:
				var chunk:Chunk2D = chunk_map.chunks.data.get(chunk_pos)
				if chunk.has(pool_name): return [pool_name]
	return data.keys()

func _clear(pool_name_suffix:String="") -> void:
	if pool_name_suffix.length() > 0 and not pool_name_suffix.begins_with("/"): pool_name_suffix = str("/"+pool_name_suffix)
	var pool_name:String = str(parent_instance.name + "/" + name + pool_name_suffix)
	if access_chunks:
		if contains_pools:
			var chunk_pools: Array[Pool] = chunk_map.get_chunk_pools_from_chunks(pool_name)#, parent_instance)
			for pool in chunk_pools:
				pool.clear()
			index_size = 0
			return
		else:
			for chunk_pos:Vector2 in chunk_map.chunks.data:
				var chunk:Chunk2D = chunk_map.chunks.data.get(chunk_pos)
				if chunk.has(pool_name): chunk.erase(pool_name)
			index_size = 0
			return
	
	data.clear()
	index_size = 0
	return


func _add(value:Variant, at_key:Variant=null, force:bool=false, verbose:bool=true, pool_name_suffix:String="") -> bool:
	var is_ref: bool = value is RefInstance
	var is_node_ref: bool = value is Object and value.has_method("get_database")
	
	
	if is_ref: 
		if not at_key: at_key = value.key
		if not value.parent_instance: value.parent_instance = self
	if is_node_ref: 
		if not at_key: at_key = value
		if not value.db.parent_instance: value.db.parent_instance = self
	
	if at_key == null: warn(str("can't add null-keyed value: " + str(value))); return false
	if at_key is Vector2i: at_key = Vector2(at_key)
	if at_key is not Vector2: 
		warn(str("tried to add non-vector2 key to chunk pool at key: " + str(at_key)))
		return false
	
	if verbose and not deep_debug: verbose = false
	if verbose: 
		if is_ref or is_node_ref: 
			var obj_name:String = Info.get_script_name(value)
			chatd(str("adding " + obj_name + "(" + str(value.name) + ") at key: " + str(at_key)))
		else: chatd(str("adding variant at key: " + str(at_key)))
	
	
	var pos: Vector2 = at_key
	if pool_name_suffix.length() > 0 and not pool_name_suffix.begins_with("/"): pool_name_suffix = str("/"+pool_name_suffix)
	if access_chunks:
		if contains_pools:
			var chunk_pool: ChunkPool2D = chunk_map.get_chunk_pool_from_global_position(str(parent_instance.name + "/" + name + pool_name_suffix), pos)#, parent_instance)
			if chunk_pool.has(pos):
				warnd(str("data already has key! can't add: " + str(at_key))); 
				if not force: return false
			
			if chunk_pool.add(value, at_key, force, verbose): 
				if value: index_size += 1; 
				return true
			
		else:
			var chunk: Chunk2D = chunk_map.get_chunk_from_global_position(pos)
			if chunk.has(str(parent_instance.name + "/" + name + pool_name_suffix)): 
				warnd(str("data already has key! can't add: " + str(at_key))); 
				if not force: return false
			if chunk.add(value, str(parent_instance.name + "/" + name + pool_name_suffix), force, verbose):
				if value: index_size += 1; 
				return true
	
	
	if has(at_key): 
		warnd(str("data already has key! can't add: " + str(at_key))); 
		if not force: return false
	
	data[at_key] = value
	#data.get_or_add(at_key, value)
	if value: index_size += 1
	
	if is_ref:
		if not value.parent_instance: value.parent_instance = self
	if is_node_ref:
		if not value.db.parent_instance: value.db.parent_instance = self
	
	if verbose: chatd(str("added: " + str(at_key) + " to data."))
	return true


func _has(key_entry:Variant, pool_name_suffix:String="") -> bool: 
	if key_entry is Vector2i: key_entry = Vector2(key_entry)
	if key_entry is not Vector2: return false
	
	if not access_chunks: return data.has(key_entry)
	
	if pool_name_suffix.length() > 0 and not pool_name_suffix.begins_with("/"): pool_name_suffix = str("/"+pool_name_suffix)
	
	if key_entry is Vector2:
		if contains_pools:
			var chunk_pool: ChunkPool2D = chunk_map.get_chunk_pool_from_global_position(str(parent_instance.name + "/" + name + pool_name_suffix), key_entry)#, parent_instance)
			return chunk_pool.has(key_entry)
		else:
			var chunk: Chunk2D = chunk_map.get_chunk_from_global_position(key_entry)
			
			return chunk.has(str(parent_instance.name + "/" + name + pool_name_suffix))
	
	return false

func _grab(at_key:Variant, pool_name_suffix:String="") -> Variant:
	if at_key is Vector2i: at_key = Vector2(at_key)
	if at_key is not Vector2: return null
	if pool_name_suffix.length() > 0 and not pool_name_suffix.begins_with("/"): pool_name_suffix = str("/"+pool_name_suffix)
	if access_chunks and at_key is Vector2:
		if contains_pools:
			var chunk_pool: ChunkPool2D = chunk_map.get_chunk_pool_from_global_position(str(parent_instance.name + "/" + name + pool_name_suffix), at_key)#, parent_instance)
			if chunk_pool.has(at_key):
				return chunk_pool.grab(at_key)
		else:
			var chunk: Chunk2D = chunk_map.get_chunk_from_global_position(at_key)
			if not chunk.has(str(parent_instance.name + "/" + name + pool_name_suffix)): return null
			return chunk.grab(str(parent_instance.name + "/" + name + pool_name_suffix))
	return find_data(at_key)

func _erase(at_key:Variant, pool_name_suffix:String="") -> bool:
	if at_key is Vector2i: at_key = Vector2(at_key)
	if at_key is not Vector2: return false
	
	if pool_name_suffix.length() > 0 and not pool_name_suffix.begins_with("/"): pool_name_suffix = str("/"+pool_name_suffix)
	
	var pool_name: String = str(parent_instance.name + "/" + name + pool_name_suffix)
	
	if access_chunks and at_key is Vector2:
		if contains_pools:
			var chunk_pool: ChunkPool2D = chunk_map.get_chunk_pool_from_global_position(pool_name, at_key)#, parent_instance)
			if chunk_pool.has(at_key):
				if chunk_pool.erase(at_key):
					index_size -= 1
					return true
			return false
		else:
			var chunk: Chunk2D = chunk_map.get_chunk_from_global_position(at_key)
			if not chunk.has(pool_name): return false
			if chunk.erase(pool_name):
				index_size -= 1
				return true
	
	if not data.has(at_key): return false
	if data.erase(at_key):
		index_size -= 1
		return true
	return false


func scan_chunks(pool_name:String = name, max_scans_in_chunk:int=0, in_chunks:Array = chunk_map.chunks.data.values(), max_scan_chunks:int = 0, scan_condition:Variant = null, reset:bool=false) -> Dictionary:
	if reset:
		last_scanned_chunk = null
	
	if not access_chunks:
		warn("scan chunks called on pool without access_chunks flag"); return {}
	
	pool_name = str(parent_instance.name + "/" + pool_name)
	
	var past_last_scanned_chunk: bool = false
	if not last_scanned_chunk or not in_chunks.has(last_scanned_chunk): past_last_scanned_chunk = true
	
	if not past_last_scanned_chunk and in_chunks.back() == last_scanned_chunk: past_last_scanned_chunk = true
	
	
	var scan : Dictionary = {}
	
	
	for idx in in_chunks.size():
		var chunk:Chunk2D = in_chunks[idx]
		
		if not past_last_scanned_chunk:
			if chunk == last_scanned_chunk:
				past_last_scanned_chunk = true; continue
			else: continue
		
		last_scanned_chunk = chunk
		
		
		if contains_pools:
			var scan_idx: int = 0
			var pool : ChunkPool2D = chunk_map.get_chunk_pool_from_chunk(pool_name, chunk)#, parent_instance)
			for k in pool.data:
				var v = pool.grab(k)
				if v: 
					if scan_condition is Callable:
						if scan_condition.call(v) == true:
							scan[k] = v
					else: scan[k] = v
				scan_idx += 1
				if max_scans_in_chunk > 0 and scan_idx >= max_scans_in_chunk:
					break
		else:
			if chunk.has(pool_name):
				var v = chunk.grab(pool_name)
				if v:
					if scan_condition is Callable:
						if scan_condition.call(v) == true:
							scan[pool_name] = v
					else: scan[pool_name] = v
		
		if max_scan_chunks > 0 and idx >= max_scan_chunks: break
	
	return scan
