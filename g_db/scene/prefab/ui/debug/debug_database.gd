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
