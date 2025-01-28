extends Window
class_name DebugDatabaseWindow

@onready var debug_database_control: DebugDatabase = $DebugDatabase

@onready var refresh_timer: Timer = $RefreshTimer
@export var refresh_rate: float = 1.0


func _ready():
	position += Vector2i(25,25)
	size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	title = str(ProjectSettings.get_setting("application/config/name") + " Debug Database")
	refresh_timer.start(1.0)


func _on_refresh_timer_timeout() -> void:
	var err = await debug_database_control.draw_database_tree()
	if err == OK: refresh_timer.start(refresh_rate)
