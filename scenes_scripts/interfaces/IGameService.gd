class_name IGameService extends Node2D

var gameUI: GameUI
var webService: WebService


func _init() -> void:
	Global.gameService = self

func loadGame(game: GameDTO) -> bool:
	MyLogger.log_error("Implement this method")
	return false

func endGame() -> bool:
	MyLogger.log_error("Implement this method")
	return false

func cleanField() -> bool:
	MyLogger.log_error("Implement this method")
	return false

func watchReplay() -> bool:
	MyLogger.log_error("Implement this method")
	return false

func submitReplay() -> bool:
	MyLogger.log_error("Implement this method")
	return false

func startGame() -> bool:
	MyLogger.log_error("Implement this method")
	return false

func removeMyReplay() -> bool:
	MyLogger.log_error("Implement this method")
	return false

func reloadGame() -> bool:
	MyLogger.log_error("Implement this method")
	return false
