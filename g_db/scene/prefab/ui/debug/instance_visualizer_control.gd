extends Control

class_name InstanceVisualizerControl

var panel: Panel = null
var margin: MarginContainer = null
var vbox: VBoxContainer = null
func get_vbox() -> VBoxContainer: return vbox

var parent_instance_visualizer: InstanceVisualizerControl = null

var debug_database_graph: DebugDatabaseGraph = null
var parent_node: Node = null

var text_colors: Dictionary = {
	"0" : -1,
	"class_name" : Text.COLORS.red,
	"property" : Text.COLORS.green
}

var instance : Variant = null
var subinstances : Array[InstanceVisualizerControl] = []


static func instance_visualizer(instance:Variant, recursive:bool = false, parent:Node=null, graph:Node=null, with_offset:Vector2 = Vector2.ZERO, _class_string_name:Variant=null) -> InstanceVisualizerControl:
	var v : InstanceVisualizerControl = InstanceVisualizerControl.new()
	v.name = instance.name
	
	v = await Make.child(v, parent)
	v.position += with_offset
	
	return await v.create_from_instance(instance, recursive, parent, graph, _class_string_name)


func _ready():
	parent_node = get_parent()
	
	panel = Panel.new()
	add_child(panel)
	
	margin = MarginContainer.new()
	add_child(margin)
	if not margin.is_node_ready(): await margin.ready
	
	var margin_value = 10
	margin.add_theme_constant_override("margin_top", margin_value)
	margin.add_theme_constant_override("margin_left", margin_value)
	margin.add_theme_constant_override("margin_bottom", margin_value)
	margin.add_theme_constant_override("margin_right", margin_value)
	
	vbox = VBoxContainer.new()
	margin.add_child(vbox)
	if not vbox.is_node_ready(): await vbox.ready
	
	#print("MARGIN DEFAULT SIZE: " + str(margin.size))
	
	#create_from_instance(RefData.new())


func cast_property_by_name(property_name:String):
	var property_value:Variant = instance.get(property_name)
	await cast_property(property_name, property_value)

func cast_property(property_name:String, property_value:Variant):
	var property_value_name: String
	
	if property_value is RefInstance: property_value_name = property_value.name
	else: property_value_name = str(property_value)
	
	var p: Node = self
	if p.has_method("get_vbox"):
		var v = p.get_vbox()
		if v:
			p = v
	
	return await Make.text_label(
		Text.center(str( Text.color( str(property_name + " : ") , text_colors["property"], true ) + property_value_name )),
		"property_label", 
		p
		)


func is_visualizable(value:Variant) -> bool:
	if not value: return false
	if value is not Object: return false
	
	if not is_instance_valid(value): return false
	
	if value is Node:
		if value.has_method("get_database"):
			if debug_database_graph:
				if debug_database_graph.all_instance_keys.has(value.db.key):
					return false
			return true
	if value is RefInstance:
		if debug_database_graph:
			if debug_database_graph.all_instance_keys.has(value.key):
				return false
		return true
	return false

