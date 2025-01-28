class_name Cast

static var debug:bool
static var deep_debug:bool

static func array_string(array:Array) -> Array[String]:
	var arr:Array[String] = []
	for e in array:
		if e is String: 
			arr.append(e)
		else: 
			if debug: 
				push_warning(str("Error casting to Array[String], not all elements are String in Array: " + str(array)))
				push_warning(str("Not String: " + str(e)))
	return arr

static func is_array_strings(array:Array) -> bool:
	if array.size() == 0: return false
	for element in array:
		if element is not String: return false
	return true
