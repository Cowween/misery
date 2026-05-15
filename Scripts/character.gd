class_name Character
extends Path3D

const DIRECTIONS = [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]

#==SETTINGS==
@export var grid: Resource = preload("uid://d2qkoqg3ttlpu")
@export var ground: GridMap
@export var offset := Vector3(0,0,0)
@export var initial_cell := Vector3(0,0,0)
@export var cname := "P1"
@export var option_menu_offset := Vector2(10,10)
@export var side_length: int = 1
@export var character_class: CharacterClass

#==STATS==
var level: int:
	get:
		return character_class.level if character_class else 1
var agility: float:
	get:
		return get_speed()
var ap_per_turn: int:
	get:
		return character_class.ap_per_turn if character_class else 5
var max_hp: float:
	get:
		return character_class.max_hp if character_class else 100.0
var atk_range: int:
	get:
		return character_class.atk_range if character_class else 2
var atk: float:
	get:
		return character_class.max_atk if character_class else 3.0
var def: float:
	get:
		return get_def()
var res: float:
	get:
		return get_res()
var crit_rate: float:
	get:
		return character_class.crit_rate if character_class else 2.0
var initial_adr: float:
	get:
		return character_class.initial_adr if character_class else 0.0
var max_adr: float:
	get:
		return character_class.max_adr if character_class else 100.0
var adr_decay_per_turn: float:
	get:
		return character_class.adr_decay_per_turn if character_class else 15.0
var tier_1_threshold: float:
	get:
		return character_class.tier_1_threshold if character_class else 20.0
var tier_2_threshold: float:
	get:
		return character_class.tier_2_threshold if character_class else 50.0
var tier_3_threshold: float:
	get:
		return character_class.tier_3_threshold if character_class else 90.0

#==ABILIITIES==
@export var attack_abilities : Array[Ability] = []
@export var special_abilities: Array[SpecialAbility] = []

#==PRIVATE VARIABLES==
var action_points = 5: set = set_action_points
var signal_bus: SignalBus
var cell := Vector3.ZERO: set = set_cell
var tile_over = true
@export var initiative = 0
var current_basis = Vector3()
var is_walking = false : set = set_is_walking
var hp = max_hp: set =set_hp
var walking_ap := 0
var adrenaline := 0.0: set = set_adrenaline
var speed := 5
var status_effects : Array[StatusEffect]
var atk_mult := 1.0
var atk_add := 0.0
var def_mult := 1.0
var def_add := 0.0
var res_mult := 1.0
var res_add := 0.0
var speed_mult := 1.0
var speed_add := 0.0
var ap_cost_add := 0
var prevent_adr_decay_turns := 0
var adr_decay_locked := false
var invulnerable_turns := 0
var class_state := {}
var is_current := false
var terrain_cache := {}
var suppress_action_done := false
var _last_adrenaline_tier := 0
@onready var _path_follow = $PathFollow3D
		
func set_cell(value: Vector3) -> void:
	cell = grid.clamp(value)
	
func set_hp(value: float) -> void:
	if invulnerable_turns > 0 and value < hp:
		return
	if value < hp:
		var domination := get_status("Domination") as DominationEffect
		if domination and domination.bubble_hp > 0.0:
			var incoming := hp - value
			var absorbed = min(incoming, domination.bubble_hp)
			domination.bubble_hp -= absorbed
			value += absorbed
	hp = value
	if hp >= max_hp:
		hp = max_hp
	if hp <= 0:
		die()
	if is_current:
		signal_bus.hp_update.emit(value, max_hp)
	
func set_is_walking(value: bool) -> void:
	is_walking = value
	set_process(is_walking)
	
func set_action_points(value: int) -> void:
	action_points = value
	print(cname, "ap", value)
	signal_bus.ap_update.emit(value)
	if action_points == 0 and not suppress_action_done:
		signal_bus.action_done.emit()

