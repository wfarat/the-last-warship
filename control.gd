extends Control

@onready var score_label = $VBoxContainer/ScoreLabel
@onready var stats_label = $VBoxContainer/StatsLabel

func _ready() -> void:
	# Pobieramy dane z ostatniego, zakończonego podejścia
	var score = ScoreManager.calculate_final_score()
	var time = int(ScoreManager.time_survived)
	var kills = ScoreManager.enemies_destroyed
	
	score_label.text = "TWÓJ WYNIK: " + str(score)
	stats_label.text = "Przetrwałeś: %ds\nZniszczone statki: %d" % [time, kills]

func _on_menu_button_pressed() -> void:
	GameManager.go_to_menu()
