class_name Enums

enum Holder {
	NOT_ASSIGNED,
	PLAYER, 
	LOBBY,
	GAME,
}

enum LobbyStatus {
	LOBBY,
	MAP_PICK,
	GAME, 
	CREATING_MAP,
}

enum PositionType {
	PLAYER_SPAWN,
	ARTEFACT,
}

enum ProgramState {
	MAIN_MENU, 
	GAME,
}

enum GameState {
	PRE_GAME,
	GAME,
	POST_GAME,
}

enum ActionType {
	TANK_SPAWNED = 0, 
	TANK_DIED = 1, 
	TURN_RIGHT = 2, 
	TURN_LEFT = 3, 
	STOP_ROTATING = 4, 
	MOVE_FORWARD = 5, 
	MOVE_BACKWARDS = 6, 
	STOP_MOVING = 7,
	SHOOT = 8,
}

enum GameStatusAction {
	NOT_MY_ACTION = 0,
	MY_TURN = 1,
	END_TURN = 2,
}
