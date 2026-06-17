extends Control

@onready var menu_container = $MenuContainer

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameManager.current_state == GameManager.GameState.PLAYING or GameManager.current_state == GameManager.GameState.PAUSED:
			toggle_pause()

func toggle_pause() -> void:
	if GameManager.current_state == GameManager.GameState.PLAYING:
		GameManager.change_state(GameManager.GameState.PAUSED)
		get_tree().paused = true
		show() 
	elif GameManager.current_state == GameManager.GameState.PAUSED:
		GameManager.change_state(GameManager.GameState.PLAYING)
		get_tree().paused = false
		hide() 


func _on_continue_button_pressed() -> void:
	toggle_pause()

func _on_save_button_pressed() -> void:
	GameManager.save_game()
	$MenuContainer/SaveButton.text = "ZAPISANO!"

func _on_settings_button_pressed() -> void:
	print("Otwieram ustawienia...")
	# np. SettingsMenu.show() 

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	hide()
	GameManager.go_to_menu()
