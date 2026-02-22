## Extends playable character and activates initial camera
class_name player

extends Node3D

@onready var character = $Character


func _ready() -> void:
	character.switch_camera()
