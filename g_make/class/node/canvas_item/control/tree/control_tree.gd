extends Tree
# This script is a modified version of a script by reddit.com user: u/Unlikely-Raisin

class_name ControlTree


# Connect signals from the Tree
func _ready():
	item_selected.connect(_on_tree_item_selected)
	item_edited.connect(_on_tree_item_edited)


# This draws the tree from a data structure provided ("model")
func update_tree(model):
	return _update_tree(model)

func _update_tree(model):
	clear()

	# Create the root TreeItem ("model")
	var item_model = create_item()

	# Set the text label for this item (the 0 specifies the Tree column)
	item_model.set_text(0, model.name) 

	# Set the actual model node as the TreeItem's metadata.
	# This means I can get the actual model node from the TreeItem using tree_item.get_metadata(0)
	item_model.set_metadata(0, model) 

	# Create a subheading / child TreeItem ("bodies")
	var item_bodies = create_item(item_model)
	item_bodies.set_text(0, "Bodies")
	item_bodies.set_selectable(0, false)
	
	create_tree_item(model, item_bodies)
	## Few lines to sort all the bodies in the model into alphabetical order and add them to the tree as children to the Bodies subheading
	#var bodies_array = []
	#for body_name in model.bodies.keys():
		#bodies_array.append(body_name)
		#bodies_array.sort()
	#
	#if !bodies_array.empty():
		#for body_name in bodies_array:
			#create_tree_item(model.bodies[body_name], item_bodies)


# Sub function to create a TreeItem for a body or joint (_item)
# Creates a selectable text label in column 0 and a check box in column 1
func create_tree_item(_item, _parent_item):
	return _create_tree_item(_item, _parent_item)

func _create_tree_item(_item, _parent_item):
	var item = create_item(_parent_item)
	item.set_text(0, _item.name)
	item.set_metadata(0, _item)
	#item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	#item.set_checked(1, _item.visible)
	#item.set_tooltip(1, "Show/Hide")
	#item.set_editable(1, true)
	#item.set_tooltip(0, "this shows when you mouse hover over the item")


# item selected (if the TreeItem is set to selectable, clicking it will fire this signal)
func _on_tree_item_selected():
	# Get the node from the selected tree_item
	if get_selected().get_metadata(0) == null: return
	
	var selected_node = get_selected().get_metadata(0)
	
	if not selected_node.has_method("_on_selected"): return
	
	selected_node._on_selected() # Do something with it


# Name change (if the TreeItem is set to editable, clicking it lets you change the TreeItem's label)
# Here we use the updated label to change the name of the node represented by the tree_item
func _on_tree_item_edited():
	var c: int = get_edited_column()
	if get_edited().get_metadata(c) == null:
		return
	var edited_node = get_edited().get_metadata(c)
	var new_name = get_edited().get_text(c)
	edited_node.name = new_name
