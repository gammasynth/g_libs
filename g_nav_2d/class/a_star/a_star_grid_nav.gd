extends RefCounted

class_name AStarGridNav

var astar_grid: AStarGrid2D = null

func _init(region:Rect2i=Rect2i(-512, -512, 1024, 1024), cell_size:Vector2 = Vector2(8, 8), middle_offset:bool=false):
	establish_map(region, cell_size, middle_offset)

func establish_map(region:Rect2i=Rect2i(-512, -512, 1024, 1024), cell_size:Vector2 = Vector2(8, 8), middle_offset:bool=false):
	astar_grid = AStarGrid2D.new()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar_grid.region = region
	astar_grid.offset = Vector2.ZERO; if middle_offset: if cell_size.x > 1: astar_grid.offset = (cell_size * 0.5).floor();
	astar_grid.cell_size = cell_size
	astar_grid.update()


func plot_solid_tiles_in_map(solid_tiles:Array[Vector2i], solid:bool=true) -> Error:
	return _plot_solid_tiles_in_map(solid_tiles, solid)

func _plot_solid_tiles_in_map(solid_tiles:Array[Vector2i], solid:bool=true) -> Error:
	for solid_tile in solid_tiles:
		astar_grid.set_point_solid(solid_tile, solid)
	return OK

func are_tiles_solid(tiles:Array[Vector2i]) -> bool:
	return _are_tiles_solid(tiles)

func _are_tiles_solid(tiles:Array[Vector2i]) -> bool:
	for tile in tiles:
		if astar_grid.is_point_solid(tile):
			return true
	return false


func get_point_weight(grid_pos:Vector2i) -> float:
	return astar_grid.get_point_weight_scale(grid_pos)

func set_point_weight(grid_pos:Vector2i, new_weight_scale:float) -> void:
	astar_grid.set_point_weight_scale(grid_pos, new_weight_scale); return;

func alter_point_weight(grid_pos:Vector2i, by_amount:float) -> void:
	if astar_grid.is_in_boundsv(grid_pos):
		set_point_weight(grid_pos, get_point_weight(grid_pos) + by_amount)
	return



func handle_danger(adding:bool, grid_pos:Vector2i, danger_level:float, area_danger_level:float = 1, area_danger_radius:int = 1, do_area:bool = false):
	var danger_dict = {}
	if not adding: danger_level *= -1; area_danger_level *= -1;
	alter_point_weight(grid_pos, danger_level);
	if do_area:
		var circle_tiles:Array[Vector2i] = TileMath2D.create_tiles_in_circle(grid_pos, area_danger_radius)
		for circle_tile in circle_tiles:
			if circle_tile != grid_pos:
				if astar_grid.is_in_boundsv(circle_tile):
					alter_point_weight(circle_tile, area_danger_level)
		
		for circle_tile in circle_tiles:
			if astar_grid.is_in_boundsv(circle_tile):
				danger_dict[circle_tile] = astar_grid.get_point_weight_scale(circle_tile)
	else:
		danger_dict[grid_pos] = astar_grid.get_point_weight_scale(grid_pos)
	return danger_dict
	

func get_nav_path(start_point, end_point) -> PackedVector2Array:
	if astar_grid.cell_size != Vector2(1,1):
		if not start_point is Vector2i:
			start_point = TileMath2D.global_to_grid_pos(start_point)
		if not end_point is Vector2i:
			end_point = TileMath2D.global_to_grid_pos(end_point)
	
	var was_solid:bool = false
	if astar_grid.is_point_solid(end_point):
		was_solid = true
		astar_grid.set_point_solid(end_point, false)
	
	var path = astar_grid.get_point_path(start_point, end_point, true)
	
	if was_solid:
		astar_grid.set_point_solid(end_point, true)
	
	return path
