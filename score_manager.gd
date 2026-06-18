extends Node

const HIGHSCORES_PATH = "user://highscores.json"

var time_survived: float = 0.0
var enemies_destroyed: int = 0
var is_running: bool = false

# Uruchamiamy stoper na starcie nowej gry
func start_run() -> void:
	time_survived = 0.0
	enemies_destroyed = 0
	is_running = true

# Zatrzymujemy stoper po śmierci
func stop_run() -> void:
	is_running = false

func _process(delta: float) -> void:
	if is_running:
		time_survived += delta

func add_kill() -> void:
	enemies_destroyed += 1

func calculate_final_score() -> int:
	# Przykładowy wzór: 10 pkt za każdą sekundę + 100 pkt za każdego wroga
	return int(time_survived * 10) + (enemies_destroyed * 100)

# --- SYSTEM ZAPISU I ODCZYTU HIGHSCORE ---

func save_current_score(player_name: String = "Kapitan") -> void:
	var final_score = calculate_final_score()
	var new_entry = {
		"name": player_name,
		"score": final_score,
		"time": time_survived,
		"kills": enemies_destroyed
	}
	
	var highscores = load_highscores()
	highscores.append(new_entry)
	
	# Sortowanie malejąco według wyniku (najlepszy na górze)
	highscores.sort_custom(func(a, b): return a["score"] > b["score"])
	
	# Zatrzymujemy tylko TOP 10 wyników
	if highscores.size() > 10:
		highscores.resize(10)
		
	var file = FileAccess.open(HIGHSCORES_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(highscores))

func load_highscores() -> Array:
	if FileAccess.file_exists(HIGHSCORES_PATH):
		var file = FileAccess.open(HIGHSCORES_PATH, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			return json.get_data()
	return []
