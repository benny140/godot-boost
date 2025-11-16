extends RigidBody3D

## Rotation speed when turning left/right
@export_range(0.1, 5) var rotation_torque: float = 1.0
## Forward thrust strength when boosting
@export_range(10, 50) var thrust_force: float = 25

var is_level_complete: bool = false
var stability_timer: float = 0.0
var landing_pad: Node = null
const STABILITY_THRESHOLD: float = 0.5 # How long to be stable before completing
const VELOCITY_THRESHOLD: float = 0.1 # Max velocity to be considered stable
const UPRIGHT_THRESHOLD: float = 0.9 # Minimum dot product with up vector to be considered upright

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Check if player has stabilized after landing
	if is_level_complete:
		check_stability(delta)
	
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


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Goal"):
		complete_level(body)
	if body.is_in_group("Hazard"):
		crash_sequence()

func crash_sequence() -> void:
	get_tree().reload_current_scene()

func check_stability(delta: float) -> void:
	var is_upright = transform.basis.y.dot(Vector3.UP) > UPRIGHT_THRESHOLD
	var is_stable = linear_velocity.length() < VELOCITY_THRESHOLD and angular_velocity.length() < VELOCITY_THRESHOLD and is_upright
	if is_stable:
		stability_timer += delta
		if stability_timer >= STABILITY_THRESHOLD:
			if landing_pad and landing_pad.level_complete_scene:
				get_tree().change_scene_to_file(landing_pad.level_complete_scene)
			else:
				get_tree().quit()
	else:
		stability_timer = 0.0

func complete_level(pad: Node) -> void:
	is_level_complete = true
	landing_pad = pad
