extends Ability


func execute(target: Character) -> void:
	var has_status := false
	for i in target.status_effects:
		if i is ResentmentEffect:
			has_status = true
			i.add_stack()
			break
	if not has_status:
		var new_status : ResentmentEffect = status_infliction.instantiate()
		new_status.on_apply(target)
		target.add_child(new_status)
		target.status_update(false)
		
