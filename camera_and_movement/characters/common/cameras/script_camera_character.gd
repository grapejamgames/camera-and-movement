## A Camera3D at the end of a pivot and spring arm
##
## Used in default character
class_name CharacterCamera

extends Camera3D

## Emitted at the end of deactivate()
signal deactivated
## Emitted at the end of activate()
signal activated

@onready var pivot = get_node_or_null("../../")
@onready var arm = get_node_or_null("../")

## Emits a signal when camera becomes current
## Does not check for success
func activate() -> void:
	make_current()
	activated.emit()


## Emits a signal when camera stops being current
## Does not check for success
func deactivate() -> void:
	clear_current()
	deactivated.emit()
