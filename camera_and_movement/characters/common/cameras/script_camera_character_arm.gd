## A SpringArm3D with zoom
##
## Used in default character
class_name CharacterCameraArm

extends SpringArm3D

## Do not zoom in past this point
@export var min_length : float = 1.0
## Do not zoom out past this point
@export var max_length : float = 7.0
## Delta multiplier to speed up movement
@export var zoom_speed : int = 3
## Roughly the number of input events needed to get from min to max.
## (max_length - min_length) / zoom_steps
@export var zoom_steps : float = 14

## Set to the spring_length on ready to reset position
@onready var default_spring_length : float = spring_length
## The target length to move toward
@onready var target : float = spring_length
## The length to move each step (max_length - min_length) / zoom_steps
@onready var step_size : float = (max_length - min_length) / zoom_steps


func _physics_process(delta : float) -> void:
	zoom(delta)


## Move the spring length toward the target over time
func zoom(delta : float) -> void:
	if target != spring_length:
		spring_length = move_toward(spring_length, target, delta * zoom_speed)


## Reduce the target value by step size, but do not go past min length
func zoom_in() -> void:
	# Compute max so zooming in works on first input even when compressed
	var computed_max = max(min_length,	get_hit_length() - step_size)
	spring_length = min(get_hit_length(), spring_length)
	target = clampf(target - step_size, min_length, computed_max)


## Increase the target value by step size, but do not go past max length
func zoom_out() -> void:
	target = clampf(target + step_size, target, max_length)


## Set target to default length
func reset_zoom() -> void:
	target = default_spring_length
