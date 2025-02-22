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
