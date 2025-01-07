extends Node
class_name Config
@export var ipconnect: Button
@export var login: Button
@export var ipconnect_scene: PackedScene
@export var login_scene: PackedScene
func _ready() -> void:
	ipconnect.pressed.connect(changeScene.bind("ipconnect"))
	login.pressed.connect(changeScene.bind("login"))
	
func changeScene(condition)->void:
	if condition == "ipconnect":
		get_tree().change_scene_to_packed(ipconnect_scene)
	elif condition == "login":
		get_tree().change_scene_to_packed(login_scene)
