#|*******************************************************************
# registry_entry.gd
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

extends Database

class_name RegistryEntry


static func make_entry(with_entry_name:String) -> RegistryEntry:
	return RegistryEntry.new(with_entry_name)


func setup_entry():
	return _setup_entry()

func _setup_entry():
	pass


func asset_registered(file_name:String) -> Error:
	chatd("RegistryEntry: " + name + " | " + " asset registered: " + file_name)
	return OK

func register_asset(file_name:String, asset:Variant) -> Error:
	chatd("RegistryEntry: " + name + " | " + " registering asset: " + file_name)
	if await _register_asset(file_name, asset) == OK: return asset_registered(file_name);
	if not data.has(file_name): data[file_name] = asset; return asset_registered(file_name)
	return ERR_ALREADY_EXISTS

func _register_asset(_file_name:String, _asset:Variant) -> Error: return ERR_DATABASE_CANT_READ

func is_entry() -> bool: return true
