#|*******************************************************************
# debug_database_tree.gd
#*******************************************************************
# This file is part of g_libs.
# 
# g_libs is an open-source software library.
# g_libs is licensed under the MIT license.
# 
# https://github.com/gammasynth/g_libs
#*******************************************************************
# Copyright (c) 2025 AD - present; 1447 AH - present, Gammasynth.  
# Gammasynth (Gammasynth Software), Texas, U.S.A.
# 
# This software is licensed under the MIT license.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
#|*******************************************************************




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
