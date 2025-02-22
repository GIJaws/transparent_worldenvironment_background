extends StaticBody3D

@export_enum("wall_face", "floor", "ceiling") var surface_type: String = "wall_face"
@export var debug_mode := false  # Toggle between debug visualization and passthrough

@onready var csg_box_3d: CSGBox3D = $CSGBox3D
@onready var pass_through_geo: OpenXRFbPassthroughGeometry = $OpenXRFbPassthroughGeometry

signal surface_mesh_baked(mesh_instance: MeshInstance3D)

var _is_baked := false
var _baked_mesh: Mesh = null

func _ready() -> void:
	# Add to appropriate group based on surface type
	add_to_group("room_surface")

	# Connect to global event from player_room
	if not Engine.is_editor_hint():
		await get_tree().create_timer(0.1).timeout  # Small delay to ensure player_room is ready
		var player_room = get_tree().get_first_node_in_group("player_room")
		if player_room:
			player_room.bake_surface_meshes.connect(_on_bake_surface_meshes)

func _on_bake_surface_meshes() -> void:
	# Prevent multiple bakes
	if _is_baked:
		print("[RoomSurface] Already baked, skipping...")
		return

	if not is_instance_valid(csg_box_3d):
		print("[RoomSurface] CSG node no longer valid, skipping...")
		return

	print("[RoomSurface] Baking mesh from CSG...")

	# Bake mesh from CSG
	var meshes = csg_box_3d.get_meshes()
	if meshes.size() >= 2:  # CSG returns array with [Transform3D, Mesh, ...]
		_baked_mesh = meshes[1]  # [1] contains the mesh data

		if debug_mode:
			_create_debug_mesh_instance()
		else:
			_apply_to_passthrough()

		# Free the CSG node since we don't need it anymore
		csg_box_3d.queue_free()

		# Mark as baked
		_is_baked = true

		print("[RoomSurface] Mesh baked successfully!")
	else:
		printerr("[RoomSurface] Failed to get mesh data from CSG!")

func _create_debug_mesh_instance() -> void:
	# Create MeshInstance3D as sibling
	var mesh_instance := MeshInstance3D.new()
	get_parent().add_child(mesh_instance)
	mesh_instance.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().root

	# Copy transform and material
	mesh_instance.transform = transform

	# Create a new StandardMaterial3D with some visual distinction
	var material := StandardMaterial3D.new()
	# Different colors for different surface types
	match surface_type:
		"wall_face":
			material.albedo_color = Color(0.2, 0.8, 0.3, 1.0)  # Green
			material.emission = Color(0.1, 0.4, 0.15)
		"floor":
			material.albedo_color = Color(0.2, 0.3, 0.8, 1.0)  # Blue
			material.emission = Color(0.1, 0.15, 0.4)
		"ceiling":
			material.albedo_color = Color(0.8, 0.2, 0.3, 1.0)  # Red
			material.emission = Color(0.4, 0.1, 0.15)

	material.metallic = 0.7
	material.roughness = 0.2
	material.emission_enabled = true
	mesh_instance.material_override = material

	mesh_instance.mesh = _baked_mesh

	# Add a visual effect to show the bake happened
	_add_bake_effect(mesh_instance)

	# Emit signal that mesh was baked
	surface_mesh_baked.emit(mesh_instance)

func _apply_to_passthrough() -> void:
	# Apply the baked mesh to the passthrough geometry
	pass_through_geo.mesh = _baked_mesh

	# Emit signal that mesh was baked (might be useful for other systems)
	surface_mesh_baked.emit(pass_through_geo)

	print("[RoomSurface] Applied baked mesh to passthrough geometry")

func _add_bake_effect(mesh_instance: MeshInstance3D) -> void:
	# Create a tween for a quick "pop" effect
	var tween := create_tween()
	mesh_instance.scale = Vector3.ONE * 0.9  # Start slightly smaller

	# Scale up with bounce
	tween.tween_property(mesh_instance, "scale", Vector3.ONE, 0.3)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

	# Optional: Add a GPUParticles3D effect
	var particles := GPUParticles3D.new()
	mesh_instance.add_child(particles)
	# TODO Note: You'll need to set up a particle material for this to be visible
	# This is just a placeholder for now
	particles.emitting = true
	particles.one_shot = true
	particles.lifetime = 1.0
