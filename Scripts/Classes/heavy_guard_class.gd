extends CharacterClass
class_name HeavyGuardClass

@export var damage_to_adr_ratio := 0.35

func _init() -> void:
	display_name = "Heavy Guard"
	max_hp = 170.0
	ap_per_turn = 4
	min_atk = 18.0
	max_atk = 30.0
	atk_range = 1
	def = 14.0
	res = 1.2
	crit_rate = 4.0
	spd = 7.0
	str_stat = 1.45
	adr_decay_per_turn = 25.0
	attack_ability_scenes = [
		preload("res://Scenes/Attacks/bonecrusher.tscn"),
		preload("res://Scenes/Attacks/bloodletting.tscn"),
		preload("res://Scenes/Attacks/sentinel.tscn"),
	]

func on_damage_taken(character: Character, source: Character, final_damage: float, _damage_type: String) -> void:
	if not character.has_status("Bloodletting"):
		return
	character.gain_adrenaline(final_damage * damage_to_adr_ratio)
	if source and is_instance_valid(source) and not character.class_state.get("countering", false):
		character.class_state["countering"] = true
		var counter_damage := character.get_atk_val() * 0.65
		source.take_damage(counter_damage, character, "physical", false)
		character.class_state["countering"] = false
		var bloodletting := character.get_status("Bloodletting") as BloodlettingEffect
		if character.get_adrenaline_tier() >= 4 and bloodletting:
			bloodletting.add_damage_stack(character)
