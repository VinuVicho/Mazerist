extends PanelContainer

var currentDisplayerId: int
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
	var player: PlayerDTO = await Global.webService.getPlayerProfile(playerId)
	if player == null: 
		%ExceptionDisplayer.displayError("Player with id " + str(playerId) + " was not found")
		return
	hide_main_container()			#TODO: probably at beggining hide and show loading anumation till here
	$VBoxContainer/HBoxContainer/PlayerProfile.visible = true
	$VBoxContainer/HBoxContainer/PlayerProfile/PlayerName.text = player.username
	currentDisplayerId = player.playerId

func get_and_display_lobby(lobbyId: int):
	var lobby: LobbyDTO = await Global.webService.getLobby(lobbyId)
	if lobby == null: 
		%ExceptionDisplayer.displayError("Lobby with id " + str(lobbyId) + " was not found")
		return
	hide_main_container()			#TODO: probably at beggining hide and show loading anumation till here
	$VBoxContainer/HBoxContainer/GameInfoContainer.visible = true
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/LobbyNameLabel.text = lobby.lobbyName
	
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbySettingsContainer/LobbySettings.text = lobby.lobbySettings.to_string()
	#TODO: display normally lobbySettings 
	
	#lobbyPassword
	$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/VBoxContainer/PasswordField.text = ""
	if lobby.hasPassword:
		$VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/VBoxContainer/PasswordField.visible = true
	else: $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/VBoxContainer/PasswordField.visible = false
	
	currentDisplayerId = lobby.lobbyId
	
	#lobby players
	var list = $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbyPlayersContainer/LobbyPlayersList/VBoxContainer
	for nodeItem in list.get_children():
		nodeItem.free()
	var spectatorslist = $VBoxContainer/HBoxContainer/GameInfoContainer/VBoxContainer/HBoxContainer/LobbyPlayersContainer/LobbySpectatorsList/VBoxContainer
	for nodeItem in spectatorslist.get_children():
		nodeItem.free()
	
	for player in lobby.players:
		var newButton = Button.new()
		newButton.text = player.username
		newButton.name = "Player" + str(player.playerId)
		newButton.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		newButton.pressed.connect(get_and_display_player.bind(player.playerId))
		if player.playerId == lobby.lobbyOwnerId:
			newButton.icon = load("res://icon.svg")
			newButton.expand_icon = true
		if player.isSpectator:
			spectatorslist.add_child(newButton)
		else: 
			list.add_child(newButton)
			newButton.self_modulate = Color.from_string(player.color, Color.WHITE)
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


func hide_main_container():
	$VBoxContainer/HBoxContainer/GameInfoContainer.visible = false
	$VBoxContainer/HBoxContainer/PlayerProfile.visible = false
	$VBoxContainer/HBoxContainer/CreateNewLobbyContainer.visible = false
