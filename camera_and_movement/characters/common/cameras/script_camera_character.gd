class_name CharacterCamera

extends Camera3D

signal deactivated
signal activated

# Move the pivot instead of the camera itself
func rotate_camera(to_position : Vector2) -> void:
	get_parent().get_parent().rotate_camera(to_position)


func activate() -> void:
	make_current()
	activated.emit()


func deactivate() -> void:
	clear_current()
	deactivated.emit()
