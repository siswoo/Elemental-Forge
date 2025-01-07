extends Node
@export var cancelarButton: Button
@export var ingresarButton: Button
@export var registrarButton: Button
@export var loginOption_button: Button
@export var registerOption_button: Button
@export var statusInfo: Label
@export var userText: LineEdit
@export var correoText: LineEdit
@export var passwordText: LineEdit
@export var correo_HB: HBoxContainer
@export var usuario_HB: HBoxContainer
@export var http_request: HTTPRequest
var status_send = ""
func _ready() -> void:
	switch_registerLogin("login")
	cancelarButton.pressed.connect(changeScene)
	ingresarButton.pressed.connect(_login_veri)
	registrarButton.pressed.connect(_register_veri)
	registerOption_button.pressed.connect(switch_registerLogin.bind("register"))
	loginOption_button.pressed.connect(switch_registerLogin.bind("login"))
	http_request.request_completed.connect(_on_request_completed)

func _login_veri()->void:
	var correo_text = correoText.text
	var password_text = passwordText.text
	if correo_text.length() == 0 or password_text.length() == 0:
		_errorInfo_text(1,"Indique un usuario y password validos")
	else:
		var url = "http://localhost/elemental_forge/login.php"
		var body = {"Email": correo_text, "Password": password_text}
		var json_body = JSON.stringify(body)
		var headers = ["Content-Type: application/x-www-form-urlencoded"]
		status_send = "login"
		var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
		if error != OK:
			print("Error al realizar la solicitud: ", error)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var response_text = body.get_string_from_utf8()
	var parse_result = json.parse(response_text)
	var response = json.data
	var respuestaJson = json.parse_string(response_text)
	var status_response = respuestaJson["status"]
	var message_response = respuestaJson["message"]
	if response_code == 404:
		_errorInfo_text(1,"Verifique la conexión")
		return
	if status_response == "error":
		_errorInfo_text(1,message_response)
		return
	if response_code == 200 and response["status"] == "success" and status_send == "login":
		_errorInfo_text(1,"Login exitoso, token: "+response["token"])
		return
	elif response_code == 200 and response["status"] == "success" and status_send == "register":
		_errorInfo_text(1,"Registro exitoso")
		return

func _errorInfo_text(condition,texto)->void:
	if condition == 1:
		statusInfo.text = texto
	statusInfo.set("theme_override_colors/font_color", Color.DODGER_BLUE)
	await get_tree().create_timer(3).timeout
	statusInfo.text = ""

func _register_veri()->void:
	var user_text = userText.text
	var correo_text = correoText.text
	var password_text = passwordText.text
	if user_text == "" or correo_text == "" or password_text == "":
		_errorInfo_text(1,"Indique un usuario, correo y password validos")
	else:
		var url = "http://localhost/elemental_forge/register.php"
		var body = {"Username": user_text, "Email": correo_text, "Password": password_text}
		var json_body = JSON.stringify(body)
		var headers = ["Content-Type: application/x-www-form-urlencoded"]
		var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
		status_send = "register"
		if error != OK:
			print("Error al realizar la solicitud: ", error)

func switch_registerLogin(condition)->void:
	if condition == "register":
		usuario_HB.visible = true
		registrarButton.visible = true
		loginOption_button.visible = true
		ingresarButton.visible = false
		registerOption_button.visible = false
	elif condition == "login":
		usuario_HB.visible = false
		registrarButton.visible = false
		loginOption_button.visible = false
		ingresarButton.visible = true
		registerOption_button.visible = true

func changeScene()->void:
	get_tree().change_scene_to_file("res://Config/Initial.tscn")
