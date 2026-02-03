@tool
extends Node
class_name TimeTool

@export_tool_button("Refresh Timestamp") var refresh_timestamp_button: Callable = refresh_timestamp

func refresh_timestamp() -> void: 
	print(date_time_stamp)
	#date_lib_created = date_time_stamp

@export var use_utc_time: bool = false
@export var use_military_time: bool = false
@export var string_case: Text.StringCases = Text.StringCases.Kebab
@export var size_case: Text.SizeCases = Text.SizeCases.Lower

@export var date_time_stamp: String = "jan-1-2000":
	get:
		date_time_stamp = get_date_time_stamp(string_case, use_utc_time, use_military_time, size_case)
		return date_time_stamp


static func get_date_time_stamp(stringcase:Text.StringCases=Text.StringCases.Kebab, use_utc:bool=false, use_military:bool=false, sizecase:Text.SizeCases=Text.SizeCases.Lower) -> String:
	var current_date_time_stamp: String = Timestamp.stamp(
			Timestamp.DateTimeFormats.DT, true,
			Timestamp.DateFormats.MDY, true, 3,
			Timestamp.TimeFormats.HMS, true, 
			stringcase, use_utc, 
			[Timestamp.TimeTypes.Second], 1, false, false, 
			use_military,
			sizecase
		)
	return current_date_time_stamp
