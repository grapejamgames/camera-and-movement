## Input handling for camera pivot, spring arm, and camera. 
class_name CameraControls

extends Node3D

## The speed at which the camera moves around
@export_range(1, 10) var mouse_sensitivity : int = 4

## The controls rely on a pivot with a spring arm child that has a camera3d child.
## This references that pivot
@onready var pivot : Node = get_node_or_null("../../Character/Cameras/%s" % name)

## The controls rely on a pivot with a spring arm child that has a camera3d child.
## This references that spring arm
var spring_arm : Node

## The controls rely on a pivot with a spring arm child that has a camera3d child.
## This references that camera
var camera : Node


func _ready() -> void:
	# start deactivated.
	_on_camera_deactivated()
	if not pivot:
		_on_camera_deactivated()
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


## Deactivates camera and stops processing physics, input, etc...
func _on_camera_deactivated() -> void:
	set_process_mode(PROCESS_MODE_DISABLED)

## Activates camera and starts processing physics, input, etc...
func _on_camera_activated() -> void:
	set_process_mode(PROCESS_MODE_INHERIT)
