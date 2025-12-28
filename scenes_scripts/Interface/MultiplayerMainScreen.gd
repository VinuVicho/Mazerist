extends PanelContainer

@onready var webService: WebService = Global.webService
var currentDisplayerId: int = 0
var to_display_hashId: int = 0									#LastClickId. Assign before request, and match it after receiving
var holder: Enums.Holder = Enums.Holder.NOT_ASSIGNED			#That one detailed info
var listHolder: Enums.Holder = Enums.Holder.NOT_ASSIGNED		#List of search results. Probably not needed

func _ready() -> void:
	hide_main_container()

func _on_create_lobby_button_pressed() -> void:
	$VBoxContainer/HBoxContainer/CreateNewLobbyContainer/HBoxContainer/VBoxContainer/CreateLobbyButton.disabled = true
	var container := $VBoxContainer/HBoxContainer/CreateNewLobbyContainer/HBoxContainer/VBoxContainer/LobbyRequestContainer
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
	var createdLobby = await Global.webService.createLobby(lobbyRequest)
	if createdLobby != null:
		displayLobby(createdLobby)
		hide_main_container()
		$VBoxContainer/HBoxContainer/LobbyInfoContainer.visible = true
	
	$VBoxContainer/HBoxContainer/CreateNewLobbyContainer/HBoxContainer/VBoxContainer/CreateLobbyButton.disabled = false

func _on_hide_found_results_toggled(toggled_on: bool) -> void:
	$VBoxContainer/HBoxContainer/ListColumn.visible = !toggled_on

func _on_my_profile_button_pressed() -> void:
	hide_main_container()
	
	var playerProfile: PlayerDTO = await webService.getMyProfile()
	if playerProfile == null:
		MyLogger.log_error("Your profile not found...")
		Global.interfaceService.exit_multiplayer()
		return
	Global.playerId = playerProfile.playerId
	$VBoxContainer/HBoxContainer/PlayerProfile/PlayerName.text = playerProfile.username
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.color = Color.from_string(playerProfile.color, Color.WHITE)
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.disabled = false
	
	$VBoxContainer/HBoxContainer/PlayerProfile.visible = true
	
	_on_send_search_button_pressed()
	#TODO: show his games in searchResult (probably)

func _on_join_button_pressed() -> void:
	var joinRequest := LobbyRequest.new()
	joinRequest.lobbyId = currentDisplayerId
	joinRequest.lobbyPassword = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/VBoxContainer/PasswordField.text
	var resultLobby = await webService.joinLobby(joinRequest)
	if resultLobby == null:
		return
	displayLobby(resultLobby)

