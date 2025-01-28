class_name Math

static func coin(sides:int=1) -> bool:
	return randi_range(clamp(0,sides, sides),sides) == 0
