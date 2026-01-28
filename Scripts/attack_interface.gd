extends Control

@export var camera: Camera3D
@export var SignalBus: Node

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
	target_character = target
	for i in current.attack_abilities:
		add_button(id_count, i.ability_name)
		id_count += 1
	set_process(true)
	show()
	
func hide_attacks() -> void:
	for i in container.get_children():
		i.queue_free()
	id_count = 0
	set_process(false)
	hide()
	
	
func add_button(id: int, aname: String) -> void:
	#todo: connect button signal to signal bus
	var btn = ability_btn.instantiate()
	btn.text = aname
	btn.abilityID = id
	btn.SignalBus = SignalBus
	container.add_child(btn)
	
	
	
