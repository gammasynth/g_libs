class_name Make


static func child(node:Node, parent:Node, await_ready:bool=true) -> Node:
	if parent: 
		parent.add_child(node, true)
		if await_ready and not node.is_node_ready(): await node.ready
		#if parent.has_method("get_database") and node.has_method("get_database"):
			#var p: Database = parent.db
			#var c: Database = node.db
			#p.add(c, c.name)
		return node
	push_error("no parent for node: " + str(node))
	node.queue_free()
	return null



static func unique_canvas_item_child(canvas_item:CanvasItem, for_database:Database=null, await_ready:bool=false) -> CanvasItem:
	if for_database: for_database.chat("making unique child canvas item...")
	var canvas_script:GDScript = canvas_item.get_script()
	var canvas: CanvasItem
	if not canvas_script: canvas = ClassDB.instantiate(canvas_item.get_class())
	else: canvas = canvas_script.new()
	
	var n: String = ""
	if for_database:
		n = for_database.name
		n = str(n + "_")
	
	canvas.name = str(n+"canvas")
	
	if await_ready:
		await Make.child(canvas, canvas_item)
	else:
		canvas_item.add_child(canvas)
	
	return canvas


static func text_label(label_text:String, label_name:String="RichTextLabel", parent:Node=null, fit_content:bool=true, custom_minimum_size:Vector2=Vector2.ZERO, word_wrap:bool=false) -> RichTextLabel:
	var label : RichTextLabel = RichTextLabel.new()
	label.name = label_name
	
	label = await child(label, parent)
	
	label.bbcode_enabled = true
	label.fit_content = fit_content
	label.custom_minimum_size = custom_minimum_size
	if not word_wrap: label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	label.text = label_text
	
	return label

static func fade(node:CanvasItem, duration:float = 1.0, disable_controls:bool=true) -> Tween:
	if not node or not is_instance_valid(node): push_error("Make.fade(): node is already null or invalid instance!"); return null
	
	if disable_controls: disable_control(node)
	
	var tween: Tween = node.create_tween().set_parallel()
	tween.tween_property(node, "modulate", Color(0.0, 0.0, 0.0, 0.0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween

static func fade_delete(node:CanvasItem, duration:float = 1.0, disable_controls:bool=true) -> void:
	if not node or not is_instance_valid(node): return push_error("Make.fade_delete(): node is already null or invalid instance!")
	
	var tween:Tween = fade(node, duration, disable_controls)
	tween.tween_callback(node.queue_free).set_delay(duration)




static func disable_control(node:Control, recursive:bool=true) -> void:
	if not node or not is_instance_valid(node): return push_error("disable_control(): node is null or invalid instance!")
	
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE; node.focus_mode = Control.FOCUS_NONE
	
	if recursive:
		var kids := node.get_children()
		for kid in kids: if kid and is_instance_valid(kid) and kid is Control: disable_control(kid)

static func clear_children(node:Node, excluding_children:Array[Node]=[]) -> void:
	for kid in node.get_children():
		if excluding_children.has(kid): continue
		node.remove_child(kid)
		kid.queue_free()
	return
