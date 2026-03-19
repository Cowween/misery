extends AITargeting

func acquire_target(target_group : String, unit_list : Dictionary) -> Character:
	var smallest_dist := 9999999999
	var target : Character
	for i in unit_list:
		
		if unit_list[i] == null: continue
		var curr_dist := actor.cell.distance_to(unit_list[i])
		if actor.cell.distance_to(unit_list[i]) <= smallest_dist and i.is_in_group(target_group):
			target = i
			smallest_dist = curr_dist
	return target
