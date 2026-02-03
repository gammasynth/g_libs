#|*******************************************************************
# time_tool.gd
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
@tool
extends Node
class_name TimeTool

@export_tool_button("Refresh Timestamp") var refresh_timestamp_button: Callable = refresh_timestamp

func refresh_timestamp() -> void: 
	print(date_time_stamp)
	#date_lib_created = date_time_stamp

@export var use_utc_time: bool = false
@export var use_military_time: bool = false
@export var string_case: Text.StringCases = Text.StringCases.Kebab
@export var size_case: Text.SizeCases = Text.SizeCases.Lower

@export var date_time_stamp: String = "jan-1-2000":
	get:
		date_time_stamp = get_date_time_stamp(string_case, use_utc_time, use_military_time, size_case)
		return date_time_stamp


static func get_date_time_stamp(stringcase:Text.StringCases=Text.StringCases.Kebab, use_utc:bool=false, use_military:bool=false, sizecase:Text.SizeCases=Text.SizeCases.Lower) -> String:
	var current_date_time_stamp: String = Timestamp.stamp(
			Timestamp.DateTimeFormats.DT, true,
			Timestamp.DateFormats.MDY, true, 3,
			Timestamp.TimeFormats.HMS, true, 
			stringcase, use_utc, 
			[Timestamp.TimeTypes.Second], 1, false, false, 
			use_military,
			sizecase
		)
	return current_date_time_stamp
