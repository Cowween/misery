extends CharacterClass
class_name EliteGuardClass

@export var spd_per_adr_tier := 2.0

func _init() -> void:
	display_name = "Elite Guard"
	max_hp = 115.0
	ap_per_turn = 6
	min_atk = 12.0
	max_atk = 18.0
	atk_range = 1
	def = 7.0
	res = 1.0
	crit_rate = 12.0
	spd = 18.0
	dex_stat = 1.35
	adr_decay_per_turn = 45.0
	attack_ability_scenes = [
		preload("res://Scenes/Attacks/execution.tscn"),
		preload("res://Scenes/Attacks/breach.tscn"),
		preload("res://Scenes/Attacks/domination.tscn"),
	]

func on_tier_changed(character: Character, old_tier: int, new_tier: int) -> void:
	character.speed_add -= old_tier * spd_per_adr_tier
	character.speed_add += new_tier * spd_per_adr_tier

func on_turn_end(character: Character) -> void:
	if character.adr_decay_locked:
		character.hp -= character.max_hp * 0.1
		return
	super.on_turn_end(character)
