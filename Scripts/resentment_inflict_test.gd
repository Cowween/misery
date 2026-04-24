extends Ability


func execute(target: Character) -> void:
	inflict_status(target, "Resentment")
	ability_owner.gain_adrenaline(adr_gain_on_use)
		
