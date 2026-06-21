extends Control

@onready var load_button = $MarginContainer/VBoxContainer/LoadButton
@onready var main_menu: Control = $"."
@onready var new_game_button: Button = $MarginContainer/VBoxContainer/NewGameButton
@onready var scores_panel = $ScoresPanel
@onready var scores_list = $ScoresPanel/VBoxContainer/ScoresList
var font = load("res://ui/BebasNeue-Regular.ttf")
func _ready() -> void:
	new_game_button.grab_focus()
	scores_panel.hide()
	# Bezpośrednie i czyste sprawdzenie pliku przez SaveManagera
	load_button.disabled = not SaveManager.has_save_file()
func _on_highscores_button_pressed() -> void:
	# Czyszczenie starej listy (żeby uniknąć duplikatów przy klikaniu)
	for child in scores_list.get_children():
		child.queue_free()
		
	var highscores = ScoreManager.load_highscores()
	
	if highscores.is_empty():
		var empty_label = Label.new()
		# ZMIANA TUTAJ: używamy kluczy "font" i "font_size"
		empty_label.add_theme_font_override("font", font)
		empty_label.add_theme_font_size_override("font_size", 56)
		empty_label.text = "Brak wyników! Zagraj, aby być pierwszym."
		scores_list.add_child(empty_label)
	else:
		# Generujemy tekst dla każdego zapisanego wyniku
		for i in range(highscores.size()):
			var entry = highscores[i]
			var score_label = Label.new()
			
			# ZMIANA TUTAJ:
			score_label.add_theme_font_override("font", font)
			score_label.add_theme_font_size_override("font_size", 56)
			
			score_label.text = "%d. %s - %d pkt (%d zabójstw)" % [i + 1, entry["name"], entry["score"], entry["kills"]]
			scores_list.add_child(score_label)
			
	scores_panel.show()

func _on_close_scores_button_pressed() -> void:
	new_game_button.grab_focus()
	scores_panel.hide()
	
func _on_play_button_pressed() -> void:
	GameManager.start_new_game()

func _on_load_button_pressed() -> void:
	GameManager.load_game()

func _on_settings_button_pressed() -> void:
	GlobalSettings.show()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
