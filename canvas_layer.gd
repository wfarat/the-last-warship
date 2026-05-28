extends CanvasLayer

# Preloaded data for the different weapon types the player can buy
@export var basic_cannon: PackedScene
@export var laser_cannon: PackedScene
@export var missile_cannon: PackedScene
@export var plasma_cannon: PackedScene

var player_ship: CharacterBody2D = null
var selected_slot_index: int = -1
var player_gold: int = 1200 # Track currency

@onready var slot_panel = $SlotPanel
@onready var action_panel = $ActionPanel
@onready var status_label = $ActionPanel/ButtonContainer/StatusLabel

func _ready() -> void:
	# 1. Hide the entire CanvasLayer so the screen is clear while sailing
	hide() 
	
	# 2. Hide the action panel so it's perfectly reset for the first time you enter port
	action_panel.hide()
	
func open_shop(player: CharacterBody2D):
	show()
	player_ship = player
	action_panel.hide() # Hide choices until they select a slot

# Call this from your UI layout when the player clicks Slot Button #1, #2, etc.
func _on_slot_button_pressed(slot_index: int):
	selected_slot_index = slot_index
	action_panel.show()
	
	# Get the specific Marker2D slot from the player ship's node array
	var target_slot = player_ship.get_node("Slots").get_child(slot_index)
	
	if target_slot.get_child_count() == 0:
		status_label.text = "Slot is EMPTY. Choose a weapon to install:"
		# Show "Buy New" buttons, hide "Upgrade/Swap" buttons
		set_button_visibility(true, false)
	else:
		var current_weapon = target_slot.get_child(0)
		status_label.text = "Occupied by: " + current_weapon.name
		# Hide "Buy New" buttons, show "Upgrade/Swap" buttons
		set_button_visibility(false, true)

func _on_buy_weapon_pressed(weapon_type: String):
	if selected_slot_index == -1 or !player_ship: return
	
	var weapon_blueprint: PackedScene = null
	var cost = 300
	
	match weapon_type:
		"basic": weapon_blueprint = basic_cannon
		"laser": weapon_blueprint = laser_cannon; cost = 600
		"missile": weapon_blueprint = missile_cannon; cost = 900
		"plasma": weapon_blueprint = plasma_cannon; cost = 1200
		
	if player_gold >= cost:
		player_gold -= cost
		# Call the installation system we built earlier
		player_ship.install_cannon(selected_slot_index, weapon_blueprint)
		_on_slot_button_pressed(selected_slot_index) # Refresh UI view
	else:
		status_label.text = "Not enough gold!"

func _on_upgrade_pressed():
	var target_slot = player_ship.get_node("Slots").get_child(selected_slot_index)
	var current_weapon = target_slot.get_child(0)
	
	# Check if the weapon has an upgrade function built into its own script
	if current_weapon.has_method("upgrade_tier") and player_gold >= 400:
		player_gold -= 400
		current_weapon.upgrade_tier()
		status_label.text = "Upgraded to Tier " + str(current_weapon.tier)

func _on_sell_button_pressed():
	var target_slot = player_ship.get_node("Slots").get_child(selected_slot_index)
	# Wipe out the current child node safely
	for child in target_slot.get_children():
		child.queue_free()
	player_gold += 150 # Give partial refund
	_on_slot_button_pressed(selected_slot_index) # Refresh UI view

func set_button_visibility(buy_state: bool, upgrade_state: bool):
	$ActionPanel/ButtonContainer/BuyContainer.visible = buy_state
	$ActionPanel/ButtonContainer/UpgradeButton.visible = upgrade_state
	$ActionPanel/ButtonContainer/SellButton.visible = upgrade_state

func _on_close_button_pressed() -> void:
	hide()
	get_tree().paused = false # Unpause the game world
