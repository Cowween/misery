extends AITargeting
class_name PassiveTargeting

var aggro_radius: int = 5
var is_awake: bool = false

func _init(_actor: Character, _terrain_cache: Dictionary):
	super(_actor,_terrain_cache)
	
	# Once awake, it acts like a normal unit
	weight_attack = 100.0
	weight_distance = 5.0
	weight_safety = 1.0

# Override the main decision loop
func get_best_move(targeted_group: String, move_grid_ap: Dictionary, total_units: Dictionary) -> Vector3:
	if not is_awake:
		# Check if anyone is close enough to wake us up
		for unit in total_units:
			if unit.is_in_group(targeted_group):
				var dist = abs(actor.cell.x - unit.cell.x) + abs(actor.cell.y - unit.cell.y) + abs(actor.cell.z - unit.cell.z)
				if dist <= aggro_radius:
					is_awake = true
					break # WAKE UP!
					
	# If we are still asleep, return the tile we are currently standing on (don't move)
	if not is_awake:
		return actor.cell
		
	# If we are awake, run the normal AI calculation
	return super.get_best_move(targeted_group, move_grid_ap, total_units)
