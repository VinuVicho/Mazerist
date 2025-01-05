class_name TankState

var tankNode: Node2D

var movingActionPressed: int = 0					#How many % of speed to move
var rotatingActionPressed: int = 0					# % to rotate
var shootActionPressed: bool = false

## Action should be:
## [actionNumber, ActionType, posX * 1000, posY * 1000, rotation * 100, time]
# probably later add some more new situational fields 
var actions: Array = []
var is_alive: bool = false
var current_speed: int = 20

# Probably make different TankStates for different game modes
var isHoldingArtefact = false
var artefact: Area2D

#TODO: amke method here to clean up after game
