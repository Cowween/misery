extends AITargeting
class_name AggressiveTargeting

func _init(_actor: Character, _terrain_cache: Dictionary):
	super(_actor, _terrain_cache)
	
	# Tweak the weights for a Berserker/Aggressive style
	weight_attack = 200.0   # Will ALWAYS attack if possible
	weight_distance = 15.0  # Runs straight at the enemy
	weight_terrain = 1.0    # Doesn't care much about high ground
	weight_ap = 0.0         # Willing to burn all AP just to get closer
	weight_safety = -5.0    # Negative weight means it PREFERS to be in the danger zone!

func evaluate_target_value(target: Character, ability: Ability) -> float:
	var score = super.evaluate_target_value(target, ability)
	
	# Aggressive AI absolutely LOVES to secure kills. 
	var estimated_damage = ability.get_damage_multiplier() * actor.atk * actor.atk_mult * ability.get_hit_count()
	if estimated_damage >= target.hp:
		score += 500.0 # Extreme priority for lethal blows
		
	# Prefers to bully targets with the lowest actual HP
	# (e.g., will target a squishy mage over a wounded tank)
	score += (100.0 - target.hp)
	
	# Bonus if it's a high AP cost ability (goes all-out)
	score += ability.get_ap_cost() * 10.0
	
	return score
