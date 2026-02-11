class_name CameraControls

extends Node3D

@export_range(1, 10) var mouse_sensitivity : int = 4
@export var camera_name : String

@onready var pivot : Node = get_node_or_null("../../Character/Cameras/%s" % name)

var spring_arm : Node
var camera : Node


func _ready() -> void:
	if not pivot:
		set_process_mode(PROCESS_MODE_DISABLED)
	else:
		spring_arm = pivot.get_child(0)
		camera = spring_arm.get_child(0)

		camera.deactivated.connect(_on_camera_deactivated)
		camera.activated.connect(_on_camera_activated)


func _physics_process(_delta: float) -> void:
	pivot.free_look = Input.is_action_pressed("free_look")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_unlock"):
		pivot.unlocked = not pivot.unlocked
	if spring_arm:
		if event.is_action_pressed("zoom_in"):
			spring_arm.zoom_in()
		if event.is_action_pressed("zoom_out"):
			spring_arm.zoom_out()


func _unhandled_input(event: InputEvent) -> void:
	# Mouselook implemented using `screen_relative` for resolution-independent sensitivity.
	if event is InputEventMouseMotion :
		pivot.follow_mouse(event.screen_relative * mouse_sensitivity * .001)


func _on_camera_deactivated() -> void:
	set_process_mode(PROCESS_MODE_DISABLED)


func _on_camera_activated() -> void:
	set_process_mode(PROCESS_MODE_INHERIT)
