#|*******************************************************************
# a_star_pixel_grid_nav.gd
#*******************************************************************
# This file is part of g_libs.
# 
# g_libs is an open-source software library.
# g_libs is licensed under the MIT license.
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


extends AStarGridNav

class_name AStarPixelGridNav

func _init(region:Rect2i=Rect2i(-512, -512, 1024, 1024)):
	establish_map(region, Vector2(1,1))

func _plot_solid_tiles_in_map(solid_tiles:Array[Vector2i], solid:bool=true) -> Error:
	for solid_tile in solid_tiles:
		var pixels = TileMath2D.create_pixels_in_tile(8, solid_tile)
		plot_solid_pixels_in_map(pixels, solid)
	return OK

func plot_solid_pixels_in_map(solid_tiles:Array[Vector2i], solid:bool=true):
	for solid_tile in solid_tiles:
		astar_grid.set_point_solid(solid_tile, solid)

func are_pixels_solid(pixels:Array[Vector2i]):
	for pixel in pixels:
		if astar_grid.is_point_solid(pixel):
			return true
	return false


func _are_tiles_solid(tiles:Array[Vector2i]) -> bool:
	for tile in tiles:
		var pixels = TileMath2D.create_pixels_in_tile(8, tile)
		var found_solid = are_pixels_solid(pixels)
		if found_solid: return true
	return false
