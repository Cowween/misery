extends SpecialAbility

func _ready() -> void:
	aim_required = true

func execute(targets: Array[Character]) -> void:
	if not pay_cost():
		return
	for i in targets:
		deal_damage(i)
