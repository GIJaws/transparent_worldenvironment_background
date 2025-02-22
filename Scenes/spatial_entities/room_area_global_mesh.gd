extends Area3D

@onready var room_static_body: StaticBody3D = $RoomGlobalStaticBody
#@onready var passThroughGeo: OpenXRFbPassthroughGeometry = $PassthroughGeo
@onready var csg_box_3d: CSGBox3D = $RoomGlobalMesh/CSGBox3D
func setup_scene(entity: OpenXRFbSpatialEntity) -> void:
	var collision_shape = entity.create_collision_shape()
	#var mesh_instance = entity.create_mesh_instance()
	#passThroughGeo.set_mesh(mesh_instance.mesh)
	if collision_shape:
		room_static_body.add_child(collision_shape)

		var bounding_size = entity.get_bounding_box_2d().size
		csg_box_3d.size = Vector3(bounding_size.x, bounding_size.y, 0.1)