func _on_send_search_button_pressed() -> void:
	var list := $VBoxContainer/HBoxContainer/ListColumn/ListContainer/List
	for nodeItem in list.get_children():
		nodeItem.queue_free()
	
	var priorityDictionary: Dictionary = {0: [], 1: [], 2: []}
	
	#Getting PLayers
	if $VBoxContainer/HBoxContainer/MultiplayerMenu/HBoxContainer/SearchForOptions.selected == 1:
		var playerList: Array[PlayerDTO] = await Global.webService.getAllPlayers()
		if playerList.size() == 0: MyLogger.log_warning("empty responce")
		
		for player in playerList:
			var newButton = Button.new()
			newButton.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			newButton.text = player.username
			newButton.name = "Player" + str(player.playerId)
			list.add_child(newButton)
			newButton.pressed.connect(get_and_display_player.bind(player.playerId))
			#TODO: probbaly make some coloring based on last online
		listHolder = Enums.Holder.PLAYER
		return
	
	#region Getting Games
	if $VBoxContainer/HBoxContainer/MultiplayerMenu/HBoxContainer/SearchForOptions.selected == 2:
		var gamesList: Array[GameWithStatusAction]
		if $VBoxContainer/HBoxContainer/MultiplayerMenu/WithMeCheckBox.button_pressed:
			gamesList = await webService.getMyGames()
		else: 
			gamesList = await webService.getAllGames()
		
		for game in gamesList:
			var newButton = Button.new()
			newButton.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			newButton.text = str(game.gameId)
			newButton.name = "Game" + str(game.gameId)
			newButton.pressed.connect(get_and_show_game.bind(game.gameId))
			match game.statusAction:
				Enums.GameStatusAction.MY_TURN: 
					newButton.self_modulate = Color.SEA_GREEN
					newButton.tooltip_text = "It's your turn!"
					priorityDictionary[0].append(newButton)
				Enums.GameStatusAction.END_TURN: 
					if game.gameFinished:
						newButton.self_modulate = Color.FIREBRICK
						newButton.tooltip_text = "This game is finished"
						priorityDictionary[2].append(newButton)
					else: 
						if (game.gameCreatorId == Global.playerId):
							newButton.self_modulate = Color.LIGHT_GREEN
							newButton.tooltip_text = "You have to verify this game replay"
							priorityDictionary[0].append(newButton)
						else: 
							newButton.self_modulate = Color.LIGHT_YELLOW
							newButton.tooltip_text = "Waiting for game owner to verify this game"
							priorityDictionary[1].append(newButton)
		listHolder = Enums.Holder.GAME
		#Adding to the list by button priority
		for priorityArray in priorityDictionary:
			for newButton in priorityDictionary[priorityArray]:
				list.add_child(newButton)
		return
	#endregion
	
	#region Getting Lobbies
	var resultList: Array[LobbyDTO] 
	if $VBoxContainer/HBoxContainer/MultiplayerMenu/WithMeCheckBox.button_pressed:
		resultList = await Global.webService.getMyLobbies()
	else: 
		resultList = await Global.webService.getAllLobbies()
	if resultList.size() == 0: MyLogger.log_warning("empty responce")
	
	for lobby in resultList:
		var newButton = Button.new()
		newButton.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		newButton.text = lobby.lobbyName
		newButton.name = "Lobby" + str(lobby.lobbyId)
		
		newButton.pressed.connect(get_and_display_lobby.bind(lobby.lobbyId))
		match lobby.lobbyStatus:
			Enums.LobbyStatus.GAME:
				newButton.self_modulate = Color.LIGHT_BLUE
				newButton.tooltip_text = "Game in this lobby already started"
				priorityDictionary[2].append(newButton)
			Enums.LobbyStatus.LOBBY:
				if lobby.hasPassword:
					newButton.self_modulate = Color.FIREBRICK
					newButton.tooltip_text = "This lobby is protected by password"
					priorityDictionary[1].append(newButton)
				else:
					priorityDictionary[0].append(newButton)
			_: 
				newButton.self_modulate = Color.RED
				newButton.tooltip_text = "Hmm, very strange lobby status"
				priorityDictionary[2].append(newButton)
	listHolder = Enums.Holder.LOBBY
	#endregion
	
	#Adding to the list by button priority
	for priorityArray in priorityDictionary:
		for newButton in priorityDictionary[priorityArray]:
			list.add_child(newButton)
	
	#TODO: perform search

func get_and_display_player(playerId: int) -> void:
	var player: PlayerDTO = await webService.getPlayerProfile(playerId)
	display_player(player)

func display_player(player: PlayerDTO) -> void:
	if player == null: 
		MyLogger.log_warning("Player was not found")
		return
	hide_main_container()			#TODO: probably at beggining hide and show loading anumation till here
	$VBoxContainer/HBoxContainer/PlayerProfile.visible = true
	
	$VBoxContainer/HBoxContainer/PlayerProfile/PlayerName.text = player.username
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.color = Color.from_string(player.color, Color.WHITE)
	
	var isItMyProfile := player.playerId == Global.playerId
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.disabled = !isItMyProfile
	$VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/UpdateProfileButton.visible = isItMyProfile
	currentDisplayerId = player.playerId
	pass

func get_and_display_lobby(lobbyId: int) -> void:
	var lobby: LobbyDTO = await webService.getLobby(lobbyId)
	if lobby == null: 
		MyLogger.log_warning("Lobby with id " + str(lobbyId) + " was not found")
		return
	displayLobby(lobby)

