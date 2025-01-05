extends Control

func _on_check_box_toggled(toggled_on: bool) -> void:
	$PanelContainer/VBoxContainer/ColorPickerContainer.visible = !toggled_on
	$PanelContainer/VBoxContainer/UsernameContainer.visible = !toggled_on
	pass

func _on_submit() -> void:
	if $PanelContainer/VBoxContainer2/AlreadyHaveAccountCheckBox.button_pressed:
		perform_LoginRequest()
		return
	perform_CreateAccountRequest()

func perform_LoginRequest():
	var loginRequest := PlayerLoginRequest.new()
	loginRequest.login = $PanelContainer/VBoxContainer/LoginContainer/TextEditLogin.text
	loginRequest.password = $PanelContainer/VBoxContainer/PasswordContainer/TextEditPassword.text
	var isSuccessfull: bool = await Global.webService.login_player(loginRequest)
	if !isSuccessfull:
		Logger.log_error("Login not successful")
		return
	get_parent()._on_multiplayer_button_pressed()

func perform_CreateAccountRequest():
	var createRequest := PlayerCreateRequest.new()
	createRequest.login = $PanelContainer/VBoxContainer/LoginContainer/TextEditLogin.text
	createRequest.password = $PanelContainer/VBoxContainer/PasswordContainer/TextEditPassword.text
	createRequest.username = $PanelContainer/VBoxContainer/UsernameContainer/TextEditUsername.text
	createRequest.color = $PanelContainer/VBoxContainer/ColorPickerContainer/ColorPickerButton.color.to_html(false)
	var result: PlayerDTO = await Global.webService.register_player(createRequest)
	if (result == null): 
		Logger.log_error("There was an error creating account")
		return
	perform_LoginRequest()
