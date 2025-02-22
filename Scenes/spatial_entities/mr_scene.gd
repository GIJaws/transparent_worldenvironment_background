extends Area3D
# TODO refactor the room_surface logic in the room_surface scene
const WINDOW_FRAME = preload("res://Scenes/spatial_entities/window_frame.tscn")
const ROOM_SURFACE = preload("res://Scenes/spatial_entities/room_surface.tscn")

# TODO refactor this so either window_mesh or room_surface is instantiated since only one is used
# var window_mesh: StaticBody3D = WINDOW_FRAME.instantiate()
# var room_surface: StaticBody3D = ROOM_SURFACE.instantiate()

var window_mesh: StaticBody3D
var room_surface: StaticBody3D

@onready var label_3d: Label3D = $Label3D


func setup_scene(entity: OpenXRFbSpatialEntity) -> void:
	var semantic_labels: PackedStringArray = entity.get_semantic_labels()
	var entity_name = semantic_labels[0]
	print("[MRScene] Setting up spatial entity: %s" % entity_name)

	label_3d.text = entity_name

	var collision_shape: CollisionShape3D = entity.create_collision_shape()
	add_child(collision_shape)
	print("[MRScene] Added collision shape to %s" % entity_name)

	if semantic_labels[0] == "window_frame":
		window_mesh = WINDOW_FRAME.instantiate()
		print("[MRScene] Adding window_frame mesh")
		add_child(window_mesh)
		var bounding_size = entity.get_bounding_box_2d().size
		window_mesh.csg_box_3d.size = Vector3(bounding_size.x, bounding_size.y, 1)
		print("[MRScene] Window frame size: %s" % str(bounding_size))
		var static_shape: CollisionShape3D = entity.create_collision_shape()
		window_mesh.add_child(static_shape)
	else:
		room_surface = ROOM_SURFACE.instantiate()
		print("[MRScene] Adding room_surface mesh")
		add_child(room_surface)
		var bounding_size = entity.get_bounding_box_2d().size
		room_surface.csg_box_3d.size = Vector3(bounding_size.x, bounding_size.y, 0.1)
		print("[MRScene] room_surface size: %s" % str(bounding_size))
		var static_shape: CollisionShape3D = entity.create_collision_shape()
		room_surface.add_child(static_shape)

	# Notify that this spatial entity is ready
	print("[MRScene] Spatial entity %s is ready" % entity_name)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("window_frame"):
		if is_instance_valid(body.csg_box_3d) and is_instance_valid(room_surface):
			print("[MRScene] Window frame entered room_surface - reparenting CSG")
			body.csg_box_3d.reparent(room_surface.csg_box_3d)