func displayLobby(lobby: LobbyDTO) -> void:
	if lobby == null:
		MyLogger.log_warning("No lobby to display")
		return
	hide_main_container()			#TODO: probably at beggining hide and show loading animation till here
	$VBoxContainer/HBoxContainer/LobbyInfoContainer.visible = true
	
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/LobbyNameLabel.text = lobby.lobbyName
	currentDisplayerId = lobby.lobbyId
	
	#Lobby settings
	var container = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/LobbyRequestContainer
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
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/UpdateLobbyInfoButton.visible = isPlayerOwner
	
	var amIJoinedLobby: bool = false
	var playerColor: String
	var amISpectator: bool = false
	#lobby players
	var list = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbyPlayersContainer/LobbyPlayersList/VBoxContainer
	for nodeItem in list.get_children():
		nodeItem.free()
	var spectatorslist = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbyPlayersContainer/LobbySpectatorsList/VBoxContainer
	for nodeItem in spectatorslist.get_children():
		nodeItem.free()
	
	for player in lobby.players:
		if Global.playerId == player.playerId && player.color != null:
			amIJoinedLobby = true
			playerColor = player.color
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
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/ColorPickerButton.visible = amIJoinedLobby
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/UpdateMyColorInLobbyButton.visible = amIJoinedLobby
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/BecomeSpectatorButton.visible = amIJoinedLobby && !amISpectator
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/BecomePlayerButton.visible = amIJoinedLobby && amISpectator
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/PasswordContainer.visible = amIJoinedLobby
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/ColorPickerButton.color = Color.from_string(playerColor, Color.WHITE)
	if (lobby.gameId != 0):
		var viewGameButton = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbyPlayersContainer/ViewGameButton
		if viewGameButton.pressed.get_connections():
			viewGameButton.pressed.disconnect(get_and_show_game)
		viewGameButton.pressed.connect(get_and_show_game.bind(lobby.gameId))
		viewGameButton.visible = true
	else:
		$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbyPlayersContainer/ViewGameButton.visible = false
	
	if (lobby.hasPassword):
		$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/PasswordContainer/LobbyPasswordEdit.placeholder_text = "has password"
	else:
		$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/PasswordContainer/LobbyPasswordEdit.placeholder_text = "no password"
	#If playes is owner: edit password
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/UpdatePasswordButton.visible = isPlayerOwner
	$VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/PasswordContainer/LobbyPasswordEdit.editable = isPlayerOwner
	
	## StartGameButton
	var startGameButton = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbyPlayersContainer/StartGameButton
	startGameButton.visible = isPlayerOwner && (lobby.lobbyStatus == 0)
	if startGameButton.pressed.get_connections():
		startGameButton.pressed.disconnect(start_game_button_pressed)
	startGameButton.pressed.connect(start_game_button_pressed.bind(lobby.lobbyId))
	
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
	var joinContainer = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/VBoxContainer
	joinContainer.get_node("PasswordField").text = ""
	joinContainer.get_node("PasswordField").visible = lobby.hasPassword && !amIJoinedLobby
	joinContainer.get_node("JoinAsSpectatorButton").visible = !amIJoinedLobby && !amISpectator
	joinContainer.get_node("JoinButton").visible = !amIJoinedLobby

func hide_main_container() -> void:
	$VBoxContainer/HBoxContainer/LobbyInfoContainer.visible = false
	$VBoxContainer/HBoxContainer/PlayerProfile.visible = false
	$VBoxContainer/HBoxContainer/CreateNewLobbyContainer.visible = false
	$VBoxContainer/HBoxContainer/GameInfoContainer.visible = false

func _on_join_as_spectator_button_pressed() -> void:
	MyLogger.log_error("TODO: join without password, but cant be player (has no color)")


func _on_update_profile_button_pressed() -> void:
	var updateRequest = PlayerUpdateRequest.new()
	updateRequest.color = $VBoxContainer/HBoxContainer/PlayerProfile/GridContainer/ColorPickerButton.color.to_html(false)
	webService.updatePlayer(updateRequest)


func _on_update_my_color_in_lobby_button_pressed() -> void:
	var color = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/ColorPickerButton.color.to_html()
	var updatedLobby = await webService.changeColorInLobby(currentDisplayerId, color)
	displayLobby(updatedLobby)


