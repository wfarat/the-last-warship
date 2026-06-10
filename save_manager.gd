extends Node

const SAVE_PATH = "user://save_data.json"

func save_game_data(data_to_save: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data_to_save)
		file.store_line(json_string)
		print("SaveManager: Dane zostały zapisane do pliku.")
	else:
		push_error("SaveManager: Nie udało się otworzyć pliku do zapisu!")

func load_game_data() -> Dictionary:
	if not has_save_file():
		print("SaveManager: Brak pliku zapisu.")
		return {}
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		print("SaveManager: Dane zostały pomyślnie odczytane z pliku.")
		return json.get_data()
	else:
		push_error("SaveManager: Błąd parsowania pliku JSON!")
		return {}

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
