extends Node3D

@export var velocity = 10

var dir := Vector3()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	dir = Vector3()
	
	var movement_vector = Vector2()
	if Input.is_action_pressed("move_forward"):
		movement_vector.y += 1
	if Input.is_action_pressed("move_backwards"):
		movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		movement_vector.x += 1
	
	movement_vector = movement_vector.normalized()
	
	dir += -global_transform.basis.z.normalized() * movement_vector.y
	dir += global_transform.basis.x.normalized() * movement_vector.x
	
	position += dir * velocity * delta
