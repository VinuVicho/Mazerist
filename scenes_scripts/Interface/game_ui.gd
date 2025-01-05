class_name GameUI extends CanvasLayer

var gameService: GameService
var endGameTimer: Timer
var reloadGameButtonPressed := false

func _init() -> void:
	Global.gameUI = self

func _ready() -> void:
	gameService = Global.gameService
	endGameTimer = gameService.getGameTimer()

func _process(_delta: float) -> void:
	$StartGamePanel/VBoxContainer/GameTimerLabel.text = str(roundf(($TimerBeforeStart.wait_time if $TimerBeforeStart.is_stopped() else $TimerBeforeStart.time_left)*10)/10)
	$TimerBeforeStartLabel.text = str(roundf(endGameTimer.wait_time if endGameTimer.is_stopped() else endGameTimer.time_left))

func resetUI():
	endGameTimer.stop()
	$StartGamePanel.visible = true
	$VBoxContainer/RestartReplayButton.disabled = false
	$VBoxContainer2/RemoveReplayButton.visible = false
	$VBoxContainer2/WatchReplayButton.visible = true
	gameService.endGame()

#region buttons
func _on_back_to_menu_button_pressed() -> void:
	$StartGamePanel.visible = true
	gameService.endGame()
	gameService.cleanField()
	gameService.get_node("GameCamera").enabled = false
	$TimerBeforeStart.stop()
	Global.interfaceService.changeGameState(Enums.ProgramState.MAIN_MENU)
	$VBoxContainer2/RemoveReplayButton.visible = false
	$VBoxContainer2/WatchReplayButton.visible = true

func _on_restart_replay_button_pressed() -> void:
	if reloadGameButtonPressed: 
		Logger.log_error("Game is reloading, cannot restart now")
		return
	$TimerBeforeStart.stop()
	$StartGamePanel.visible = true
	gameService.endGame()

func _on_watch_replay_button_pressed() -> void:
	if gameService.watchReplay():
		$VBoxContainer2/RemoveReplayButton.visible = true
		$VBoxContainer2/WatchReplayButton.visible = false
		setGameHintLabel("Watching replay")

func _on_submit_replay_button_pressed() -> void:
	gameService.submitReplay()
#endregion

func _on_start_game_button_pressed() -> void:
	#set_process(true)			#TODO: make this optimization
	var timer: Timer = $TimerBeforeStart
	if timer.time_left != timer.wait_time && timer.time_left != 0: 
		_on_timer_before_start_timeout()
		return
	timer.start()

func setDisabledForSubmitTurn(disable: bool):
	$VBoxContainer2/SubmitReplayButton.disabled = disable

func _on_timer_before_start_timeout() -> void:
	$StartGamePanel.visible = false
	endGameTimer.start()
	$TimerBeforeStart.stop()
	gameService.startGame()

func setGameHintLabel(text: String):
	$GameHintLabel.text = text

func _on_remove_replay_button_pressed() -> void:
	gameService.removeMyReplay()
	$VBoxContainer2/RemoveReplayButton.visible = false
	$VBoxContainer2/WatchReplayButton.visible = true


func _on_reload_game_button_pressed() -> void:
	reloadGameButtonPressed = true
	$VBoxContainer/ReloadGameButton.disabled = true
	$VBoxContainer/RestartReplayButton.disabled = true
	await gameService.reloadGame()
	resetUI()
	$VBoxContainer/ReloadGameButton.disabled = false
	reloadGameButtonPressed = false
