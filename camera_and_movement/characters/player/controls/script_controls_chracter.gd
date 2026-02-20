extends Node3D

## The speed at which the the character turns with the mouse
@export_range(0.0, 10.0) var mouse_sensitivity : float = 1
## The initial mouse movement ignored
@export var mouse_x_deadzone : float = 0
## if true, camera movement by mouse stops and the cursor becomes active
@export var cursor_activated : bool = false

## This script is intended to be in a child of a Controls node, which is a child of a character
## This variable gets that character
@onready var character = get_node("../../Character")

func _ready() -> void:
	if not character:
		print("No character found for controls")
		set_process(false)

	toggle_mouse_mode(false)

	mouse_x_deadzone *= mouse_sensitivity


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		character.jump()

	var input_direction : Vector2 = Input.get_vector(
			"move_left",
			"move_right",
			"move_forward",
			"move_back"
		)
	
	var direction : Vector3 = (
			character.transform.basis * Vector3(input_direction.x, 0, input_direction.y)
		).normalized()
	character.move(direction)


func _unhandled_input(event: InputEvent) -> void:
	# Mouselook implemented using `screen_relative` for resolution-independent sensitivity.
	if event is InputEventMouseMotion and not cursor_activated:
		if character.mouse_turn_enabled:
			var mouse_x = apply_deadzone(event.screen_relative.x * 0.001 * mouse_sensitivity, mouse_x_deadzone)
			character.turn(mouse_x)

## This method used when mouse input is detected and ignores input within the + or - deadzone
func apply_deadzone(value : float, deadzone : float) -> float:
	if (value < 0 and value > -deadzone) or (value > 0 and value < deadzone):
		return 0
	else:
		return value

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("activate_cursor"):
		toggle_mouse_mode()
	if event.is_action_pressed("pause"):
		pause()
	if event.is_action_pressed("next_camera"):
		character.switch_camera(character.NEXT_CAMERA)
	# if event.is_action_pressed("prev_camera"):
	# 	character.switch_camera(character.PREV_CAMERA)
	# if event.is_action_pressed("first_person"):
	# 	character.switch_camera(character.FIRST_CAMERA)
	# if event.is_action_pressed("top_down"):
	# 	character.switch_camera(character.SECOND_CAMERA)
	# if event.is_action_pressed("third_person"):
	# 	character.switch_camera(character.THIRD_CAMERA)


## toggles the cursor visibility
func toggle_mouse_mode(toggle_cursor : bool = true) -> void:
	if toggle_cursor:
		cursor_activated = not cursor_activated

	if cursor_activated:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Allows the cursor to escape the game window
func pause() -> void:
	cursor_activated = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
