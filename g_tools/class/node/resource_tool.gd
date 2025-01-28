@tool
extends Node
class_name ResourceTool

@export var resource_control_type: Resource = null

@export var operation_path: String = "res://"

@export var resource_save_path: String = "res://src/resources/resource_folder/file_name.ext"

@export var create_animated_texture: bool = false:
	set(b):
		create_animated_texture = b
		if b:
			do_create_animated_texture()
			await get_tree().create_timer(0.5)
			create_animated_texture = false



func do_create_animated_texture() -> void:
	var image_file_paths: Array[String] = FileTool.get_all_filepaths_from_directory(operation_path, "", true)
	
	
	for fp:String in image_file_paths:
		if fp.ends_with("import"): image_file_paths.erase(fp)
	
	var fp_count:int = image_file_paths.size()
	
	if not image_file_paths or fp_count == 0 or fp_count > AnimatedTexture.MAX_FRAMES: 
		print("ResourceTool | Cant save AnimatedTexture!")
		return
	
	var anim_tex: AnimatedTexture = AnimatedTexture.new()
	
	anim_tex.frames = fp_count
	
	var idx: int = 0
	for fp: String in image_file_paths:
		var img: Texture2D = load(fp)
		if not img: continue
		
		anim_tex.set_frame_texture(idx, img)
		idx += 1
	
	ResourceSaver.save(anim_tex, resource_save_path)
	print("ResourceTool | Saved resource successfully.")
