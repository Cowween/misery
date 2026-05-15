extends RefCounted
class_name AITargeting

# --- WEIGHT MULTIPLIERS (To be overridden by children) ---
var weight_attack: float = 100.0  # Massive bonus if moving here allows an attack
var weight_distance: float = 5.0  # Bonus for getting closer to targets
var weight_terrain: float = 3.0   # Bonus for good terrain/height
var weight_ap: float = 2.0        # Bonus for having AP left over
var weight_safety: float = 1.0    # Bonus for staying out of enemy ranges

var actor: Character
var terrain_cache: Dictionary

func _init(_actor: Character, _terrain_cache: Dictionary):
	actor = _actor
	terrain_cache = _terrain_cache

# The core decision engine
func get_best_move(targeted_group: String, move_grid_ap: Dictionary, total_units: Dictionary) -> Vector3:
	var best_tile: Vector3 = actor.cell
	var best_score: float = -99999.0
	
	# Extract valid targets from the total units
	var targets: Array[Character] = []
	for unit in total_units.values():
		if unit.is_in_group(targeted_group):
			# Ensure we only check each unit once (spatial hash has duplicate entries for big bosses)
			if not targets.has(unit):
				targets.append(unit)
				
	if targets.is_empty(): 
		
		return best_tile

	# Evaluate every tile we can reach (including the tile we are standing on)
	print("here")
	for tile in move_grid_ap.keys():
		var remaining_ap = move_grid_ap[tile]
		var score = 0.0
		
		score += evaluate_attack(tile, remaining_ap, targets) * weight_attack
		score += evaluate_distance(tile, targets) * weight_distance
		score += evaluate_terrain(tile, targets) * weight_terrain
		score += evaluate_safety(tile, targets) * weight_safety
		

		if score > best_score:
			best_score = score
			best_tile = tile
	return best_tile

func get_best_attack_target(current_tile: Vector3, remaining_ap: int, targeted_group: String, total_units: Dictionary) -> Array:
	var best_target: Character = null
	var best_ability:= -1
	var best_score: float = -99999.0
	
	# Extract valid targets
	var targets: Array[Character] = []
	for unit in total_units.values():
		if unit.is_in_group(targeted_group):
			# Ensure we only check each unit once (spatial hash has duplicate entries for big bosses)
			if not targets.has(unit):
				targets.append(unit)
			
	if targets.is_empty(): 
		return []

	# Evaluate every ability against every target in range
	var atkid := 0
	for ability in actor.attack_abilities:
		ability.prepare_for_use()
		if ability.get_ap_cost() <= remaining_ap:
			var range_cells = ability.ability_range.get_tiles_in_range(current_tile)
			for target in targets:
				var target_in_range := false
				for occupied_cell in target.get_occupied_cells():
					if range_cells.has(occupied_cell):
						target_in_range = true
						break
				
				if target_in_range:
					# Found a valid target in range! Score the attack.
					var score = evaluate_target_value(target, ability)
					score += randf() * 0.1 # Tie-breaker
					
					
					if score > best_score:
						best_score = score
						best_target = target
						best_ability = atkid
		atkid += 1

	if best_target:
		return [best_target, best_ability]
	return []

# --- EVALUATION LOGIC ---
func evaluate_target_value(target: Character, ability: Ability) -> float:
	var score = 0.0
	
	# Safely estimate damage (Assuming your ability script has a 'damage' or 'base_damage' property)
	var estimated_damage = ability.get_damage_multiplier() * actor.get_atk_val() * ability.get_hit_count()
	
	# 1. Damage Efficiency: Reward using strong attacks against enemies
	var health_percentage_taken = float(estimated_damage) / float(target.max_hp)
	score += health_percentage_taken * 50.0
	
	# 2. Kill Shot: Massive priority if this attack will kill the target
	if estimated_damage >= target.hp:
		score += 300.0
		
	# 3. Focus Fire: Bonus for targeting units that are already heavily injured
	var missing_health_ratio = 1.0 - (float(target.hp) / float(target.max_hp))
	score += missing_health_ratio * 40.0
	if target.class_state.has("sentinel_threat"):
		score *= float(target.class_state["sentinel_threat"])
	
	return score
func evaluate_attack(tile: Vector3, remaining_ap: int, targets: Array[Character]) -> float:
	var score = 0.0
	# Loop through actor's abilities to see if they can afford to attack from here
	for ability in actor.attack_abilities:
		ability.prepare_for_use()
		if ability.get_ap_cost() <= remaining_ap:
			# Check if any target is within this ability's range from this tile
			var range_cells = ability.ability_range.get_tiles_in_range(tile)
			for target in targets:
				for occupied_cell in target.get_occupied_cells():
					if not range_cells.has(occupied_cell):
						continue
					# Found a valid attack! Score increases based on target's missing health (finish them off)
					score += 1.0 + (1.0 - (target.hp / float(target.max_hp)))
					break
	return score

func evaluate_distance(tile: Vector3, targets: Array[Character]) -> float:
	var closest_dist = 999.0
	for target in targets:
		# 3D Manhattan Distance
		var dist = abs(tile.x - target.cell.x) + abs(tile.y - target.cell.y) + abs(tile.z - target.cell.z)
		if dist < closest_dist:
			closest_dist = dist
	
	# Return inverse distance (closer = higher score). 
	# Note: For ranged units, you might want to return highest score at exactly max_range instead!
	return -closest_dist 

func evaluate_terrain(tile: Vector3, targets: Array[Character]) -> float:
	var score = 0.0
	# Example: Favor tiles that are higher up than the closest enemy
	if not targets.is_empty():
		if tile.y > targets[0].cell.y:
			score += 1.0
			
	# Favor defensive tiles from your terrain rules
	var rules = terrain_cache.get(tile, {"cost": 1})
	if rules.has("defense_bonus"):
		score += rules.defense_bonus
		
	return score

func evaluate_ap(remaining_ap: int) -> float:
	# Simply having AP left is good, as it means we didn't exhaust ourselves moving
	return float(remaining_ap)

func evaluate_safety(tile: Vector3, targets: Array[Character]) -> float:
	var danger = 0.0
	# Very basic safety check: penalize if within 3 tiles of an enemy
	for target in targets:
		var dist = abs(tile.x - target.cell.x) + abs(tile.y - target.cell.y) + abs(tile.z - target.cell.z)
		if dist <= 3:
			danger += 1.0
	return -danger
