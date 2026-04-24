extends Ability


# Called when the node enters the scene tree for the first time.
func execute(target: Character) -> void:
	deal_damage(target)
	
