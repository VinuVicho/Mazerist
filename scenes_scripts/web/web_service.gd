class_name WebService extends Node

var simpleHttpRequest: Node
const serverUrl := "https://localhost:7080/"
const headers: PackedStringArray = ["Content-Type: application/json"]
var authentinticated: bool = false 

func _init() -> void:
	Global.webService = self

func _ready() -> void:
	simpleHttpRequest = $SimpleHTTPRequest
	
	#var result = await getPlayerProfile(2)
	#printErrorResponce(str(result))

#region Endpoints

#region Lobby

func getAllLobbies() -> Array[LobbyDTO]:
	const url = "Lobby/all"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toListOfObjects(responce.body_as_json())
	Logger.log_error("Getting all lobbies failed: " + str(responce.status))
	return []

func getMyLobbies() -> Array[LobbyDTO]:
	const url = "Lobby/my"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toListOfObjects(responce.body_as_json())
	Logger.log_error("Getting my lobbies failed: " + str(responce.status))
	return []

func getLobby(lobbyId: int) -> LobbyDTO:
	var url = "Lobby/" + str(lobbyId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	Logger.log_error("Getting my lobbies failed: " + str(responce.status))
	return

func createLobby(lobbyCreateRequest: LobbyRequest) -> LobbyDTO:
	const url = "Lobby/create"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, lobbyCreateRequest.to_string())
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	Logger.log_error("Getting my lobbies failed: " + str(responce.status))
	return

func updateLobby(lobbyUpdateRequest: LobbyRequest) -> LobbyDTO:
	const url = "Lobby/update"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, lobbyUpdateRequest.to_string())
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	Logger.log_error("Updating lobby " + str(lobbyUpdateRequest.lobbyId) + " failed: " + str(responce.status))
	return

func deleteLobby(lobbyId: int) -> bool:
	var url = "Lobby/" + str(lobbyId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_DELETE)
	if responce.success() && !responce.status_err():
		return true
	Logger.log_error("Deleting lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return false

func joinLobby(lobbyJoinRequest: LobbyRequest) -> LobbyDTO:				#Maybe make another request
	const url = "Lobby/join"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, lobbyJoinRequest.to_string())
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	Logger.log_error("Joining lobby " + str(lobbyJoinRequest.lobbyId) + " failed: " + str(responce.status))
	return 

#region lobbyActions

