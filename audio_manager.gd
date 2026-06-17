extends Node

@onready var music_player = $MusicPlayer

@export var menu_music: AudioStream
@export var battle_music: AudioStream
@export var game_over_music: AudioStream

func _ready() -> void:
	GameManager.state_changed.connect(_on_game_state_changed)
	
	_on_game_state_changed(GameManager.current_state)

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.MENU:
			play_music(menu_music)
		GameManager.GameState.PLAYING:
			play_music(battle_music)
		GameManager.GameState.GAME_OVER:
			play_music(game_over_music)
		GameManager.GameState.PAUSED:
			pass # Nie zmieniamy utworu, niech leci dalej tło z bitwy!

func play_music(stream: AudioStream) -> void:

	if music_player.stream == stream:
		return
		
	music_player.stream = stream
	if stream:
		music_player.play()
