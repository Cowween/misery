class_name Character
extends Path3D

const DIRECTIONS = [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]

@export var speed = 5
@export var ap_per_turn = 5
@export var max_hp = 100
@export var grid: Resource = preload("res://Resources/Grid.tres")
@export var offset := Vector3(0,2,0)
@export var initial_cell := Vector3(0,0,0)
@export var atk_range := 2
@export var atk := 3
@export var cname := "P1"
@export var option_menu_offset := Vector2(10,10)
@export var attack_abilities : Array[Ability] = []
@export var special_abilities: Array[SpecialAbility] = []

var action_points = 5: set = set_action_points
var SignalBus: Node
var cell := Vector3.ZERO: set = set_cell
var tile_over = true
var initiative = randi_range(0,11)
var current_basis = Vector3()
var is_walking = false : set = set_is_walking
var hp = max_hp: set =set_hp
var walking_ap := 0
var adrenaline := 0

@onready var _path_follow = $PathFollow3D
		

func set_cell(value: Vector3) -> void:
	cell = grid.clamp(value)
	
func set_hp(value: int) -> void:
	hp = value
	SignalBus.hp_update.emit(value)
	
func set_is_walking(value: bool) -> void:
	is_walking = value
	set_process(is_walking)
	
func set_action_points(value: int) -> void:
	action_points = value
	print(cname, "ap", value)
	SignalBus.ap_update.emit(value)
	if action_points == 0:
		SignalBus.action_done.emit()
	
	
	
func initialise() -> void:
	action_points = ap_per_turn

func _ready() -> void:
	
	for i in attack_abilities:
		i.ability_owner = self
	for i in special_abilities:
		i.set_ability_owner(self)
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
		position = grid.calculate_map_position(cell+offset)
		_path_follow.rotation = cached_rot
		_path_follow.position = Vector3(0,0,0)
		action_points = walking_ap

		#print(_path_follow.progress_ratio)
		curve.clear_points()
		# Finally, we emit a signal. We'll use this one with the game board.
		SignalBus.walk_finished.emit()

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
		
func attack(target: Character, abilityID: int) -> void:
	#For attack, you pass a character object through the target and deduct its hp
	_path_follow.look_at(target.position, Vector3(0,1,0), true)
	attack_abilities[abilityID].execute(target)
	print("AP cost: ", attack_abilities[abilityID].ap_cost)
	action_points = action_points - attack_abilities[abilityID].ap_cost
	

	
