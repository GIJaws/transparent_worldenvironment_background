extends StaticBody3D

@onready var csg_box_3d: CSGBox3D = $CSGBox3D

var _is_cleaned_up := false

func _ready() -> void:
	add_to_group("window_frame")

	# Connect to global event from player_room
	if not Engine.is_editor_hint():
		await get_tree().create_timer(0.1).timeout  # Small delay to ensure player_room is ready
		var player_room = get_tree().get_first_node_in_group("player_room")
		if player_room:
			player_room.bake_surface_meshes.connect(_on_bake_surface_meshes)

func _on_bake_surface_meshes() -> void:
	if _is_cleaned_up or not is_instance_valid(csg_box_3d):
		return

	print("[WindowFrame] Cleaning up CSG node after surface bake")
	csg_box_3d.queue_free()
	_is_cleaned_up = true
