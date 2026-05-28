extends CanvasLayer

@export var basic_cannon: PackedScene
@export var laser_cannon: PackedScene
@export var missile_cannon: PackedScene
@export var plasma_cannon: PackedScene

var player_ship: CharacterBody2D = null
var selected_slot_index: int = -1
var player_gold: int = 1200

@onready var slot_panel = $Panel/Box/HBox/SlotPanel
@onready var action_panel = $Panel/Box/HBox/ActionPanel
@onready var status_label = $Panel/Box/HBox/ActionPanel/ButtonContainer/StatusLabel
@onready var gold_label = $Panel/Box/Gold
@onready var upgrade_button = $Panel/Box/HBox/ActionPanel/ButtonContainer/UpgradeButton
@onready var sell_button = $Panel/Box/HBox/ActionPanel/ButtonContainer/SellButton
func _ready() -> void:
	hide() 

	action_panel.hide()
	
func open_shop(player: CharacterBody2D):
	show()
	update_gold_display()
	player_ship = player
	action_panel.hide()

func _on_slot_button_pressed(slot_index: int):
	selected_slot_index = slot_index
	action_panel.show()
	
	var target_slot = player_ship.get_node("Slots").get_child(slot_index)
	
	if target_slot.get_child_count() == 0:
		status_label.text = "Choose a weapon to install:"
		set_button_visibility(true, false)
	else:
		var current_weapon = target_slot.get_child(0)
		status_label.text = "Occupied by: " + current_weapon.name
		if (current_weapon.has_method("next_tier_price")):
			upgrade_button.text = 'Upgrade ' + str(current_weapon.next_tier_price()) + 'g'
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
		update_gold_display()
		player_ship.install_cannon(selected_slot_index, weapon_blueprint)
		_on_slot_button_pressed(selected_slot_index) # Refresh UI view
	else:
		status_label.text = "Not enough gold!"

func _on_upgrade_pressed():
	var target_slot = player_ship.get_node("Slots").get_child(selected_slot_index)
	var current_weapon = target_slot.get_child(0)
	
	if current_weapon.has_method("upgrade_tier") and current_weapon.has_method("next_tier_price"):
		player_gold -= current_weapon.next_tier_price()
		update_gold_display()
		current_weapon.upgrade_tier()
		status_label.text = "Upgraded to Tier " + str(current_weapon.current_tier+1)

func _on_sell_button_pressed():
	var target_slot = player_ship.get_node("Slots").get_child(selected_slot_index)
	for child in target_slot.get_children():
		child.queue_free()
	player_gold += 150
	update_gold_display()
	_on_slot_button_pressed(selected_slot_index)

func set_button_visibility(buy_state: bool, upgrade_state: bool):
	$Panel/Box/HBox/ActionPanel/ButtonContainer/BuyContainer.visible = buy_state
	sell_button.visible = upgrade_state
	upgrade_button.visible = upgrade_state

func update_gold_display():
	gold_label.text = "Your gold: " + str(player_gold)
	
func _on_close_button_pressed() -> void:
	hide()
	get_tree().paused = false # Unpause the game world
