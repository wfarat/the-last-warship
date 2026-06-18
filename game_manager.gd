extends Node

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
var current_state: GameState = GameState.MENU

const SAVE_PATH = "user://save_data.json"
signal state_changed(new_state)
var world = "res://world.tscn" 
var main_menu_path = "res://ui/main_menu.tscn"
var game_over_path = "res://ui/game_over.tscn"
var chest_scene: PackedScene = preload("res://misc/chest.tscn")

func start_new_game():
	PlayerData.gold = 0
	PlayerData.xp = 0
	PlayerData.level = 1
	ScoreManager.start_run()
	change_state(GameState.PLAYING)
	get_tree().change_scene_to_file(world)

func game_over() -> void:
	ScoreManager.stop_run()
	ScoreManager.save_current_score() # Zapisujemy wynik do JSON
	
	get_tree().change_scene_to_file(game_over_path)
	
func go_to_menu():
	change_state(GameState.MENU)
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)

func change_state(new_state: GameState):
	current_state = new_state
	state_changed.emit(current_state)


func save_game() -> void:
	# 1. Zbieramy globalne dane gracza
	var data = {
		"gold": PlayerData.gold,
		"xp": PlayerData.xp,
		"level": PlayerData.level,
		"xp_to_next_level": PlayerData.xp_to_next_level,
		"ship_data": {} # Domyślnie puste
	}
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.has_method("get_save_data"):
		data["ship_data"] = player.get_save_data()

	SaveManager.save_game_data(data)

func load_game() -> bool:
	var loaded_data = SaveManager.load_game_data()
	if loaded_data.is_empty():
		return false
		
	PlayerData.gold = loaded_data.get("gold", 0)
	PlayerData.xp = loaded_data.get("xp", 0)
	PlayerData.level = loaded_data.get("level", 1)
	PlayerData.xp_to_next_level = loaded_data.get("xp_to_next_level", 100)

	PlayerData.saved_ship_data = loaded_data.get("ship_data", {})
	
	change_state(GameState.PLAYING)
	get_tree().change_scene_to_file(world)
	return true

func spawn_loot(spawn_position: Vector2):
	var chest = chest_scene.instantiate()
	chest.global_position = spawn_position
	get_tree().current_scene.call_deferred("add_child", chest)
