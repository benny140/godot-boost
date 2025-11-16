extends RigidBody3D

var rotation_torque: float = 1.0
var thrust_force: float = 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Player node is ready.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Rotate left/right
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0, 0, rotation_torque))
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0, 0, -rotation_torque))
	
	# Move forward in facing direction
	if Input.is_action_pressed("boost"):
		var forward = transform.basis.y
		var thrust = Vector3(forward.x, forward.y, 0).normalized() * thrust_force
		apply_central_force(thrust)