func setReadyInLobby(lobbyId: int, isReady: bool) -> LobbyDTO:
	var url = "Lobby/" + str(lobbyId) + "/ready/" + str(isReady)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	Logger.log_error("Setting readiness in lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

func kickPlayerOutOfLobby(lobbyId: int, playerToRemoveId: int) -> LobbyDTO:
	var url = "Lobby/" + str(lobbyId) + "/kick/" + str(playerToRemoveId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		var respBody = responce.body_as_json()
		if respBody != null:
			return LobbyDTO.toObject(respBody)
		return
	Logger.log_error("Kicking player out of lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

func invitePlayerToLobby(lobbyId: int, playerToInviteId: int) -> LobbyDTO:			#WARNING not works currently
	var url = "Lobby/" + str(lobbyId) + "/invite/" + str(playerToInviteId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	Logger.log_error("Inviting player to lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

func changeColorInLobby(lobbyId: int, color: String) -> LobbyDTO:
	var url = "Lobby/" + str(lobbyId) + "/color/" + color
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	Logger.log_error("Changing color in lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

func switchTeamsInLobby(lobbyId: int, teamId: int) -> LobbyDTO:
	var url = "Lobby/" + str(lobbyId) + "/switchTeams/" + str(teamId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return LobbyDTO.toObject(responce.body_as_json())
	Logger.log_error("Changing color in lobby " + str(lobbyId) + " failed: " + str(responce.status))
	return

#endregion

#endregion

#region Player

func getPlayerProfile(playerId: int) -> PlayerDTO:
	var url = "player/" + str(playerId)
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return PlayerDTO.toObject(responce.body_as_json())
	Logger.log_error("Getting player " + str(playerId) + " failed: " + str(responce.status))
	return

func getMyProfile() -> PlayerDTO:
	const url = "player/me"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return PlayerDTO.toObject(responce.body_as_json())
	Logger.log_error("Getting my profile failed: " + str(responce.status))
	return

func getAllPlayers() -> Array[PlayerDTO]:
	const url = "player/all"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_GET)
	if responce.success() && !responce.status_err():
		return PlayerDTO.toListOfObjects(responce.body_as_json())
	Logger.log_error("Getting all players failed: " + str(responce.status))
	return []

func updatePlayer(playerUpdateRequest: PlayerUpdateRequest) -> PlayerDTO:		#WARNING: not implemented
	const url = "player/update"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, playerUpdateRequest.to_string())
	if responce.success() && !responce.status_err():
		return PlayerDTO.toObject(responce.body_as_json())
	Logger.log_error("Updating my playerInfo failed: " + str(responce.status))
	return

#endregion

#region Auth

func register_player(playerCreateRequest: PlayerCreateRequest) -> PlayerDTO:
	const url = "Auth/register"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, playerCreateRequest.to_string())
	if responce.success() && !responce.status_err():
		return PlayerDTO.toObject(responce.body_as_json())
	Logger.log_error("there was an error registering player: " + str(responce.status) + playerCreateRequest.to_string())
	return

func login_player(playerLoginRequest: PlayerLoginRequest) -> bool:
	const url = "Auth/login"
	var responce: HTTPResult = await send_simle_httpRequest(url, HTTPClient.METHOD_POST, playerLoginRequest.to_string())
	if responce.success() && !responce.status_err():
		addAuthorizationBearer(responce.body_as_string())
		authentinticated = true
		return true
	Logger.log_error("Auth was unsuccessful " + str(responce.status))
	return false

#endregion

#endregion

func send_map_request(request: FieldRequestForGen) -> MapInfo:
	var requestBody = JSON.stringify(request.toJSON());
	var responce: HTTPResult = await send_simle_httpRequest("generate", HTTPClient.METHOD_POST, requestBody)
	Logger.log(responce.status)
	if responce.success() && !responce.status_err():
		return MapInfo.toObject(responce.body_as_json())
	Logger.log_error("Error, bad responce" + str(responce.status))
	return 

#region Helper methods

#func loginTestPlayer():
	#print_rich("[color=orange]AUTO LOGIN USER[/color]")
	#var playerLoginRequest = PlayerLoginRequest.new()
	#playerLoginRequest.login = "string"
	#playerLoginRequest.password = "string"
	#await login_player(playerLoginRequest)

static func print_something() -> String:
	return "WebService print"

func addAuthorizationBearer(JWToken: String):
	var i: int = 0
	for header in headers:
		if (header.begins_with("Auth")):
			headers.set(i, "Authorization: Bearer " + JWToken)
			return
		else: i = i + 1
	headers.append("Authorization: Bearer " + JWToken)

#endregion

			#Probably remove logs here before release
func send_simle_httpRequest(url: String, method := HTTPClient.Method.METHOD_GET, request_data := ""):
	var time_before = Time.get_ticks_msec()
	Logger.log_with_color("Sending request (" + str(time_before) + "): " + url + " " + request_data, "GREEN_YELLOW")
	var thisHttpRequest = simpleHttpRequest.duplicate()
	add_child(thisHttpRequest)
	
	var resp: HTTPResult = await thisHttpRequest.async_request(serverUrl + url, headers, method, request_data)
	Logger.log_with_color("Recieved request (" + str(time_before) + ") in " + str(Time.get_ticks_msec() - time_before) + "ms: " + resp.body_as_string(), "GREEN_YELLOW")
	thisHttpRequest.queue_free()
	if resp.status_err():
		#TODO: error handler
		match resp.status:
			401:
				authentinticated = false
				Logger.log_error("Auth error, log in again")
			404:
				Logger.log_warning("Resource not found for " + url)
			500:
				Logger.log_error("Nah, server down")
		pass
	return resp
