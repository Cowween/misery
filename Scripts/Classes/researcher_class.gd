extends CharacterClass
class_name ResearcherClass

@export var morphine_uses := 10
@export var bandage_uses := 10

func _init() -> void:
	display_name = "Researcher"
	max_hp = 90.0
	ap_per_turn = 5
	min_atk = 7.0
	max_atk = 12.0
	atk_range = 3
	def = 4.0
	res = 1.5
	crit_rate = 6.0
	spd = 11.0
	int_stat = 1.35
	adr_decay_per_turn = 20.0
	attack_ability_scenes = [
		preload("res://Scenes/Attacks/corrosive_spray.tscn"),
		preload("res://Scenes/Attacks/field_testing.tscn"),
		preload("res://Scenes/Attacks/neural_spike.tscn"),
	]

func apply_to_character(character: Character) -> void:
	super.apply_to_character(character)
	character.class_state["morphine_uses"] = morphine_uses
	character.class_state["bandage_uses"] = bandage_uses
