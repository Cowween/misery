extends AITargeting
class_name DefensiveTargeting

func _init(_actor: Character, _terrain_cache: Dictionary):
	super(_actor, _terrain_cache)
	
	# Tweak the weights for a Cowardly/Tactical style
	weight_attack = 50.0    # Still attacks if free, but won't risk its life
	weight_distance = -10.0 # Negative weight: actively TRIES to get further away
	weight_terrain = 20.0   # Deeply values high ground and cover
	weight_ap = 5.0         # Likes to keep AP in reserve
	weight_safety = 30.0    # Massive priority on avoiding enemy attack ranges


func evaluate_target_value(target: Character, ability: Ability) -> float:
	var score = super.evaluate_target_value(target, ability)
	
	# Defensive AI tries to eliminate the biggest immediate threats (closest units)
	var dist = abs(actor.cell.x - target.cell.x) + abs(actor.cell.y - target.cell.y) + abs(actor.cell.z - target.cell.z)
	score -= dist * 15.0 # High penalty for farther targets; prefers adjacent threats
	
	# Tactical AI loves applying status effects to cripple enemies
	# (Checking against your uploaded status effect architecture)
		
	return score
