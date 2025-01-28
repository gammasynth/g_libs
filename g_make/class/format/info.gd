class_name Info


static func get_script_name(value:Variant) -> String:
	if not value: return "NIL"
	
	var script: Script 
	if value is Script: script = value
	elif value is Object and value.get_script() is Script: script = value.get_script()
	
	if not script: return "NIL"
	
	var script_name : String = script.get_global_name()
	while script_name.is_empty(): 
		if script.get_base_script() is Script:
			script = script.get_base_script()
			script_name = script.get_global_name()
		else:
			script_name = script.get_class()
			if script_name.is_empty(): script_name = "Object"
	
	return script_name
