extends Control

@export var camera: Camera3D
@export var signal_bus: Node

@onready var container = $ScrollContainer/VBoxContainer

const ability_btn := preload("uid://ce82pnvqf3agw")
var target_character: Character
var id_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_attacks()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = camera.unproject_position(target_character.position) + target_character.option_menu_offset
	
func display_attacks(target: Character, current: Character) -> void:
	clear_attack_buttons()
	target_character = target
	for i in current.attack_abilities:
		i.prepare_for_use()
		var cost := i.get_ap_cost()
		var is_disabled := false
		if cost > current.action_points:
			is_disabled = true
		add_button(id_count, i.get_display_name(), cost, is_disabled)
		id_count += 1
	set_process(true)
	show()
	
func hide_attacks() -> void:
	clear_attack_buttons()
	set_process(false)
	hide()
	
func clear_attack_buttons() -> void:
	for i in container.get_children():
		i.queue_free()
	id_count = 0
	
	
func add_button(id: int, aname: String, cost: int, disabled:=false) -> void:
	#todo: connect button signal to signal bus
	var btn = ability_btn.instantiate()
	btn.text = aname
	btn.abilityID = id
	btn.signal_bus = signal_bus
	
	container.add_child(btn)
	btn.set_ap(cost)
	
	if disabled:
		btn.disabled = true
	
	
	