func set_adrenaline(value: float) -> void:
	var old_tier := _last_adrenaline_tier
	adrenaline = value
	if adrenaline >= max_adr:
		adrenaline = max_adr
	if adrenaline <= 0:
		adrenaline = 0
	var new_tier := get_adrenaline_tier()
	if character_class and new_tier != old_tier:
		character_class.on_tier_changed(self, old_tier, new_tier)
	_last_adrenaline_tier = new_tier
	if is_current:
		signal_bus.adr_update.emit(adrenaline, max_adr)
	
func turn_start() -> void:
	#connected to  main turn start
	if character_class:
		character_class.on_turn_start(self)
	for i in status_effects:
		i.on_turn_start()
	is_current = true
	for ability in attack_abilities:
		ability.prepare_for_use()
	status_update()

func turn_end() -> void:
	#connected to main turn end
	is_current = false
	for i in status_effects:
		i.on_turn_end()
	if invulnerable_turns > 0:
		invulnerable_turns -= 1
	if character_class:
		character_class.on_turn_end(self)
	else:
		adrenaline -= adr_decay_per_turn
	
func status_update() -> void:
	signal_bus.emit_signal("status_update", self, is_current)

func initialise() -> void:
	action_points = ap_per_turn

func _ready() -> void:
	if not character_class:
		character_class = _build_default_class()
	character_class.apply_to_character(self)
	_last_adrenaline_tier = get_adrenaline_tier()
	_instantiate_class_loadout()
	for i in attack_abilities:
		i.set_ability_owner(self)
		if i.uses_class_range:
			i.set_range(atk_range,  1)
		i.set_walkable(ground.get_walkable_cells())
	for i in special_abilities:
		i.set_ability_owner(self)
	adrenaline = initial_adr
	cell = initial_cell
	position = grid.calculate_map_position(cell) + offset
	_path_follow.progress = 0.0
	
	if not Engine.is_editor_hint():
		curve = Curve3D.new()
	set_process(false)


	
func _process(delta: float) -> void:
	_path_follow.progress += speed * delta
	if _path_follow.progress_ratio >= 1.0:
		# Setting `_is_walking` to `false` also turns off processing.
		#action_points = walking_ap
		is_walking = false
		# Below, we reset the offset to `0.0`, which snaps the sprites back to the Unit node's
		# position, we position the node to the center of the target grid cell, and we clear the
		# curve.
		# In the process loop, we only moved the sprite, and not the unit itself. The following
		# lines move the unit in a way that's transparent to the player.
		var cached_rot = _path_follow.rotation
		_path_follow.progress = 0.0
		position = grid.calculate_map_position(cell) + offset
		_path_follow.rotation = cached_rot
		_path_follow.position = Vector3(0,0,0)
		suppress_action_done = true
		action_points = walking_ap
		suppress_action_done = false

		#print(_path_follow.progress_ratio)
		curve.clear_points()
		# Finally, we emit a signal. We'll use this one with the game board.
		signal_bus.walk_finished.emit()

func get_occupied_cells() -> Array[Vector3]:
	var cells: Array[Vector3] = []
	for x_offset in range(side_length):
		for z_offset in range(side_length):
			# Height (Y) remains flat relative to the root cell
			cells.append(cell + Vector3(x_offset, 0, z_offset))
	return cells

func walk_along(path: PackedVector3Array) -> void:
	if path.is_empty():
		return
	# print(path)
	# This code converts the `path` to points on the `curve`. That property comes from the `Path2D`
	# class the Unit extends.
	curve.add_point(Vector3(0, 0, 0))
	for point in path:
		#print("point is ", grid.calculate_map_position(point))
		curve.add_point(grid.calculate_map_position(point) + offset - position)
		
	# We instantly change the unit's cell to the target position. You could also do that when it
	# reaches the end of the path, using `grid.calculate_grid_coordinates()`, instead.
	# I did it here because we have the coordinates provided by the `path` argument.
	# The cell itself represents the grid coordinates the unit will stand on.
	cell = path[-1]
	walking_ap = action_points - path.size() + 1
	# The `_is_walking` property triggers the move animation and turns on `_process()`. See
	# `_set_is_walking()` below.
	is_walking = true

