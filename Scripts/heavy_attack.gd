extends Ability


func execute(target: Character) -> void:
	target.hp -= ability_owner.atk * atk_multiplier
# Called when the node enters the scene tree for the first time.
