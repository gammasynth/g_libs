extends ControlTree

class_name DebugDatabaseTree


func _update_tree(origin_inst:InstanceVisualizerControl):
	clear()

	# Create the root TreeItem ("model")
	var item_model = create_item()

	# Set the text label for this item (the 0 specifies the Tree column)
	item_model.set_text(0, origin_inst.name) 

	# Set the actual model node as the TreeItem's metadata.
	# This means I can get the actual model node from the TreeItem using tree_item.get_metadata(0)
	item_model.set_metadata(0, origin_inst) 

	create_all_instances(item_model, origin_inst)
	#item_bodies.set_selectable(0, false)
	
	

func create_all_instances(item:TreeItem, inst:InstanceVisualizerControl):
	for subinst in inst.subinstances:
		var sub_item = create_tree_item(subinst, item)
		create_all_instances(sub_item, subinst)


func _create_tree_item(_item, _parent_item):
	var item = create_item(_parent_item)
	item.set_text(0, _item.instance.name)
	item.set_metadata(0, _item)
	#item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	#item.set_checked(0, _item.visible)
	#item.set_tooltip(1, "Show/Hide")
	#item.set_editable(0, true)
	#item.set_tooltip(0, "this shows when you mouse hover over the item")
	return item
