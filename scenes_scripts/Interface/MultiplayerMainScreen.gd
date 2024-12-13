extends PanelContainer

@onready var webService: WebService = Global.webService
var currentDisplayerId: int = 0
var holder: Enums.Holder = Enums.Holder.NOT_ASSIGNED			#That one detailed info
var listHolder: Enums.Holder = Enums.Holder.NOT_ASSIGNED		#List of search results. Probably not needed

func _ready() -> void:
	hide_main_container()

func _on_create_lobby_button_pressed() -> void:
	hide_main_container()
	$VBoxContainer/HBoxContainer/CreateNewLobbyContainer.visible = true

func _on_hide_found_results_toggled(toggled_on: bool) -> void:
	$VBoxContainer/HBoxContainer/ListColumn.visible = !toggled_on

func _on_my_profile_button_pressed() -> void:
	hide_main_container()
	
	var playerProfile: PlayerDTO = await webService.getMyProfile()
	Global.playerId = playerProfile.playerId
	$VBoxContainer/HBoxContainer/PlayerProfile/PlayerName.text = playerProfile.username
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.color = Color.from_string(playerProfile.color, Color.WHITE)
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.disabled = false
	
	$VBoxContainer/HBoxContainer/PlayerProfile.visible = true
	
	#TODO: fetch user data (MyProfile)
	#TODO: show his games in searchResult (probably)

func _on_search_players_toggled(toggled_on: bool) -> void:
	$VBoxContainer/HBoxContainer/MultiplayerMenu/MyGamesFilter.disabled = toggled_on
	$VBoxContainer/HBoxContainer/MultiplayerMenu/InLobbyStatusFilter.disabled = toggled_on

func _on_join_button_pressed() -> void:
	var joinRequest := LobbyRequest.new()
	joinRequest.lobbyId = currentDisplayerId
	joinRequest.lobbyPassword = $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/VBoxContainer/PasswordField.text
	var resultLobby = await Global.webService.joinLobby(joinRequest)
	if resultLobby == null:
		print("joining Failed to lobby " + str(joinRequest.lobbyId))
		return
	print("successful join")
	#TODO: move to lobby screen 

func _on_send_search_button_pressed() -> void:
	var list := $VBoxContainer/HBoxContainer/ListColumn/ListContainer/List
	for nodeItem in list.get_children():
		nodeItem.queue_free()
	
	if $VBoxContainer/HBoxContainer/MultiplayerMenu/SearchForPlayersCheck.button_pressed:
		var resultList: Array[PlayerDTO] = await Global.webService.getAllPlayers()
		if resultList.size() == 0: print("empty responce")
		
		for player in resultList:
			var newButton = Button.new()
			newButton.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			newButton.text = player.username
			newButton.name = "Player" + str(player.playerId)
			list.add_child(newButton)
			newButton.pressed.connect(get_and_display_player.bind(player.playerId))
			#TODO: probbaly make some coloring based on last online
		listHolder = Enums.Holder.PLAYER
		return
	
	#Getting Lobbies
	var resultList: Array[LobbyDTO] 
	
	if $VBoxContainer/HBoxContainer/MultiplayerMenu/MyGamesFilter.button_pressed:
		resultList = await Global.webService.getMyLobbies()
	else: resultList = await Global.webService.getAllLobbies()
	if resultList.size() == 0: print("empty responce")
	
	for lobby in resultList:
		var newButton = Button.new()
		newButton.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		newButton.text = lobby.lobbyName
		newButton.name = "Lobby" + str(lobby.lobbyId)
		list.add_child(newButton)
		newButton.pressed.connect(get_and_display_lobby.bind(lobby.lobbyId))
		if lobby.hasPassword:
			newButton.self_modulate = Color.FIREBRICK
	listHolder = Enums.Holder.LOBBY
	
	#TODO: perform search
	pass # Replace with function body.

