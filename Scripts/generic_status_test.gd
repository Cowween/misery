extends Ability

@export var status := ""

func execute(target: Character) -> void:
	#print(status_infliction)
	inflict_status(target, status)
