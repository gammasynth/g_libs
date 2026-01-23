#|*******************************************************************
# debug_database.gd
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



extends Control
class_name DebugDatabase

@onready var graph_tabs: TabContainer = $GraphTabs


func _ready():
	if RefInstance.origin_instance:
		add_graph(RefInstance.origin_instance)



func add_graph(database: Variant) -> DebugDatabaseGraph:
	var graph:DebugDatabaseGraph = load("res://core/scene/prefab/ui/debug/debug_database_graph.tscn").instantiate()
	graph.database = database
	
	graph = await Make.child(graph, graph_tabs)
	
	graph.name = str(database.name + "_graph")
	graph.debug_database = self
	
	return graph




func draw_database_tree() -> Error:
	var err: Error = OK
	for tab in graph_tabs.get_children():
		if tab is DebugDatabaseGraph:
			err = await tab.draw_database_tree()
			if err != OK: print("err drawing trees: " + error_string(err))
	return OK
