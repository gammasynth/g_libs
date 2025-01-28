class_name VectorMath2D
# A Static Helper class for Vector2 and Vector2i management.

const manhattan_dirs: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

const dirs: Array[Vector2] = [
	
	Vector2.UP, 
	Vector2.DOWN, 
	Vector2.LEFT, 
	Vector2.RIGHT,
	
	Vector2.UP + Vector2.RIGHT,
	Vector2.UP + Vector2.LEFT,
	
	Vector2.DOWN + Vector2.RIGHT,
	Vector2.DOWN + Vector2.LEFT
	
	]

static func float_as_vector2(n:float) -> Vector2: return Vector2(n,n);
static func int_as_vector2(n:int) -> Vector2: return Vector2(n,n);
static func int_as_vector2i(n:int) -> Vector2i: return Vector2i(n,n);
static func floor_vec2(x:Variant, y:Variant) -> Vector2: return Vector2i(floor(float(x)),floor(float(y)));
static func floor_vec2i(x:Variant, y:Variant) -> Vector2i: return Vector2i(floor(float(x)),floor(float(y)));

static func distance_vec(vec2a:Vector2i, vec2b:Vector2i) -> Vector2i: return vec2a - vec2b;

static func manhattan_direction_to(point_a:Vector2, point_b:Vector2, prefer_vertical:bool=false):
	var dir = point_a.direction_to(point_b)
	if dir.x != 0 and dir.y != 0:
		if prefer_vertical: dir.x = 0;
		else: dir.y = 0;
	return dir

static func get_corner_directions(from_dir:Vector2) -> Array[Vector2]:
	var corners : Array[Vector2] = []
	if from_dir.x and from_dir.y:
		for dir: Vector2 in dirs:
			if dir == from_dir: continue
			if from_dir.y and dir.y == from_dir.y: 
				var d = dir
				d.x = 0
				if not corners.has(d): corners.append(d)
			if from_dir.x and dir.x == from_dir.x:
				var d = dir
				d.y = 0
				if not corners.has(d): corners.append(d)
	else:
		for dir: Vector2 in dirs:
			if dir == from_dir: continue
			if from_dir.y and dir.y == from_dir.y: corners.append(dir)
			if from_dir.x and dir.x == from_dir.x: corners.append(dir)
	return corners
