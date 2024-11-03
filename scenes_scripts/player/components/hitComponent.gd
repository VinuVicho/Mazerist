extends Node

var childNodes: Array = []

func prepare():			#TODO: probably prepare this component for different situations
	childNodes = get_children()

func process_hit():
	var hitReaction = 0
	for node in childNodes:
		hitReaction = node.process_hit()
	if (hitReaction == -1):
		return
	get_parent().makeTankDead()
	print(get_parent().name + " died")

