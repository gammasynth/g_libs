#|*******************************************************************
# pool.gd
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




extends RefData
## Pool is currently built on top of [RefData] as a means of ease when recursing many [RefData]s within each other on an arbitrary keying scheme.
## @experimental
##
## A Pool is a [RefData], but the functionality Pool implements is intended for support of managing internal Pools, which could also be called "subpools".
## [br][br]
## The primary feature that the Pool class implements is the instantiation of a new Pool or other classtype upon attempting to retrieve a key value when the key value does not already exist.
## [br][br]
## Essentially, internal pools can be made and/or already existing and retrieved using the [method get_pool] method. [br]
## The [method get_pool] method will call the [method make_new_pool] method if the at_key argument is not grabbable with [method grab].
## [br][br]
## When pooling internal pools that are of a classtype other Pool, but extending from Pool, a pool_class_name can be used to pull a class script that may be loaded by the g_libs/pools built-in [Registry] (if it is functional at this stage of development) using the [method ClassNameDB.try_instantiate] method.
## [br][br]
## The method [method get_fancy_pool] can be used be used to pop the value of at_key to the front of the params [Array], twice, so that if a new subpool is a type of [RefInstance], the at_key value will be applied to the new instance's [member RefInstance.name] and [member RefInstance.key], or whatever other first two parameters that new class uses in it's [method RefInstance._init] constructor method.
## [br][br]
## When operating across possibly multiple at_key values, multple subpools in one function call, one can use [method get_pools] or [method get_fancy_pools], both of which handle an at_keys [Array] instead of a singular at_key [Variant].
class_name Pool

# What is a Pool

#var pool: Callable = get_fancy_pool
#var pools: Callable = get_fancy_pools

## The method [method get_fancy_pools] will call [method get_fancy_pool] for every value within [param at_keys].
func get_fancy_pools(at_keys:Array[Variant], pool_class_name:String="pool", extra_pool_parameters:Array=[], pool_parent_instance:RefInstance=null) -> Array[Pool]:
	var pools : Array[Pool] = []
	for at_key in at_keys:
		var pool = get_fancy_pool(at_key, pool_class_name, extra_pool_parameters, pool_parent_instance)
		pools.append(pool)
	return pools

## The method [method get_fancy_pool] is a [method get_pool], which will append the [param extra_pool_parameters] to the params for the [method get_pool] which consists of two entries of [param at_key] at its beginning. [br][br]
## At this time, the method will first try to return [method Dictionary.get] from [member data], if [method Dictionary.has], but there is no mutex locking.
## @experimental
func get_fancy_pool(at_key:Variant, pool_class_name:String="pool", extra_pool_parameters:Array=[], pool_parent_instance:RefInstance=null) -> Pool:
	if data.has(at_key): return data.get(at_key)
	var fancy = at_key; 
	var params = [fancy, fancy]
	params.append_array(extra_pool_parameters)
	return get_pool(fancy, pool_class_name, params, pool_parent_instance)

## The [method make_new_pool] method is intended to be called internally via the [method get_pool] function. [br][br]
## The new_pool will first attempt to be made using [method ClassNameDB.try_instantiate] using the [param pool_class_name] and [param pool_parameters] as arguments. [br][br]
## The new_pool will default to a [method Pool.new] if it can not be instantiated prior. [br][br]
## If a [param pool_parent_instance] is not null, the new_pool will apply it to the member [member RefInstance.parent_instance].
func make_new_pool(at_key:Variant, pool_class_name:String="pool", pool_parameters:Array=[], pool_parent_instance:RefInstance=null) -> Pool:
	if pool_parameters.size() == 0 and at_key is String: pool_parameters.append(at_key)
	var new_pool = ClassNameDB.try_instantiate(pool_class_name, pool_parameters)
	
	if not new_pool: new_pool = Pool.new()
	
	if pool_parent_instance: new_pool.parent_instance = pool_parent_instance
	chatd("new pool: " + str(at_key), -1, true)
	return new_pool

## The method [method get_pool] is a get or instantiate/set/get when nil function upon [member data]. [br][br]
## The method [method get_pool] is a [method RefData.grab] which will instead [method set_pool] with the result of [method make_new_pool] if the result of [method has] with [param at_key] is false.
func get_pool(at_key:Variant, pool_class_name:String="pool", params:Array=[], parent:RefInstance=null) -> Pool:
	if at_key is Pool: return at_key# for validating that a value is already "pool", and not a key for finding that pool.
	if not has(at_key): return set_pool(at_key, make_new_pool(at_key, pool_class_name, params, parent))
	return grab(at_key)

## The method [method get_pools] will call [method get_pool] for every value within [param at_keys].
func get_pools(at_keys:Array[Variant]) -> Array[Pool]:
	var pools : Array[Pool] = []
	for at_key in at_keys:
		pools.append(get_pool(at_key))
	return pools

## The method [method set_pool] will [method add] using the [param pool] and [param at_key], and then return a [method grab] of [param at_key].
func set_pool(at_key:Variant, pool: Pool = Pool.new()) -> Pool:
	add(pool, at_key, true)
	return grab(at_key)
