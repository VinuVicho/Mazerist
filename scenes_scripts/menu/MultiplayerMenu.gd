extends Control


func _on_createLobby_button_pressed() -> void:
	var container := $TabContainer/MultiplayerMainScreen/VBoxContainer/HBoxContainer/CreateNewLobbyContainer/HBoxContainer/VBoxContainer/LobbyRequestContainer
	var lobbyRequest := LobbyRequest.new()
	#TODO: make this via 'Acces as unique name', probably faster?
	lobbyRequest.lobbyName = container.get_node("LobbyNameEdit").text
	lobbyRequest.lobbyPassword = container.get_node("LobbyPasswordEdit").text
	lobbyRequest.fieldRequest.minSizeX = container.get_node("FieldMinSizeXSelector").value
	lobbyRequest.fieldRequest.minSizeY = container.get_node("FieldMinSizeYSelector").value
	lobbyRequest.fieldRequest.maxSizeX = container.get_node("FieldMaxSizeXSelector").value
	lobbyRequest.fieldRequest.maxSizeY = container.get_node("FieldMaxSizeYSelector").value
	lobbyRequest.fieldRequest.fieldSeed = container.get_node("FieldSeedSelector").value
	lobbyRequest.fieldRequest.playersNumber = container.get_node("PlayersNumberSelector").value
	lobbyRequest.fieldRequest.wallsPercentage = container.get_node("FieldWallsPercentageSelector").value
	lobbyRequest.fieldRequest.fieldGenerationType = container.get_node("FieldGenerationTypeSelector").selected
	lobbyRequest.fieldRequest.playersPositionType = container.get_node("PlayersPositionTypeSelector").selected
	Logger.log_with_color(lobbyRequest, "ORANGE")
	var createdLobby = await Global.webService.createLobby(lobbyRequest)
	
	#TODO: change view to Lobby


