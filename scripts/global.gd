extends Node

var playerId: int = 0
var services: Dictionary = {} 
var allServicesLoaded := false
#	get_tree().root.get_node("MainScene")			get mainScene node

var webService: WebService
var errorDisplayer: ErrorDisplayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
