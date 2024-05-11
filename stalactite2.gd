extends RigidBody3D

@onready var rayCast = $RayCast3D;
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");

@export var floatForce = 1.0;
@export var waterDrag = 0.05;
@export var waterAngularDrag = 0.05;
@export var waterInstance: MeshInstance3D;

var waterParticles = preload("res://Assets/Scenes/waterSplash.tscn");

var waterHeight = 0.0;
var timesHit = 0;

var isSubmerged = false;
var once = false;

signal onSight;
signal Scanner;

var descText: Array[String] = [
	"Rock formation usually found hanging down in caves.",
	"It's spiky shape might potentially be dangerous from high distances.",
	"It is also tough enough to resist being stepped on."
	];
	
@onready var scanText = {
	"Name": "Stalactite",
	"Desc": descText,
	"Danger": 1
	};

func _ready():
	if (waterInstance != null):
		waterHeight = waterInstance.global_position.y;
	
	gravity_scale = 0;
	
func _process(_delta):
	if (rayCast.is_colliding() and rayCast.get_collider().has_method("hurtPlayer")):
		rayCast.get_collider().hurtPlayer(10);

func _physics_process(_delta):
	if (waterInstance == null):
		return;
	
	var depth = waterHeight - global_position.y;
	isSubmerged = false;
	if (depth > 0):
		isSubmerged = true;
		apply_central_force(Vector3.UP * floatForce * gravity * depth);
	
	if (depth > 1.7 and once == false):
		once = true;
		var splash = Global.instantiate_node(waterParticles, global_position, self);
		splash.emitting = true;

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if (isSubmerged):
		state.linear_velocity *= 1 - waterDrag;
		state.angular_velocity *= 1 - waterAngularDrag;

func onHit(dmg):
	timesHit += dmg;
	if (timesHit >= 2):
		gravity_scale = 1;
		return;
	
	var ogPosX = self.position.x;
	var ogPosY = self.position.y;
	var ogPosZ = self.position.z;
	var rng = RandomNumberGenerator.new();
	var tween = create_tween();
	tween.tween_property(self, "position", Vector3(rng.randf_range(-0.1, 0.1), rng.randf_range(-0.1, 0.1), rng.randf_range(-0.1, 0.1)), 0.01).as_relative();
	tween.tween_property(self, "position", Vector3(rng.randf_range(-0.25, 0.25), rng.randf_range(-0.25, 0.25), rng.randf_range(-0.25, 0.25)), 0.01).as_relative();
	tween.tween_property(self, "position", Vector3(ogPosX, ogPosY, ogPosZ), 0.1);
	
func onPlayerFOV(inView):
	onSight.emit(inView);

func onScanner(enable):
	Scanner.emit(enable);
