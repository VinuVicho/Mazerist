class_name IGameService extends Node2D

var gameUI: GameUI
var webService: WebService


func _init() -> void:
	Global.gameService = self

func loadGame(game: GameDTO) -> bool:
	Logger.log_error("Implement this method")
	return false

func endGame() -> bool:
	Logger.log_error("Implement this method")
	return false

func cleanField() -> bool:
	Logger.log_error("Implement this method")
	return false

func watchReplay() -> bool:
	Logger.log_error("Implement this method")
	return false

func submitReplay() -> bool:
	Logger.log_error("Implement this method")
	return false

func startGame() -> bool:
	Logger.log_error("Implement this method")
	return false

func removeMyReplay() -> bool:
	Logger.log_error("Implement this method")
	return false

func reloadGame() -> bool:
	Logger.log_error("Implement this method")
	return false
