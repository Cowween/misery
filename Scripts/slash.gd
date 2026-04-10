extends Ability


# Called when the node enters the scene tree for the first time.
func execute(target: Character) -> void:
	target.hp -= ability_owner.get_atk_val() * atk_multiplier
	
