extends Ability

@export var status := ""

func execute(target: Character) -> void:
	#print(status_infliction)
	inflict_status(target, status)
	ability_owner.gain_adrenaline(adr_gain_on_use)
