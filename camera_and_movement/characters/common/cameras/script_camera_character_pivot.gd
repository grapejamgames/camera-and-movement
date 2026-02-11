## A Node3D at the root of character camera scene
##
## Used in default character. Handles general movement and behavior.
class_name CharacterCameraPivot

extends Node3D

## Delta multiplier to speed up movement
@export var reset_speed : float = 1
## The number of seconds before camera starts to reset itself
@export var reset_delay : float = 2
## If true, camera will move itself back to initial position after a delay
@export var auto_reset : bool = true
## If true, the camera will follow mouse movement otherwise the camera is locked in position
@export var unlocked : bool = false
## The limit in radians of rotation.x
@export var tilt_limit : float
## The limit in radians of rotation.y
@export var turn_limit : float
## If true, the camera will only move if its owner is moving.
## Stopping will stop the movement momentarily, but not restart the delay timer 
@export var reset_only_while_moving : bool = true
## If true, the camera will reset even when in unloked mode
@export var reset_only_while_locked : bool = true

## The timer that handles reset delay
@onready var delay_timer : Timer = $Timer

## If true, the camera will follow mouse movement
## This behaves the same as unlocked but is intended to be used as hold instead of a toggle
var free_look : bool = false
## This sets to true when timer.timeout is emitted and is reset when needed.
var delay_timer_expired : bool = false


func _ready() -> void:
	delay_timer.wait_time = reset_delay
	if not delay_timer.timeout.is_connected(_on_timer_timeout):
		delay_timer.timeout.connect(_on_timer_timeout)


func _physics_process(delta: float) -> void:
	if should_auto_reset():
		if delay_timer_expired:
			reset_camera(delta)
		else:
			set_timer()


## Checks if all required settings exist to allow auto reset
## Returns true if should reset and false if not
func should_auto_reset() -> bool:
	if free_look:
		return false
	if not auto_reset:
		return false
	if reset_only_while_locked and unlocked:
		return false
	if reset_only_while_moving and not is_owner_moving():
		return false
	return true


## Checks if this node's owner is moving
func is_owner_moving() -> bool:
	if owner:
		return owner.velocity != Vector3()
	else:
		return false


## Moves rotation toward 0
func reset_camera(delta : float) -> void:
	rotation = rotation.move_toward(Vector3(), delta * reset_speed)


## Starts the delay timer if it isn't running
func set_timer() -> void:
	if delay_timer.is_stopped():
		delay_timer.start()


## Sets delay_timer_expired to true
func _on_timer_timeout() -> void:
	delay_timer_expired = true


## Checks if mouse movement should be used. 
## Resets the delay timer for auto align and rotates to the given position
func follow_mouse(mouse_position : Vector2) -> void:
	if free_look or unlocked:
		reset_delay_reset()
		rotate_camera(mouse_position)

## Resets the delay timer in charge of reseting the camera
## What a silly name.
func reset_delay_reset() -> void:
	delay_timer.stop()
	delay_timer_expired = false


## Set x and y rotation to the given vector
func rotate_camera(to_position : Vector2) -> void:
	rotation.x -= to_position.y 
	rotation.x = clampf(rotation.x, -tilt_limit, tilt_limit)
	rotation.y += -to_position.x
	rotation.y = clampf(rotation.y, -turn_limit, turn_limit)