func create_from_instance(_instance:Variant, recursive:bool = false, _parent:Node=null, _graph:DebugDatabaseGraph=null, _class_string_name:Variant=null) -> InstanceVisualizerControl:
	instance = _instance
	
	var cn: String = ""
	if instance is not RefInstance:
		if instance is Node:
			if instance.has_method("get_database"):
				var s = instance.get_script()
				cn = s.get_global_name()
				var name_attempts:int = 0
				
				while cn.is_empty() and name_attempts < 100:
					name_attempts += 1
					if s.get_base_script() is Script:
						s = s.get_base_script()
						cn = s.get_global_name()
					else: break
				instance = instance.db
			else:
				print("ERROR CANT VISUALIZE INSTANCE: " + str(instance))
		else:
			print("ERROR CANT VISUALIZE INSTANCE: " + str(instance))
	
	debug_database_graph = _graph
	
	
	var script: Script = instance.get_script()
	var class_name_string: String = script.get_global_name()
	
	if _class_string_name is String:
		if not _class_string_name.is_empty(): 
			class_name_string = _class_string_name
	
	if not cn.is_empty():
		class_name_string = cn
	
	if not debug_database_graph or debug_database_graph.details:
		await Make.text_label(
			Text.color( str("class: " + class_name_string) , text_colors["class_name"], true ),
			"class_name_label", 
			vbox
			)
		var sep:HSeparator = HSeparator.new()
		vbox.add_child(sep)
		if not sep.is_node_ready(): await sep.ready
	
	
	var values: Array = []
	
	if instance is Pool:
		for key in instance.keys():
			var value = instance.grab(key)
			if value and value != instance.parent_instance:
				if is_visualizable(value) and not values.has(value): 
					values.append(value)
	
	var script_properties: Array[Dictionary] = script.get_script_property_list()
	script_properties.reverse()
	for property_info in script_properties:
		var property_name: String = property_info.name
		
		# any properties to be skipped in display can be shown here
		#if property_name == "parent_instance": continue
		
		var s = script
		var checked_all:bool = false
		var skip:bool = false
		while not checked_all and not skip:
			var n = str(s.get_global_name().to_snake_case() + ".gd")
			if n == property_name: skip = true; break
			#print("s: " + str(s))
			#print(s.get_base_script())
			#print(s.get_global_name())
			if s.get_base_script() is Script:
				s = s.get_base_script()
			else:
				checked_all = true
		
		if skip: continue
		
		var property_value = instance.get(property_name)
		
		if property_name != "parent_instance":
			if is_visualizable(property_value): values.append(property_value)
		
		if property_value is Dictionary:
			if recursive:
				for key in property_value.keys():
					var value = property_value.get(key)
					if value and typeof(value) == TYPE_OBJECT: 
						if is_instance_valid(value) and value != instance.parent_instance:
							if is_visualizable(value) and not values.has(value): 
								values.append(value)
			
			if property_value.size() == 0:
				property_value = "{}"
			else:
				property_value = "{...}"
		if not debug_database_graph or debug_database_graph.details or property_name == "name":
			await cast_property(property_name, property_value)
		#ready.connect(setup_child_inst.bind(property_value, graph))
		
	
	size = margin.size
	panel.size = margin.size
	
	if debug_database_graph:
		if not debug_database_graph.all_instance_keys.has(instance.key):
			debug_database_graph.all_instance_keys.append(instance.key)
	
	if recursive:
		var x: float = 0.0
		for value in values:
			x = await setup_child_inst(value, x)
	
	return self

func _on_selected():
	# doesnt work
	#if OS.has_feature("editor"): EditorInterface.inspect_object(self)
	
	debug_database_graph.camera_2d.global_position = global_position + (margin.size * 0.5)
	
	var pos = position
	position = pos + (margin.size * 0.05)
	create_tween().tween_property(self, "position", pos, 0.25)
	
	scale = Vector2(0.95,0.95)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.25)
	
	modulate = Color(0.9, 1.0, 0.9, 0.9)
	create_tween().tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)

func setup_child_inst(property_value:Variant, x:float = 0.0) -> float:
	#var class_string_name:Variant = null
	#if property_value is Node:
		#if property_value.has_method("get_database"):
			#class_string_name = property_value.get_script().get_global_name()
			#property_value = property_value.db
		#else:
			#return x
	#if property_value is RefInstance:
		#var p: Node = self
		#if graph:
			#p = graph
		
		#print("instancing: " + property_value.name)
		#print("x: " + str(x))
	var new_pos: Vector2 = global_position
	#new_pos.y += position.y
	new_pos += margin.size# * -1.5
	new_pos.x += x
	#print("new pos: " + str(new_pos))
	if property_value is RefInstance:
		if property_value.parent_instance:
			if property_value.parent_instance != instance:
				print(instance.name + ": CANT SPAWN:" + property_value.name + ", PARENT IS: " + property_value.parent_instance.name)
				return x
		else:
			print( property_value.name + " HAS NO PARENT")
			return x
	elif property_value is Object:
		if property_value.has_method("get_database"):
			if property_value.db.parent_instance:
				if property_value.db.parent_instance != instance:
					print(instance.name + ": CANT SPAWN:" + property_value.db.name + ", PARENT IS: " + property_value.db.parent_instance.name)
					return x
			else:
				print( property_value.db.name + " HAS NO PARENT")
				return x
	
	var inst : InstanceVisualizerControl = await InstanceVisualizerControl.instance_visualizer(property_value, true, get_parent(), debug_database_graph, new_pos)
	inst.parent_instance_visualizer = self
	subinstances.append(inst)
	
	#print(property_value.name + ": size x: " + str(inst.margin.size.x))
	#x += inst.global_position.x
	if debug_database_graph:
		await debug_database_graph.new_child_instance(self, inst)
	x += inst.get_total_size_x()
	return x

func get_total_size_x() -> float:
	var x : float = margin.size.x# * -1.5
	for subinst in subinstances:
		x += subinst.get_total_size_x()
	return x
