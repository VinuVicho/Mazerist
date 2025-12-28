extends Node

var playerId: int = 0
#	get_tree().root.get_node("MainScene")			get mainScene node

var gameService: IGameService
var interfaceService: InterfaceService
var gameUI: GameUI
var webService: WebService
var mainScene: MainScene

var errorDisplayer: ErrorDisplayer

func _ready():
	if gameService == null: MyLogger.log_error("No game service. MEGA-ERROR")
	if webService == null: MyLogger.log_error("No web service. MEGA-ERROR")

func verifyObjectIsNotNullAndReturnIt(obj):
	if obj == null: MyLogger.log_error("Object is null")
	return obj
