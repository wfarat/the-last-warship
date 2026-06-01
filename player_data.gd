extends Node

signal gold_changed(new_amount)
signal xp_changed(current_xp, max_xp_for_level)
signal leveled_up(new_level)

var gold: int = 1000

var level: int = 1
var xp: int = 0
var xp_to_next_level: int = 100

func add_gold(amount: int):
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		return true
	return false

func add_xp(amount: int):
	xp += amount

	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = int(xp_to_next_level * 1.5) # Make the next level 50% harder to get
		
		leveled_up.emit(level)
	xp_changed.emit(xp, xp_to_next_level)
