@tool
extends XRToolsSceneBase


signal bake_surface_meshes

@onready var scene_manager: OpenXRFbSceneManager = $XROrigin3D/OpenXRFbSceneManager
@onready var right_controller: XRController3D = $XROrigin3D/RightHand
# Constants for flying
const FLYING_SPEED = 2.0  # meters per second
const ROTATION_SPEED = 1.0  # radians per second

# Variables for flying state
var _is_flying: bool = false
var _flight_direction: Vector3 = Vector3.ZERO
var _skybox: MeshInstance3D
#var pxr_pass
func _ready():
	scene_manager.openxr_fb_scene_data_missing.connect(_scene_data_missing)
	scene_manager.openxr_fb_scene_capture_completed.connect(_scene_capture_completed)
	#pxr_pass = Engine.get_singleton("OpenXRFbPassthroughExtensionWrapper")
	OpenXRFbPassthroughExtensionWrapper.openxr_fb_projected_passthrough_layer_created.connect(ps_layer_created)


	if not Engine.is_editor_hint():
		configure_passthrough()
		# Add self to player_room group
		add_to_group("player_room")
		print("[PlayerRoom] Added to player_room group")

		# Connect to the right controller's button_pressed signal
		right_controller.button_pressed.connect(_on_controller_button_pressed)
		# _setup_space_environment()

func _process(delta: float) -> void:
	if false and not Engine.is_editor_hint() and _is_flying:
		# Get controller input for flying
		var input_vector = Vector2.ZERO

		# Use right controller joystick for movement
		if right_controller:
			input_vector = right_controller.get_vector2("Primary joystick/thumbstick/trackpad")

		# Calculate movement direction based on controller orientation
		var forward = -right_controller.global_transform.basis.z
		var right = right_controller.global_transform.basis.x

		# Combine movements
		_flight_direction = (forward * input_vector.y + right * input_vector.x).normalized()

		# Move the XROrigin3D (which moves the player and skybox)
		if _flight_direction.length() > 0.1:
			$XROrigin3D.global_position += _flight_direction * FLYING_SPEED * delta

func _setup_space_environment() -> void:
	# Create a large sphere for the skybox
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 50.0  # Large enough to encompass the play area
	sphere_mesh.height = 100.0
	sphere_mesh.is_hemisphere = false

	# Create the skybox instance
	_skybox = MeshInstance3D.new()
	_skybox.mesh = sphere_mesh
	_skybox.scale = Vector3(-1, 1, 1)  # Invert normals by scaling X negative

	# Create space material
	var space_material = StandardMaterial3D.new()
	space_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	space_material.albedo_color = Color(0.0, 0.0, 0.1)  # Dark blue base
	space_material.emission_enabled = true
	space_material.emission = Color(0.2, 0.2, 0.4)  # Slight blue glow

	_skybox.material_override = space_material

	# Add to XROrigin3D to move with player
	$XROrigin3D.add_child(_skybox)

func configure_passthrough() -> void:
	# Configure for projected passthrough
	var openxr_interface: OpenXRInterface = XRServer.find_interface("OpenXR")
	if openxr_interface:
		print("[PlayerRoom] Configuring passthrough...")
		get_viewport().transparent_bg = false
		openxr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND

		#OpenXRFbPassthroughExtensionWrapper.set_texture_opacity_factor(0.0)
func ps_layer_created() -> void:
	print("openxr_fb_projected_passthrough_layer_created !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
func _on_controller_button_pressed(button_name: String) -> void:
	if button_name == "ax_button":
		print("[PlayerRoom] AX button pressed - triggering surface mesh baking")
		# Count surface faces in scene
		var surface_faces = get_tree().get_nodes_in_group("surface_face")
		print("[PlayerRoom] Found %d surface faces in scene" % surface_faces.size())
		bake_surface_meshes.emit()

func _scene_data_missing() -> void:
	scene_manager.request_scene_capture()

func _scene_capture_completed(success: bool) -> void:
	if success == false:
		return

	# Delete any existing anchors, since the user may have changed them.
	if scene_manager.are_scene_anchors_created():
		scene_manager.remove_scene_anchors()

	# Create scene_anchors for the freshly captured scene
	scene_manager.create_scene_anchors()
