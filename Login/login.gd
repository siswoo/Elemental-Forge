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
@export var playfabEvent: PlayFabEvent
func _ready() -> void:
	switch_registerLogin("login")
	cancelarButton.pressed.connect(changeScene)
	ingresarButton.pressed.connect(_login_veri)
	registrarButton.pressed.connect(_register_veri)
	registerOption_button.pressed.connect(switch_registerLogin.bind("register"))
	loginOption_button.pressed.connect(switch_registerLogin.bind("login"))
	PlayFabManager.client.connect("logged_in",_on_login)
	PlayFabManager.client.connect("api_error",_on_api_error)
	PlayFabManager.client.connect("server_error",_on_server_error)

func _login_veri()->void:
	var correo_text = correoText.text
	var password_text = passwordText.text
	if correo_text.length() == 0 or password_text.length() == 0:
		_errorInfo_text(1)
	else:
		var custom_tags = {}
		var info_request_parameters = GetPlayerCombinedInfoRequestParams.new()
		PlayFabManager.client.login_with_email(
			correo_text,
			password_text,
			custom_tags,
			info_request_parameters
		)
		var request = {
			"Username": correo_text,
			"Password": password_text,
			"TitleId": "48895",
		}
		#PlayFabManager.client.login_anonymous()

func _errorInfo_text(condition)->void:
	if condition == 1:
		statusInfo.text = "Indique un usuario y password validos"
	statusInfo.set("theme_override_colors/font_color", Color.DODGER_BLUE)

func _on_login(result: LoginResult):
	statusInfo.text = "Logged in"
	statusInfo.set("theme_override_colors/font_color", Color.WEB_GREEN)
	_send_event()

func _register_veri()->void:
	var user_text = userText.text
	var correo_text = correoText.text
	var password_text = passwordText.text
	if user_text == "" or correo_text == "" or password_text == "":
		_errorInfo_text(1)
	else:
		PlayFabManager.client.register_email_password(user_text, correo_text, password_text, GetPlayerCombinedInfoRequestParams.new())

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

func _on_api_error(error_wrapper: ApiErrorWrapper):
	match error_wrapper.errorCode:
		"InvalidUsernameOrPassword":
			statusInfo.text = "Usuario o contraseña incorrectos."
			statusInfo.set("theme_override_colors/font_color", Color.RED)
		"AccountNotFound":
			statusInfo.text = "La cuenta no existe."
			statusInfo.set("theme_override_colors/font_color", Color.ORANGE)
		_:
			statusInfo.text = "Error: %s" % error_wrapper.errorMessage
			statusInfo.set("theme_override_colors/font_color", Color.RED)

func _on_server_error(error_wrapper: ApiErrorWrapper):
	print_debug(error_wrapper)
	
func changeScene()->void:
	get_tree().change_scene_to_file("res://Config/Initial.tscn")

func _send_event()->void:
	var event_name = "Prueba"
	var payload = {
		"Usuario": correoText.text,
		"Password": passwordText.text,
	}
	playfabEvent.write_title_player_playstream_event(event_name, payload, func(response): prints("event send"))
