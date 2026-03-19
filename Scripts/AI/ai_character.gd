extends Character
class_name AI_Character
@export var target_group := "Player"
@export var targeting : Array[AITargeting]

@onready var current_targeting := targeting[0]

var prev_target : Character
var seq_counter : Dictionary[Character, int]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	for i in targeting:
		i.actor = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	
func is_in_atk_range(target: Character) -> bool:
	if target not in seq_counter:
		seq_counter[target] = 0
	var id := seq_counter[target]
	var range := attack_abilities[id].ability_range.get_tiles_in_range()
	#print(attack_abilities[id].ability_range.name)
	if target.cell in range:
		return true
	return false
	
func ai_attack(target: Character) -> void:
	#print("Attacking %s" %target.cname)
	if not is_in_atk_range(target):
		return
	attack(target, seq_counter[target])
	seq_counter[target] += 1
	if seq_counter[target] == attack_abilities.size():
		seq_counter[target] = 0
	
func attack(target: Character, abilityID: int) -> void:
	#For attack, you pass a character object through the target and deduct its hp
	
	if action_points < attack_abilities[abilityID].ap_cost:
		return
	_path_follow.look_at(target.position, Vector3(0,1,0), true)
	attack_abilities[abilityID].execute(target)
	print("AP cost: ", attack_abilities[abilityID].ap_cost)
	action_points = action_points - attack_abilities[abilityID].ap_cost
