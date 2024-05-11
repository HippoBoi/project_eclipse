extends RigidBody3D

@export var floatForce = 1.0;
@export var waterDrag = 0.05;
@export var waterAngularDrag = 0.05;
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");

const waterHeight = 0.0;

var isSubmerged = false;

func _physics_process(delta):
	var depth = waterHeight - global_position.y;
	isSubmerged = false;
	if (depth > 0):
		isSubmerged = true;
		apply_central_force(Vector3.UP * floatForce * gravity * depth);

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if (isSubmerged):
		state.linear_velocity *= 1 - waterDrag;
		state.angular_velocity *= 1 - waterAngularDrag;
		
