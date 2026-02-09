extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

enum {PREVIOUS_CAMERA = -1, NEXT_CAMERA, FIRST_CAMERA, SECOND_CAMERA, THIRD_CAMERA}

@export_range(1, 3) var active_camera: int = 3

@onready var cameras : Array[Node] = [
	get_node_or_null("Cameras/FirstPerson/SpringArm3D/Camera3D"),
	get_node_or_null("Cameras/TopDown/SpringArm3D/Camera3D"),
	get_node_or_null("Cameras/ThirdPerson/SpringArm3D/Camera3D")
]

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


func move(direction : Vector3) -> void:
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func rotate_character(rotation_delta : float) -> void:
	rotation.y -= rotation_delta


func switch_camera(camera_number : int = active_camera) -> void:
	var cam_index = active_camera - 1
	deactivate_camera(cameras[cam_index])
	match camera_number:
		PREVIOUS_CAMERA:
			active_camera -= 1
			if active_camera < 1:
				active_camera = cameras.size()
		NEXT_CAMERA:
			active_camera += 1
			if active_camera > cameras.size():
				active_camera = 1
		_:
			active_camera = clampi(camera_number, 1, cameras.size())

	cam_index = active_camera - 1
	print(cameras[cam_index])
	if cameras[cam_index]:
		activate_camera(cameras[cam_index])
	else:
		activate_camera(cameras[0])


func deactivate_camera(camera : Node) -> void:
	if camera:
		camera.deactivate()


func activate_camera(camera : Node) -> void:
	if camera:
		camera.activate()
