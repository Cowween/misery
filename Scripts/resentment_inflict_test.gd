extends Ability


func execute(target: Character) -> void:
	inflict_status(target, "Resentment", false)
		
