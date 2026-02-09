extends Node3D

@export_range(1, 10) var mouse_sensitivity : int = 1
@export var cursor_activated : bool = false

@onready var character = get_node("../../Character")

func _ready() -> void:
	if not character:
		print("No character found for controls")
		set_process(false)

	toggle_mouse_mode(false)


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
	if event is InputEventMouseMotion and not cursor_activated :
		character.rotate_character(event.screen_relative.x * mouse_sensitivity * .001)


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


func toggle_mouse_mode(toggle_cursor : bool = true) -> void:
	if toggle_cursor:
		cursor_activated = not cursor_activated

	if cursor_activated:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func pause() -> void:
	cursor_activated = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
