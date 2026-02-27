extends Ability

@export var status := ""

func execute(target: Character) -> void:
	inflict_status(target, status, false)
