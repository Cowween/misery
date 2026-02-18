@abstract
extends Node
class_name AbilityRange

@export var max_range: int = 1
@export var min_range: int = 0

# These are usually assigned dynamically by the Ability or Main script
var actor: Character
var grid: Resource 

# VIRTUAL FUNCTION: Override this in LineRange, ConeRange, etc.
# origin: If NOT null, we are simulating a position (for drawing the red border).
# direction: If NOT null, we are simulating a facing direction.
@abstract func get_tiles_in_range(origin: Variant = null, direction: Vector3 = Vector3.FORWARD) -> Array[Vector3]

# THE GENERIC EXPANSION LOGIC
# This works for ALL shapes automatically (Diamond, Cone, Line).
# It simulates the unit standing on every edge tile, spinning 360 degrees.
func get_visual_expansion(edge_tiles: Array, included_tiles: Dictionary) -> Array:
	var valid_red_tiles = {} # Using Dictionary as a Set to prevent duplicates
	
	# Simulate facing all 4 Cardinal Directions from every edge tile
	var directions = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	
	for cell in edge_tiles:
		for dir in directions:
			# Polymorphic Call: Ask the specific child class "What do you hit from here?"
			var tiles = get_tiles_in_range(cell, dir)
			
			for t in tiles:
				# Only add if it's not already a Blue Move Tile
				if not included_tiles.has(t):
					valid_red_tiles[t] = true
	
	return valid_red_tiles.keys()

func _get_facing_direction() -> Vector3:
	if not actor: return Vector3.FORWARD
	var forward = actor._path_follow.global_transform.basis.z
	if abs(forward.x) > abs(forward.z):
		return Vector3(sign(forward.x), 0, 0)
	else:
		return Vector3(0, 0, sign(forward.z))
