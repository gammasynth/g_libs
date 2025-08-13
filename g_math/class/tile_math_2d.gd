## TileMath2D is a Static Helper Class for 2-Dimensional tile-based operations.
class_name TileMath2D

#region Grid Translation
## Returns a grid position from a global space position.
static func global_to_grid_pos(global_point: Vector2, cell_size : Vector2 = Vector2(8,8)) -> Vector2i:
	return VectorMath2D.floor_vec2i(global_point.x / cell_size.x, global_point.y / cell_size.y)

## Returns a global space position from a grid position, with an optional additional offset.
static func grid_to_global_pos(grid_point:Vector2i, cell_size:Vector2=Vector2(8,8), offset:Vector2=Vector2(0,0)) -> Vector2:
	return VectorMath2D.floor_vec2(grid_point.x * cell_size.x, grid_point.y * cell_size.y) + offset
#endregion

static func plot_tiles_between_points(point_a:Vector2, point_b:Vector2, manhattan:bool=false, skip:int=0) -> PackedVector2Array:
	var tiles: PackedVector2Array = []
	var point: Vector2 = point_a
	var skipping:int = 0
	for d in round(point.distance_to(point_b)) * 2:
		
		if skipping < skip:
			skipping += 1
			continue
		else:
			skipping = 0
		
		if manhattan: point = point.move_toward(point_b, 1.0)
		else: point = Vector2(move_toward(point.x, point_b.x, 1.0), move_toward(point.y, point_b.y, 1.0))
		if point.distance_to(point_b) > 0: if not tiles.has(point): tiles.append(point)
		else: break
	return tiles



#region Circle Shape Operations
## Return an Array[Vector2i] of tile positions in a circle of radius.
static func create_tiles_in_circle(tile_pos:Vector2i, radius:int, condition:Variant=null) -> Array[Vector2i]:
	var circle_tiles:Array[Vector2i] = []
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var tile_position = Vector2i(x, y)
			if (tile_position).length() <= radius:
				var spot = tile_pos + tile_position
				
				if condition is Callable and condition.get_argument_count() > 0:
					var result: Variant = condition.call(spot)
					if result is bool and result == false:
						continue
				
				circle_tiles.append(spot)
	return circle_tiles

static func create_tiles_in_circle_outline(tile_pos:Vector2i, radius:int, outline_width:int=1) -> Array[Vector2i]:
	
	var condition : Callable = func(spot:Vector2) -> bool:
		if spot.distance_to(tile_pos) > radius - outline_width: return true
		return false
	
	var circle_tiles:Array[Vector2i] = create_tiles_in_circle(tile_pos, radius, condition)
	return circle_tiles


## Perform a Callable on tile positions in a circle of radius.
static func operate_in_tile_circle(tile_pos:Vector2i, radius:int, operation:Callable=func():return) -> Error:
	var circle_tiles:Array[Vector2i] = create_tiles_in_circle(tile_pos, radius)
	for tile in circle_tiles: 
		await operation.call(tile)
	return OK
#endregion

#region Square Shape Operations
## Returns a Array[Vector2i] of sub-tile positions within a tile_size, positioned at tile_origin, starting at the top left most "pixel".
static func create_pixels_in_tile(tile_size:int, tile_origin:Vector2=Vector2.ZERO) -> Array[Vector2i]:
	var tiles:Array[Vector2i] = []
	for x in tile_size:
		for y in tile_size:
			var vec = Vector2i(x,y) + Vector2i(tile_origin)
			tiles.append(vec)
	return tiles


## Return an Array[Vector2i] of tile positions in a sized square, centered at center_point.
static func create_tiles_in_square(square_size_x:int, square_size_y:int, center_point:Vector2=Vector2.ZERO, only_outline:bool=false) -> Array[Vector2i]:
	var tiles : Array[Vector2i] = []
	var pos_x:float = center_point.x + (-square_size_x)
	var pos_y:float = center_point.y + (-square_size_y)
	for x in range(-square_size_x - 1, square_size_x + 2):
		for y in range(-square_size_y - 1, square_size_y + 2):
			var pos_vec = Vector2i(int(pos_x),int(pos_y))
			tiles.append(pos_vec)
			pos_y += 1
		pos_y = center_point.y + (-square_size_y)
		pos_x += 1
	if only_outline:
		var outline_tiles: Array[Vector2i] = []
		for tile in tiles:
			if tile.x == center_point.x + square_size_x or tile.x == center_point.x - square_size_x or tile.y == center_point.y + square_size_y or tile.y == center_point.y - square_size_y:
				outline_tiles.append(tile)
		return outline_tiles
	return tiles

## Perform a Callable on tile positions in a sized square, centered at center_point.
static func operate_in_square(square_size_x:int, square_size_y:int, operation:Callable=func():return, center_point:Vector2=Vector2.ZERO) -> Error:
	var tiles:Array[Vector2i] = create_tiles_in_square(square_size_x, square_size_y, center_point)
	for tile in tiles: await operation.call(tile)
	return OK



## Alternate form of creating lists of tile squares
## @deprecated
## @deprecated: use [create_tiles_in_square] instead.
static func operate_in_regular_square(square_size:int, center_point:Vector2=Vector2.ZERO, include_corners:bool=true):
	#square size is a single int that describes its width and height.
	#a 2x2 square that takes up 4 tiles has a square size of 2
	#a 3x3 quare that takes up 9 tiles has a square size of 3
	
	var tiles_involved:Array[Vector2i] = []
	var corner_offset = (ceil(float(square_size)/2)) - 1 #the distance in both x and y from the center to the top left corner
	for x in range(square_size):
		for y in range(square_size):
			var is_corner = false
			
			if x == 0 and y == 0:
				is_corner = true
			if x == 0 and y == square_size - 1:
				is_corner = true
			if x == square_size - 1 and y == 0:
				is_corner = true
			if x == square_size - 1 and y == square_size - 1:
				is_corner = true
			
			
			
			var pos_vec = Vector2i(center_point + Vector2(-corner_offset, -corner_offset) + Vector2(x,y))
			#the center point + -(corner offset) + iterating tiles
			if not include_corners:
				if not is_corner:
					tiles_involved.append(pos_vec)
			else:
				tiles_involved.append(pos_vec)
#
	return tiles_involved
#endregion
