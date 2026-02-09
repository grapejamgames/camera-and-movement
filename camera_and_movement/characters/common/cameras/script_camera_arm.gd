extends SpringArm3D

@export var min_length : float = 1.0
@export var default_spring_length : float = 3.0
@export var max_length : float = 7.0
@export var zoom_speed : float = 3
@export var zoom_steps : float = 14

@onready var target : float = default_spring_length
@onready var step_size : float = max_length / zoom_steps


func _physics_process(delta : float) -> void:
	zoom(delta)


func zoom(delta : float) -> void:
	if target != spring_length:
		spring_length = move_toward(spring_length, target, delta * zoom_speed)


func move_target_closer() -> void:
	# Compute a max so if the spring arm is compressed, zoom-in works on first try
	var computed_max = max(min_length,	get_hit_length() - step_size)
	spring_length = min(get_hit_length(), spring_length)
	target = clampf(target - step_size, min_length, computed_max)


func move_target_farther() -> void:
	target = clampf(target + step_size, target, max_length)
