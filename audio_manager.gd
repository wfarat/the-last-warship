extends Node

@onready var music_player = $MusicPlayer
@onready var sfx_player = $SFXPlayer

@export_group("Music")
@export var menu_music: AudioStream
@export var battle_music: AudioStream
@export var game_over_music: AudioStream

@export_group("Sound Effects")
@export var tornado_warning_sfx: AudioStream
@export var mine_warning_sfx: AudioStream

func _ready() -> void:
	GameManager.state_changed.connect(_on_game_state_changed)
	_on_game_state_changed(GameManager.current_state)

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.MENU:
			play_music(menu_music)
			sfx_player.stream_paused = false
		GameManager.GameState.PLAYING:
			play_music(battle_music)
			sfx_player.stream_paused = false
		GameManager.GameState.GAME_OVER:
			play_music(game_over_music)
			sfx_player.stream_paused = false
		GameManager.GameState.PAUSED, GameManager.GameState.SHOP, GameManager.GameState.UPGRADE:
			sfx_player.stream_paused = true
			pass # Nie zmieniamy utworu, niech leci dalej tło z bitwy!

func play_music(stream: AudioStream) -> void:

	if music_player.stream == stream:
		return
		
	music_player.stream = stream
	if stream:
		music_player.play()
		
func play_annoucement(id: int) -> void:
	match id:
		0: play_event_warning(tornado_warning_sfx)
		1: play_event_warning(mine_warning_sfx)

func play_event_warning(event_warning_sfx: AudioStream) -> void:
	if event_warning_sfx:
		sfx_player.stream = event_warning_sfx
		sfx_player.play()

# 2. Generic function in case you ever want to pass other sounds to it!
func play_sfx(stream: AudioStream) -> void:
	if stream:
		sfx_player.stream = stream
		sfx_player.play()
