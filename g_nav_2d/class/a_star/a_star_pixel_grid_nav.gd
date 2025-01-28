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
