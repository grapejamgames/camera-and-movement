class_name CharacterCameraPivot

extends Node3D

@export_range(0.0, 10.0) var follow_speed : float = 1
@export var follow_delay : float = 2
@export var unlocked : bool = false
@export var auto_align : bool = true
@export var tilt_limit : float
@export var turn_limit : float

@onready var free_look : bool = false
@onready var wind_up_timer : Timer = $Timer

var wind_up_timer_expired : bool = false


func _ready() -> void:
	wind_up_timer.wait_time = follow_delay


func _physics_process(delta: float) -> void:
	if owner.velocity:
		while_parent_moving(delta)


func rotate_camera(to_position : Vector2) -> void:
	rotation.x -= to_position.y 
	rotation.x = clampf(rotation.x, -tilt_limit, tilt_limit)
	rotation.y += -to_position.x
	rotation.y = clampf(rotation.y, -turn_limit, turn_limit)


func follow_parent(delta : float) -> void:
	rotation = rotation.move_toward(Vector3(), delta * follow_speed)


func while_parent_moving(delta : float) -> void:
	if auto_align:
		if not (unlocked or free_look):
			if wind_up_timer_expired:
				follow_parent(delta)
			else:
				if wind_up_timer.is_stopped():
					wind_up_timer.start()


func reset_wind_up() -> void:
	wind_up_timer.stop()
	wind_up_timer_expired = false


func _on_timer_timeout() -> void:
	wind_up_timer_expired = true
