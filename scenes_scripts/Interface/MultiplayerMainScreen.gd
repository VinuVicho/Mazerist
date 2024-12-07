extends PanelContainer



func _on_create_lobby_button_pressed() -> void:
	pass # Replace with function body.

var currentLobbyId: int


func _on_hide_found_results_toggled(toggled_on: bool) -> void:
	$MultiplayerMainScreen/VBoxContainer/HBoxContainer/FoundGamesColumn.visible = !toggled_on


func _on_my_profile_button_pressed() -> void:
	$MultiplayerMainScreen/VBoxContainer/HBoxContainer/PlayerProfile.visible = true
	$MultiplayerMainScreen/VBoxContainer/HBoxContainer/GameInfoContainer.visible = false
	#TODO: fetch user data (MyProfile)
	#TODO: show his games in searchResult (probably)


func _on_search_players_toggled(toggled_on: bool) -> void:
	$MultiplayerMainScreen/VBoxContainer/HBoxContainer/SearchFilters/MyGamesFilter.disabled = toggled_on
	$MultiplayerMainScreen/VBoxContainer/HBoxContainer/SearchFilters/InLobbyStatusFilter.disabled = toggled_on


func _on_join_button_pressed() -> void:
	#TODO: send request to join
	#TODO: If success: move to lobby screen 
	pass # Replace with function body.


func _on_send_search_button_pressed() -> void:
	#TODO: perform search
	pass # Replace with function body.
