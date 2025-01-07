extends Node
@export var cancelarButton: Button
func _ready() -> void:
	cancelarButton.pressed.connect(changeScene)
	
func changeScene()->void:
	get_tree().change_scene_to_file("res://Config/Initial.tscn")
