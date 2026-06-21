extends CanvasLayer

@onready var volume_slider = $Panel/VBoxContainer/MasterVolumeSlider

# Zmienna przechowująca identyfikator głównego kanału audio
var master_bus_index: int

func _ready() -> void:
	hide() # Na start schowane
	# Szukamy kanału "Master" (Główny kanał w zakładce Audio na dole edytora)
	master_bus_index = AudioServer.get_bus_index("Master")
	
	# Ustawiamy suwak na aktualną głośność gry (tłumaczymy decybele na procenty 0-1)
	var current_db = AudioServer.get_bus_volume_db(master_bus_index)
	volume_slider.value = db_to_linear(current_db)

# PAMIĘTAJ: Podepnij ten sygnał z Twojego HSlider (sygnał: value_changed)
func _on_master_volume_slider_value_changed(value: float) -> void:
	# Tłumaczymy procenty (0-1) z powrotem na decybele
	var new_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(master_bus_index, new_db)

# PAMIĘTAJ: Podepnij ten sygnał z przycisku ZAMKNIJ (sygnał: pressed)
func _on_close_button_pressed() -> void:
	hide()