func _on_update_lobby_info_button_pressed() -> void:
	var container = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/LobbyRequestContainer
	var lobby: LobbyRequest = LobbyRequest.new()
	lobby.lobbyId = currentDisplayerId
	lobby.lobbyName = container.get_node("LobbyNameEdit").text
	lobby.fieldRequest.minSizeX = container.get_node("FieldMinSizeXSelector").value
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
	var request := LobbyRequest.new()
	request.lobbyId = currentDisplayerId
	request.lobbyPassword = $VBoxContainer/HBoxContainer/LobbyInfoContainer/VBoxContainer/HBoxContainer/LobbySettings/PasswordContainer/LobbyPasswordEdit.text
	var updatedLobby = await webService.changePasswordForLobby(request)
	displayLobby(updatedLobby)


func start_game_button_pressed(lobbyId: int) -> void:
	var game: GameDTO = await webService.startGameInLobby(lobbyId)
	if game != null:
		display_game(game)
	else:
		MyLogger.log_warning("There was a problem starting game - game is null")

func get_and_show_game(gameId: int) -> void:
	var game: GameDTO = await webService.getGameBasicInfo(gameId)
	display_game(game)

func _on_open_create_lobby_window_button_pressed() -> void:
	hide_main_container()
	$VBoxContainer/HBoxContainer/CreateNewLobbyContainer.visible = true

func display_game(game: GameDTO) -> void:
	if game == null: 
		MyLogger.log_warning("Game is null")
		return
	hide_main_container()			#TODO: probably at beggining hide and show loading animation till here
	$VBoxContainer/HBoxContainer/GameInfoContainer.visible = true
	
	$VBoxContainer/HBoxContainer/GameInfoContainer/HBoxContainer/VBoxContainer/GameIdDisplayer.text = "Game id: " + str(game.gameId)
	if game.gameFinished:
		$VBoxContainer/HBoxContainer/GameInfoContainer/HBoxContainer/VBoxContainer/StateOfGameLabel.text = "Game finished"
	else: 
		$VBoxContainer/HBoxContainer/GameInfoContainer/HBoxContainer/VBoxContainer/StateOfGameLabel.text = "Game turn: " + str(game.gameTurn)
	
	## ReplayButton
	var viewGameButton = $VBoxContainer/HBoxContainer/GameInfoContainer/HBoxContainer/VBoxContainer/ViewReplayButton
	if viewGameButton.pressed.get_connections():
		viewGameButton.pressed.disconnect(view_button_pressed)
	viewGameButton.pressed.connect(view_button_pressed.bind(game.gameId))
	
	## Players and scores
	var container = $VBoxContainer/HBoxContainer/GameInfoContainer/HBoxContainer/VBoxContainer/GridContainer
	for nodeItem in container.get_children().slice(3):
		nodeItem.queue_free()
	
	for player in game.players:
		## Player button
		var newButton = Button.new()
		newButton.text = player.username
		newButton.name = "Player" + str(player.playerId)
		newButton.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		newButton.pressed.connect(get_and_display_player.bind(player.playerId))
		newButton.self_modulate = Color.from_string(player.color, Color.WHITE)
		if player.playerId == game.gameCreatorId:
			newButton.icon = load("res://icon.svg")
			newButton.expand_icon = true
		container.add_child(newButton)
		## Label-score
		var newLabel = Label.new()
		newLabel.text = str(player.score)
		newLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(newLabel)
		## Label-turnsCompleted
		newLabel = newLabel.duplicate()
		newLabel.text = str(player.turnsCompleted)
		if player.turnsCompleted != game.gameTurn: 
			newLabel.self_modulate = Color.FIREBRICK
		container.add_child(newLabel)

func view_button_pressed(gameId: int) -> void:
	var game = await webService.getFullGame(gameId)
	if game == null:
		MyLogger.log_warning("Game not found with id: " + str(gameId))
		return
	
	## Load game
	if Global.gameService.loadGame(game):
		Global.interfaceService.changeGameState(Enums.ProgramState.GAME)
		return
	
	MyLogger.log_error("Loading game failed")


func _on_option_button_item_selected(index: int) -> void:
	$VBoxContainer/HBoxContainer/MultiplayerMenu/WithMeCheckBox.disabled = index == 1
