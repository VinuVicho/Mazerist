class_name WebService extends Node

var simpleHttpRequest: Node
const serverUrl := "http://195.72.145.156:8084/"
const headers: PackedStringArray = ["Content-Type: application/json"]
var authentinticated: bool = false 

func _init() -> void:
	Global.webService = self

func _ready() -> void:
	simpleHttpRequest = $SimpleHTTPRequest
	load_saved_token()

#region Endpoints

#region Game

func submitGameReplay(replayDto: SubmitReplayDto) -> GameDTO:
	const url = "Game/submitReplay"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, replayDto.to_string())
	if responce.success() && !responce.status_err():
		return GameDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Submitting replay failed: " + str(responce.status))
	return

func endGameTurn(scoresDto: ScoresDto) -> GameDTO:
	const url = "Game/endTurn"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, scoresDto.to_string())
	if responce.success() && !responce.status_err():
		return GameDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Sending scores failed: " + str(responce.status))
	return

func getAllGames() -> Array[GameWithStatusAction]:
	const url = "Game/all"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return GameWithStatusAction.toListOfObjects(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting all games failed: " + str(responce.status))
	return []

func getMyGames() -> Array[GameWithStatusAction]:
	const url = "Game/my"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return GameWithStatusAction.toListOfObjects(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting my games failed: " + str(responce.status))
	return []

func getGameBasicInfo(gameId: int) -> GameDTO:
	var url = "Game/" + str(gameId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return GameDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting basic info of game failed: " + str(responce.status))
	return

func getFullGame(gameId: int) -> GameDTO:
	var url = "Game/full/" + str(gameId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return GameDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting full game failed: " + str(responce.status))
	return

func deleteGame(gameId: int) -> bool:
	var url = "Game/" + str(gameId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_DELETE)
	if responce.success() && !responce.status_err():
		return true
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Deleting game failed: " + str(responce.status))
	return false

#endregion

#region Lobby

func getAllLobbies() -> Array[LobbyDTO]:
	const url = "Lobby/all"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toListOfObjects(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting all lobbies failed: " + str(responce.status))
	return []

func getMyLobbies() -> Array[LobbyDTO]:
	const url = "Lobby/my"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toListOfObjects(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting my lobbies failed: " + str(responce.status))
	return []

func getLobby(lobbyId: int) -> LobbyDTO:
	var url = "Lobby/" + str(lobbyId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting my lobbies failed: " + str(responce.status))
	return

func createLobby(lobbyCreateRequest: LobbyRequest) -> LobbyDTO:
	const url = "Lobby/create"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, lobbyCreateRequest.to_string())
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting my lobbies failed: " + str(responce.status))
	return

func updateLobby(lobbyUpdateRequest: LobbyRequest) -> LobbyDTO:
	const url = "Lobby/update"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, lobbyUpdateRequest.to_string())
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Updating lobby " + str(lobbyUpdateRequest.lobbyId) + " failed: " + str(responce.status))
	return

func deleteLobby(lobbyId: int) -> bool:
	var url = "Lobby/" + str(lobbyId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_DELETE)
	if responce.success() && !responce.status_err():
		return true
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Deleting lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return false

func joinLobby(lobbyJoinRequest: LobbyRequest) -> LobbyDTO:				#Maybe make another request
	const url = "Lobby/join"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, lobbyJoinRequest.to_string())
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Joining lobby " + str(lobbyJoinRequest.lobbyId) + " failed: " + str(responce.status))
	return 

#region lobbyActions

func setReadyInLobby(lobbyId: int, isReady: bool) -> LobbyDTO:
	var url = "Lobby/" + str(lobbyId) + "/ready/" + str(isReady)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Setting readiness in lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

func kickPlayerOutOfLobby(lobbyId: int, playerToRemoveId: int) -> LobbyDTO:
	var url = "Lobby/" + str(lobbyId) + "/kick/" + str(playerToRemoveId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		var respBody = responce.body_as_json()
		if respBody != null:
			return LobbyDTO.toObject(respBody)
		return
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Kicking player out of lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

func invitePlayerToLobby(lobbyId: int, playerToInviteId: int) -> LobbyDTO:			#WARNING not works currently
	var url = "Lobby/" + str(lobbyId) + "/invite/" + str(playerToInviteId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Inviting player to lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

func changeColorInLobby(lobbyId: int, color: String) -> LobbyDTO:
	var url = "Lobby/" + str(lobbyId) + "/color/" + color
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Changing color in lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

func switchTeamsInLobby(lobbyId: int, teamId: int) -> LobbyDTO:
	var url := "Lobby/" + str(lobbyId) + "/switchTeams/" + str(teamId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Changing color in lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

func changePasswordForLobby(request: LobbyRequest) -> LobbyDTO:
	const url = "Lobby/changePassword"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, request.to_string())
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Changing password in lobby " + str(request.lobbyId) + " failed: " + str(responce.status))
	return

func startGameInLobby(lobbyId: int) -> GameDTO:
	var url := "Lobby/start/" + str(lobbyId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return GameDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Starting game in lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return
#endregion

#endregion

#region Player

func getPlayerProfile(playerId: int) -> PlayerDTO:
	var url = "player/" + str(playerId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return PlayerDTO.toObject(responce.body_as_json())
	
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting player " + str(playerId) + " failed: " + str(responce.status))
	return

func getMyProfile() -> PlayerDTO:
	const url = "player/me"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return PlayerDTO.toObject(responce.body_as_json())
	
	if responce.status == USER_CANCELLED_STATUS_CODE: return
	MyLogger.log_error("Getting my profile failed: " + str(responce.status))
	logOut()
	return

func getAllPlayers() -> Array[PlayerDTO]:
	const url = "player/all"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return PlayerDTO.toListOfObjects(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Getting all players failed: " + str(responce.status))
	return []

func updatePlayer(playerUpdateRequest: PlayerUpdateRequest) -> PlayerDTO:		#WARNING: not implemented
	const url = "player/update"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, playerUpdateRequest.to_string())
	if responce.success() && !responce.status_err():
		return PlayerDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Updating my playerInfo failed: " + str(responce.status))
	return

#endregion

#region Auth

func load_saved_token():
	if !FileAccess.file_exists("user://login_data"):
		return
	var file = FileAccess.open("user://login_data", FileAccess.READ)
	var loadedBearer = file.get_var()
	file.close()
	if loadedBearer != null:
		addAuthorizationBearer(loadedBearer, false)

func register_player(playerCreateRequest: PlayerCreateRequest) -> PlayerDTO:
	const url = "Auth/register"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, playerCreateRequest.to_string())
	if responce.success() && !responce.status_err():
		return PlayerDTO.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("there was an error registering player: " + str(responce.status) + playerCreateRequest.to_string())
	return

func login_player(playerLoginRequest: PlayerLoginRequest) -> bool:
	const url = "Auth/login"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, playerLoginRequest.to_string())
	if responce.success() && !responce.status_err():
		addAuthorizationBearer(responce.body_as_string())
		return true
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Auth was unsuccessful " + str(responce.status))
	return false

func logOut():
	if !FileAccess.file_exists("user://login_data"):
		return
	var file = FileAccess.open("user://login_data", FileAccess.WRITE)
	file.store_var(null)
	file.close()
	
	var i: int = 0
	for header in headers:
		if (header.begins_with("Auth")):
			headers.remove_at(i)
			authentinticated = false
			MyLogger.log("Player loggined out")
			return
		else: i = i + 1

func addAuthorizationBearer(JWToken: String, saveToken: bool = true):
	var i: int = 0
	var headerToAppend = "Authorization: Bearer " + JWToken
	for header in headers:
		if (header.begins_with("Auth")):
			headers.set(i, headerToAppend)
			authentinticated = true
			return
		else: i = i + 1
	headers.append(headerToAppend)
	authentinticated = true
	if saveToken:
		var file = FileAccess.open("user://login_data", FileAccess.WRITE)
		file.store_var(JWToken)
		file.close()

#endregion

#endregion

func send_map_request(request: FieldRequestForGen) -> MapInfo:
	MyLogger.log_warning("WebService send_map_request: Do I really use this?")
	var requestBody = JSON.stringify(request.toJSON());
	var responce: HTTPResult = await send_simle_httpRequest("generate", HTTPClient.METHOD_POST, requestBody)
	MyLogger.log(responce.status)
	if responce.success() && responce.status_ok():
		return MapInfo.toObject(responce.body_as_json())
	
	if responce.status != USER_CANCELLED_STATUS_CODE: 
		MyLogger.log_error("Error, bad responce" + str(responce.status))
	return 

#region Helper methods

#func loginTestPlayer():
	#print_rich("[color=orange]AUTO LOGIN USER[/color]")
	#var playerLoginRequest = PlayerLoginRequest.new()
	#playerLoginRequest.login = "string"
	#playerLoginRequest.password = "string"
	#await login_player(playerLoginRequest)

#endregion

			#Probably remove logs here before release
const USER_CANCELLED_STATUS_CODE = 499
var userLastRequestHash = 0
func send_simle_httpRequest(url: String, method := HTTPClient.Method.METHOD_GET, request_data := "", cancel_previous_request := true):
	var time_before = Time.get_ticks_msec()
	if cancel_previous_request: userLastRequestHash = time_before
	MyLogger.log_with_color("Sending request (" + str(time_before) + "): " + url + " " + request_data, "LIME_GREEN")
	var thisHttpRequest = simpleHttpRequest.duplicate()
	add_child(thisHttpRequest)
	
	var resp: HTTPResult = await thisHttpRequest.async_request(serverUrl + url, headers, method, request_data)
	MyLogger.log_with_color("Recieved request (" + str(time_before) + ") in " + str(Time.get_ticks_msec() - time_before) + "ms: " + resp.body_as_string(), "GREEN_YELLOW")
	thisHttpRequest.queue_free()
	
	if cancel_previous_request && userLastRequestHash != time_before:
		MyLogger.log_warning("Request (" + str(time_before) + ") is cancelled by other action from user: " + str(userLastRequestHash))
		resp.status = USER_CANCELLED_STATUS_CODE
		return resp
	if resp.status_err():
		#TODO: error handler
		match resp.status:
			401:
				authentinticated = false
				MyLogger.log_error("Auth error, log in again", true)
			404:
				MyLogger.log_warning("Resource not found for " + url)
			405: 
				MyLogger.log_error(resp.body_as_json()["message"], true)
			500:
				MyLogger.log_error("Nah, server down")
		pass
	return resp
