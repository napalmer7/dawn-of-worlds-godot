extends Node2D

func _ready() -> void:
	get_tree().auto_accept_quit = false
	SessionController.call_deferred("enter_game")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if SessionController.save_current_game(): get_tree().quit()