func get_atk_val() -> int:
	var base_atk := character_class.roll_attack_value(self) if character_class else atk
	return maxi(0, roundi((base_atk + atk_add) * atk_mult))

func get_scaled_atk_val(scaling_stat: String = "") -> int:
	var scale := character_class.get_attack_scale(self, scaling_stat) if character_class else 1.0
	return maxi(0, roundi(get_atk_val() * scale))

func get_def() -> float:
	var base_def := character_class.def if character_class else 10.0
	return max(0.0, (base_def + def_add) * def_mult)

func get_res() -> float:
	var base_res := character_class.res if character_class else 1.0
	return max(0.1, (base_res + res_add) * res_mult)

func get_speed() -> float:
	var base_speed := character_class.spd if character_class else 100.0
	return max(1.0, (base_speed + speed_add) * speed_mult)

func get_adrenaline_tier() -> int:
	if character_class:
		return character_class.get_adrenaline_tier(adrenaline)
	if adrenaline >= tier_3_threshold:
		return 3
	if adrenaline >= tier_2_threshold:
		return 2
	if adrenaline >= tier_1_threshold:
		return 1
	return 0

func gain_adrenaline(amount: float) -> void:
	var final_amount := amount
	var domination := get_status("Domination") as DominationEffect
	if domination:
		final_amount += amount * domination.adr_gain_multiplier
	adrenaline += final_amount

func spend_all_adrenaline() -> void:
	adrenaline = 0

func has_status(status_name: String) -> bool:
	return get_status(status_name) != null

func get_status(status_name: String) -> StatusEffect:
	for status in status_effects:
		if status.status_name == status_name:
			return status
	return null

func take_damage(incoming_damage: float, source: Character = null, damage_type := "physical", can_miss := true) -> float:
	if incoming_damage <= 0.0:
		return 0.0
	if can_miss and source and _attack_misses(source):
		return 0.0
	var final_damage := incoming_damage
	if damage_type == "physical":
		final_damage = max(0.0, incoming_damage - get_def())
	else:
		final_damage = incoming_damage / get_res()
	hp -= final_damage
	if character_class:
		character_class.on_damage_taken(self, source, final_damage, damage_type)
	return final_damage

func attack(target: Character, abilityID: int) -> void:
	#For attack, you pass a character object through the target and deduct its hp
	if target == null or not is_instance_valid(target):
		return
	if abilityID < 0 or abilityID >= attack_abilities.size():
		return
	var ability := attack_abilities[abilityID]
	if ability == null:
		return
	ability.prepare_for_use()
	var cost := ability.get_ap_cost()
	if action_points < cost:
		return
	_path_follow.look_at(target.position, Vector3(0,1,0), true)
	ability.execute(target)
	if character_class:
		character_class.on_attack_executed(self, ability, target, ability.last_damage_done)
	print("AP cost: ", cost)
	action_points = action_points - cost
	

func die() -> void:
	signal_bus.unit_death.emit(self)
	queue_free()

func _attack_misses(source: Character) -> bool:
	var source_speed := max(1.0, source.get_speed())
	var dodge_chance := max(0.0, (get_speed() - source_speed) / source_speed * 100.0)
	return randf_range(0.0, 100.0) < dodge_chance

func _build_default_class() -> CharacterClass:
	if cname == "P1":
		return EliteGuardClass.new()
	if cname == "P2":
		return HeavyGuardClass.new()
	if cname.to_lower().contains("research"):
		return ResearcherClass.new()
	return HeavyGuardClass.new()

func _instantiate_class_loadout() -> void:
	if not character_class:
		return
	if not character_class.attack_ability_scenes.is_empty():
		attack_abilities.clear()
		for scene in character_class.attack_ability_scenes:
			var ability := scene.instantiate() as Ability
			if ability:
				add_child(ability)
				attack_abilities.append(ability)
	if not character_class.special_ability_scenes.is_empty():
		special_abilities.clear()
		for scene in character_class.special_ability_scenes:
			var ability := scene.instantiate() as SpecialAbility
			if ability:
				add_child(ability)
				special_abilities.append(ability)
