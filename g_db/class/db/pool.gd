#|*******************************************************************
# pool.gd
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

extends RefData
class_name Pool

# What is a Pool

#var pool: Callable = get_fancy_pool
#var pools: Callable = get_fancy_pools

func get_fancy_pools(at_keys:Array[Variant], pool_class_name:String="pool", extra_pool_parameters:Array=[], pool_parent_instance:RefInstance=null) -> Array[Pool]:
	var pools : Array[Pool] = []
	for at_key in at_keys:
		var pool = get_fancy_pool(at_key, pool_class_name, extra_pool_parameters, pool_parent_instance)
		pools.append(pool)
	return pools

func get_fancy_pool(at_key:Variant, pool_class_name:String="pool", extra_pool_parameters:Array=[], pool_parent_instance:RefInstance=null) -> Pool:
	if data.has(at_key): return data.get(at_key)
	var fancy = at_key; 
	var params = [fancy, fancy]
	params.append_array(extra_pool_parameters)
	return get_pool(fancy, pool_class_name, params, pool_parent_instance)


func make_new_pool(at_key:Variant, pool_class_name:String="pool", pool_parameters:Array=[], pool_parent_instance:RefInstance=null) -> Pool:
	if pool_parameters.size() == 0 and at_key is String: pool_parameters.append(at_key)
	var new_pool = ClassNameDB.try_instantiate(pool_class_name, pool_parameters)
	
	if not new_pool: new_pool = Pool.new()
	
	if pool_parent_instance: new_pool.parent_instance = pool_parent_instance
	chatd("new pool: " + str(at_key), -1, true)
	return new_pool


func get_pool(at_key:Variant, pool_class_name:String="pool", params:Array=[], parent:RefInstance=null) -> Pool:
	if at_key is Pool: return at_key# for validating that a value is already "pool", and not a key for finding that pool.
	if not has(at_key): return set_pool(at_key, make_new_pool(at_key, pool_class_name, params, parent))
	return grab(at_key)

func get_pools(at_keys:Array[Variant]) -> Array[Pool]:
	var pools : Array[Pool] = []
	for at_key in at_keys:
		pools.append(get_pool(at_key))
	return pools


func set_pool(at_key:Variant, pool: Pool = Pool.new()) -> Pool:
	add(pool, at_key, true)
	return grab(at_key)
