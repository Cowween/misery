extends Character
class_name AI_Character
@export var target_group := "Player"
var targeting_list : Array[AITargeting] = []

var current_targeting : AITargeting

var prev_target : Character
var seq_counter : Dictionary[Character, int]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	targeting_list.append(AggressiveTargeting.new(self, terrain_cache))
	targeting_list.append(DefensiveTargeting.new(self, terrain_cache))
	targeting_list.append(PassiveTargeting.new(self, terrain_cache))
	current_targeting = targeting_list[0]
	#print(targeting)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	
func is_in_atk_range(target: Character, ability: Ability) -> bool:
	var range := ability.ability_range.get_tiles_in_range()
	#print(attack_abilities[id].ability_range.name)
	for i in target.get_occupied_cells():
		if i in range:
			return true
	return false
	
"""func ai_attack(target: Character) -> void:
	#print("Attacking %s" %target.cname)
	if not is_in_atk_range(target):
		return
	attack(target, seq_counter[target])
	seq_counter[target] += 1
	if seq_counter[target] == attack_abilities.size():
		seq_counter[target] = 0"""
	

	
