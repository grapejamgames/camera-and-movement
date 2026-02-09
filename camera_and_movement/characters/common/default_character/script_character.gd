extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

enum {PREVIOUS_CAMERA = -1, NEXT_CAMERA, FIRST_PERSON, TOP_DOWN, THIRD_PERSON}

@export_range(1, 3) var active_camera: int = THIRD_PERSON

@onready var cameras : Dictionary[int, Node] = {
	FIRST_PERSON : get_node_or_null("Cameras/FirstPerson/SpringArm3D/Camera3D"),
	TOP_DOWN : get_node_or_null("Cameras/TopDown/SpringArm3D/Camera3D"),
	THIRD_PERSON : get_node_or_null("Cameras/ThirdPerson/SpringArm3D/Camera3D")
}

func _ready() -> void:
	for key in cameras.keys():
		if cameras[key] == null:
			cameras.erase(key)
	active_camera = clampi(active_camera, 0, cameras.size())

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
	if cameras.is_empty():
		print("No cameras found")
		return

	if cameras.size() > 1:
		camera_number = clampi(camera_number, -1, cameras.size())
		match camera_number:
			PREVIOUS_CAMERA:
				if active_camera == cameras.keys()[0]:
					camera_number = cameras.keys()[-1]
				else:
					camera_number = active_camera - 1
			NEXT_CAMERA:
				if active_camera == cameras.keys()[-1]:
					camera_number = cameras.keys()[0]
				else:
					camera_number = active_camera + 1
	else:
		camera_number = 1

	deactivate_camera(cameras.get(active_camera))
	active_camera = camera_number
	activate_camera(cameras.get(active_camera))


func deactivate_camera(camera : Node) -> void:
	if camera:
		camera.deactivate()


func activate_camera(camera : Node) -> void:
	if camera:
		camera.activate()
	else:
		switch_camera(NEXT_CAMERA)
	
