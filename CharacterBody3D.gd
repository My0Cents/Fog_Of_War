extends CharacterBody3D

# Speed of the character movement.
var speed: float = 100.0

func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO

	if Input.is_key_pressed(KEY_Z):  # Forward
		direction.z -= 1
	if Input.is_key_pressed(KEY_S):  # Backward
		direction.z += 1
	if Input.is_key_pressed(KEY_Q):  # Left
		direction.x -= 1
	if Input.is_key_pressed(KEY_D):  # Right
		direction.x += 1

	# Normalize the direction to ensure consistent movement speed in all directions.
	direction = direction.normalized()

	# Calculate the velocity.
	velocity = direction * speed

	# Move the character body.
	move_and_slide()
