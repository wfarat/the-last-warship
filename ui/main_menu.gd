extends Control

@onready var load_button = $MarginContainer/VBoxContainer/LoadButton

func _ready() -> void:
	# Bezpośrednie i czyste sprawdzenie pliku przez SaveManagera
	load_button.disabled = not SaveManager.has_save_file()

func _on_play_button_pressed() -> void:
	GameManager.start_new_game()

func _on_load_button_pressed() -> void:
	GameManager.load_game()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
