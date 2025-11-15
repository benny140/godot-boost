extends Node3D

var rotation_speed: float = 1.0
var move_speed: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Player node is ready.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Rotate left/right
	if Input.is_key_pressed(KEY_LEFT):
		rotate_z(rotation_speed * delta)
	if Input.is_key_pressed(KEY_RIGHT):
		rotate_z(-rotation_speed * delta)
	
	# Move forward in facing direction
	if Input.is_key_pressed(KEY_SPACE):
		var forward = transform.basis.y
		position += Vector3(forward.x, forward.y, 0).normalized() * move_speed * delta
