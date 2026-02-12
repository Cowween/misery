extends SpecialAbility

func _ready() -> void:
	aim_required = true

func execute(targets: Array[Character]) -> void:
	for i in targets:
		i.hp -= ability_owner.atk * atk_multiplier
		ability_owner.adrenaline -= adr_cost
