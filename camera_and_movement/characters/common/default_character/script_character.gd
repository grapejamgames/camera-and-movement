## A CharacterBody3D with movement and camera child nodes
class_name PlayableCharacter

extends CharacterBody3D

## An enum represening camera choices. Used to switch cameras
enum {PREVIOUS_CAMERA = -1, NEXT_CAMERA, FIRST_PERSON, TOP_DOWN, THIRD_PERSON}

## The default speed for move_xz, used primarily for walking
@export var walk_speed : float = 5.0
## The velocity that will be applied in the y direction on jump
@export var jump_velocity : float = 4.5
## The camera number representing the active camera
@export_range(1, 3) var active_camera_number: int = THIRD_PERSON
## If true, character will rotate on y axis with mouse movement
@export var mouse_turn_enabled : bool = true
## If true, forward movement will always go toward the center of the the camera view
@export var forward_to_view_enabled : bool = true
## The speed 

## The cameras dictionary has numeric keys. Null values are removed later
@onready var cameras : Dictionary[int, Node] = {
	FIRST_PERSON : get_node_or_null("Cameras/FirstPerson/SpringArm3D/Camera3D"),
	TOP_DOWN : get_node_or_null("Cameras/TopDown/SpringArm3D/Camera3D"),
	THIRD_PERSON : get_node_or_null("Cameras/ThirdPerson/SpringArm3D/Camera3D")
}

func _ready() -> void:
	# Remove empty camera values
	for key in cameras.keys():
		if cameras[key] == null:
			cameras.erase(key)
	# clamps the active camera index after removing null values
	active_camera_number = clampi(active_camera_number, 0, cameras.size())

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


## If on floor apply apply jump_velocity in the y axis
func jump() -> void:
	if is_on_floor():
		velocity.y = jump_velocity


## Moves the character in the x and z planes.
## Takes a vector 3 for direction but does not use y value
## Speed can be specified, but defaults to walk_speed
func move_xz(direction : Vector3, speed : float = walk_speed) -> void:
	direction *= Vector3(1, 0, 1)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


## Moves the character. Checks if player should face a direction and initiates xz move
func move(direction : Vector3) -> void:
	if forward_to_view_enabled and is_moving_forward(direction):
		face_camera(get_physics_process_delta_time())
	move_xz(direction)


## Turns character toward the forward vector for the camera which is the center of the camera view
## in most cases.
func face_camera(turn_speed : float) -> void:
	var camera_forward : Vector3 = -(cameras[active_camera_number].global_transform.basis.z)
	var character_forward : Vector3 = -global_transform.basis.z
	var angle_to_target : float = acos(camera_forward.dot(character_forward))
	var camera_local_forward : Vector3 = -(cameras[active_camera_number].pivot.transform.basis.z)
	if camera_local_forward.x > 0:
		# turn right
		turn(angle_to_target * turn_speed)
	elif camera_local_forward.x < 0:
		# turn left
		turn(-(angle_to_target * turn_speed))
	else:
		pass


## Returns true if moving forward.
func is_moving_forward(direction : Vector3) -> bool:
	var unit_dir = direction.normalized()
	var facing = -(global_transform.basis.z)
	return unit_dir.dot(facing) > 0


## Turns character to face to_position
func turn(to_position : float) -> void:
	rotation.y -= to_position


## Switches camera based on int value. Enum mapped for camera names that
## correspond to camera dictionary keys, 0 for next camera, and -1 for previous camera.
## Loop around at the ends. Return early if no cameras.
func switch_camera(camera_number : int = active_camera_number) -> void:
	if cameras.is_empty():
		print("No cameras found")
		return

	if cameras.size() > 1:
		camera_number = clampi(camera_number, -1, cameras.size())
		match camera_number:
			PREVIOUS_CAMERA:
				if active_camera_number == cameras.keys()[0]:
					camera_number = cameras.keys()[-1]
				else:
					camera_number = active_camera_number - 1
			NEXT_CAMERA:
				if active_camera_number == cameras.keys()[-1]:
					camera_number = cameras.keys()[0]
				else:
					camera_number = active_camera_number + 1
	else:
		camera_number = 1

	deactivate_camera(cameras.get(active_camera_number))
	active_camera_number = camera_number
	activate_camera(cameras.get(active_camera_number))


## Calls the deactivate method on the camera itself if the camera exists.
func deactivate_camera(camera : Node) -> void:
	if camera:
		camera.deactivate()


## Calls the active method on the camera itself. If a null value is passed switch camera to the
## next one. switch_camera() calls activate so these two are recursive.
func activate_camera(camera : Node) -> void:
	if camera:
		camera.activate()
	else:
		switch_camera(NEXT_CAMERA)
	