func get_and_display_player(playerId: int):
	var player: PlayerDTO = await webService.getPlayerProfile(playerId)
	if player == null: 
		%ExceptionDisplayer.displayError("Player with id " + str(playerId) + " was not found")
		return
	hide_main_container()			#TODO: probably at beggining hide and show loading anumation till here
	$VBoxContainer/HBoxContainer/PlayerProfile.visible = true
	$VBoxContainer/HBoxContainer/PlayerProfile/PlayerName.text = player.username
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.color = Color.from_string(player.color, Color.WHITE)
	
	var isItMyProfile := player.playerId == Global.playerId
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.disabled = !isItMyProfile
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/UpdateProfileButton.visible = isItMyProfile
	currentDisplayerId = player.playerId

func get_and_display_lobby(lobbyId: int):
	var lobby: LobbyDTO = await webService.getLobby(lobbyId)
	if lobby == null: 
		%ExceptionDisplayer.displayError("Lobby with id " + str(lobbyId) + " was not found")
		return
	hide_main_container()			#TODO: probably at beggining hide and show loading anumation till here
	$VBoxContainer/HBoxContainer/GameInfoContainer.visible = true
	displayLobby(lobby)

func displayLobby(lobby: LobbyDTO):
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/LobbyNameLabel.text = lobby.lobbyName
	
	currentDisplayerId = lobby.lobbyId
	
	#Lobby settings
	var container = $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/LobbyRequestContainer
	var isPlayerOwner: bool = Global.playerId == lobby.lobbyOwnerId
	
	container.get_node("LobbyNameEdit").text = lobby.lobbyName
	container.get_node("FieldMinSizeXSelector").value = lobby.lobbySettings.minSizeX
	container.get_node("FieldMinSizeYSelector").value = lobby.lobbySettings.minSizeY
	container.get_node("FieldMaxSizeXSelector").value = lobby.lobbySettings.maxSizeX
	container.get_node("FieldMaxSizeYSelector").value = lobby.lobbySettings.maxSizeY
	container.get_node("FieldSeedSelector").value = lobby.lobbySettings.fieldSeed
	container.get_node("PlayersNumberSelector").value = lobby.lobbySettings.playersNumber
	container.get_node("FieldWallsPercentageSelector").value = lobby.lobbySettings.wallsPercentage
	container.get_node("FieldGenerationTypeSelector").selected = lobby.lobbySettings.fieldGenerationType
	container.get_node("PlayersPositionTypeSelector").selected = lobby.lobbySettings.playersPositionType
	
	#update editability for selectors
	for node in container.get_children():
		if (node is SpinBox or node is LineEdit):
			node.editable = isPlayerOwner
		elif (node is OptionButton):
			node.disabled = !isPlayerOwner
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/UpdateLobbyInfoButton.visible = isPlayerOwner
	
	var amIJoinedLobby: bool = false
	var amISpectator: bool = false
	#lobby players
	var list = $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbyPlayersContainer/LobbyPlayersList/VBoxContainer
	for nodeItem in list.get_children():
		nodeItem.free()
	var spectatorslist = $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbyPlayersContainer/LobbySpectatorsList/VBoxContainer
	for nodeItem in spectatorslist.get_children():
		nodeItem.free()
	
	for player in lobby.players:
		if Global.playerId == player.playerId && player.color != null:
			amIJoinedLobby = true
		var newButton = Button.new()
		newButton.text = player.username
		newButton.name = "Player" + str(player.playerId)
		newButton.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		newButton.pressed.connect(get_and_display_player.bind(player.playerId))
		newButton.self_modulate = Color.from_string(player.color, Color.WHITE)
		if player.playerId == lobby.lobbyOwnerId:
			newButton.icon = load("res://icon.svg")
			newButton.expand_icon = true
		if player.isSpectator:
			spectatorslist.add_child(newButton)
			if Global.playerId == player.playerId:
				amISpectator = true
		else: 
			list.add_child(newButton)
			newButton.self_modulate = Color.from_string(player.color, Color.WHITE)
	#If player is in lobby: can change color there
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/ColorPickerButton.visible = amIJoinedLobby
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/UpdateMyColorInLobbyButton.visible = amIJoinedLobby
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/PasswordContainer.visible = amIJoinedLobby
	if (lobby.hasPassword):
		$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/PasswordContainer/LobbyPasswordEdit.placeholder_text = "has password"
	else:
		$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/PasswordContainer/LobbyPasswordEdit.placeholder_text = "no password"
	#If playes is owner: edit password
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/UpdatePasswordButton.visible = isPlayerOwner
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/PasswordContainer/LobbyPasswordEdit.editable = isPlayerOwner
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/BecomeSpectatorButton.visible = amIJoinedLobby && !amISpectator
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/BecomePlayerButton.visible = amIJoinedLobby && amISpectator
	
	if list.get_children().size() == 0:
		var newButton = Button.new()
		newButton.text = "No players currently"
		newButton.disabled = true
		list.add_child(newButton)
	if spectatorslist.get_children().size() == 0:
		var newButton = Button.new()
		newButton.text = "No spectators currently"
		newButton.disabled = true
		spectatorslist.add_child(newButton)
	
	#lobby Join 
	var joinContainer = $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/VBoxContainer
	joinContainer.get_node("PasswordField").text = ""
	joinContainer.get_node("PasswordField").visible = lobby.hasPassword && !amIJoinedLobby
	joinContainer.get_node("JoinAsSpectatorButton").visible = !amIJoinedLobby && !amISpectator
	joinContainer.get_node("JoinButton").visible = !amIJoinedLobby


