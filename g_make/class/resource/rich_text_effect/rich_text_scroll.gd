#|*******************************************************************
# rich_text_scroll.gd
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
extends RichTextEffect
class_name RichTextScroll

# Syntax: [matrix clean=2.0 dirty=1.0 span=50][/matrix]

# Define the tag name.
var bbcode = "scroll"

# Gets TextServer for retrieving font information.
func get_text_server():
	return TextServerManager.get_primary_interface()


func _process_custom_fx(char_fx):
	#return
	# Get parameters, or use the provided default value if missing.
	var x = char_fx.env.get("x", 1.0)
	var y = char_fx.env.get("y", 0.0)
	var speed = char_fx.env.get("speed", 10.0)
	var jumble_x = char_fx.env.get("jumble_x", 0.101251)
	var jumble_y = char_fx.env.get("jumble_y", 2.001251)
	var mixup = char_fx.env.get("mixup", 0.1)

	var value = char_fx.glyph_index

	#var matrix_time = fmod(char_fx.elapsed_time + (char_fx.range.x / float(text_span)), \
						   #clear_time + dirty_time)
#
	#matrix_time = 0.0 if matrix_time < clear_time else \
				  #(matrix_time - clear_time) / dirty_time
#
	#if matrix_time > 0.0:
		#value = int(1 * matrix_time * (126 - 65))
		#value %= (126 - 65)
		#value += 65
	#char_fx.glyph_index = get_text_server().font_get_glyph_index(char_fx.font, 1, value, 0)
	#char_fx.offset = Vector2(sin(randf_range(0.0, jumble_x)),sin(randf_range(0.0, jumble_y)))# * char_fx.transform.origin# * Vector2(1,1)
	var mx: float = sin(char_fx.elapsed_time) * speed# * 0.1
	#print(mx)
	#char_fx.offset -= Vector2(x,y) * 0.85
	#char_fx.offset += clampf(sin(mx), 0, mx) * Vector2(x,y)
	char_fx.offset += mx * Vector2(x,y)
	return true
