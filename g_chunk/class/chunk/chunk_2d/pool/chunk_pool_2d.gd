#|*******************************************************************
# chunk_pool_2d.gd
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
