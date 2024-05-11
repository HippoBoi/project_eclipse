extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var direction = Vector3.ZERO;
const lerpSpeed = 14.0;
const speed = 5.0;

func _physics_process(delta):
	var input_dir = Input.get_vector("mLeft", "mRight", "mForward", "mBackward");
	
	if (!is_on_floor()):
		velocity.y -= gravity * delta;
	
	direction = lerp(direction, transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized(), delta * lerpSpeed);
	
	if direction:
		velocity.x = direction.x * speed;
		velocity.z = direction.z * speed;
	else:
		velocity.x = move_toward(velocity.x, 0, speed);
		velocity.z = move_toward(velocity.z, 0, speed);
	
	move_and_slide();