func hide_main_container():
	$VBoxContainer/HBoxContainer/GameInfoContainer.visible = false
	$VBoxContainer/HBoxContainer/PlayerProfile.visible = false
	$VBoxContainer/HBoxContainer/CreateNewLobbyContainer.visible = false


func _on_join_as_spectator_button_pressed() -> void:
	Logger.log_error("TODO: join without password, but cant be player (has no color)")


func _on_update_profile_button_pressed() -> void:
	var updateRequest = PlayerUpdateRequest.new()
	updateRequest.color = $VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.color.to_html(false)
	webService.updatePlayer(updateRequest)


func _on_update_my_color_in_lobby_button_pressed() -> void:
	var color = $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/ColorPickerButton.color.to_html()
	var updatedLobby = await webService.changeColorInLobby(currentDisplayerId, color)
	displayLobby(updatedLobby)


func _on_update_lobby_info_button_pressed() -> void:
	var container = $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/LobbyRequestContainer
	var lobby: LobbyRequest = LobbyRequest.new()
	lobby.lobbyId = currentDisplayerId
	lobby.lobbyName = container.get_node("LobbyNameEdit").text
	lobby.fieldRequest.maxSizeX = container.get_node("FieldMinSizeXSelector").value
	lobby.fieldRequest.minSizeY = container.get_node("FieldMinSizeYSelector").value
	lobby.fieldRequest.maxSizeX = container.get_node("FieldMaxSizeXSelector").value
	lobby.fieldRequest.maxSizeY = container.get_node("FieldMaxSizeYSelector").value
	lobby.fieldRequest.fieldSeed = container.get_node("FieldSeedSelector").value 
	lobby.fieldRequest.playersNumber = container.get_node("PlayersNumberSelector").value
	lobby.fieldRequest.wallsPercentage = container.get_node("FieldWallsPercentageSelector").value
	lobby.fieldRequest.fieldGenerationType = container.get_node("FieldGenerationTypeSelector").selected
	lobby.fieldRequest.playersPositionType = container.get_node("PlayersPositionTypeSelector").selected
	
	var resultLobby = await webService.updateLobby(lobby)
	displayLobby(resultLobby)


func _on_change_team_button_pressed(teamId: int) -> void:
	var updatedLobby = await webService.switchTeamsInLobby(currentDisplayerId, teamId)
	displayLobby(updatedLobby)


func _on_update_password_button_pressed() -> void:
	Logger.log_error("TODO: Create update password thing")
