## Extends playable character and activates initial camera
class_name player

extends PlayableCharacter

@onready var character = $Character


func _ready() -> void:
	character.switch_camera()
