extends RigidBody3D

@onready var rayCast = $RayCast3D;
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
@onready var upperCollision = $upperCollision

@export var floatForce = 1.0;
@export var waterDrag = 0.05;
@export var waterAngularDrag = 0.05;
@export var waterInstance: MeshInstance3D;
@export var heightOffset = 1.1;
@export var maxDepth = -1.5;
@export var instantFall = false;

var waterParticles = preload("res://Assets/Scenes/waterSplash.tscn");

var waterHeight = 0.0;
var timesHit = 0;
var fallingTime = 0.0

var isSubmerged = false;
var isFalling = false;
var once = false;

var material;
var shader;

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
	gravity_scale = 0;
	
	if (waterInstance != null):
		waterHeight = waterInstance.global_position.y;
	
	if (instantFall == true):
		isFalling = true;
		gravity_scale = 1;
	
func _process(delta):
	if (isFalling):
		fallingTime += delta
		if (fallingTime > 0.5):
			upperCollision.disabled = false;
			isFalling = false;
	if (rayCast.is_colliding() and rayCast.get_collider().has_method("hurtPlayer")):
		rayCast.get_collider().hurtPlayer(10);

func _physics_process(_delta):
	if (waterInstance == null):
		return;
	
	var depth = (waterHeight - global_position.y) + heightOffset;
	isSubmerged = false;
	if (depth > 0):
		isSubmerged = true;
		apply_central_force(Vector3.UP * floatForce * gravity * depth);
	
	if (depth > maxDepth and once == false):
		once = true;
		var splash = Global.instantiate_node(waterParticles, global_position, self);
		splash.emitting = true;

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if (isSubmerged):
		state.linear_velocity *= 1 - waterDrag;
		state.angular_velocity *= 1 - waterAngularDrag;

func onHit(dmg):
	if (instantFall):
		return;
	
	timesHit += dmg;
	if (timesHit >= 2):
		isFalling = true;
		gravity_scale = 1;
		return;
	
	var ogPosX = self.position.x;
	var ogPosY = self.position.y;
	var ogPosZ = self.position.z;
	var rng = RandomNumberGenerator.new();
	var tween = create_tween();
	tween.tween_property(self, "position", Vector3(rng.randf_range(-0.15, 0.15), rng.randf_range(-0.15, 0.15), rng.randf_range(-0.15, 0.15)), 0.01).as_relative();
	tween.tween_property(self, "position", Vector3(rng.randf_range(-0.35, 0.35), rng.randf_range(-0.35, 0.35), rng.randf_range(-0.35, 0.35)), 0.01).as_relative();
	tween.tween_property(self, "position", Vector3(ogPosX, ogPosY, ogPosZ), 0.1);
	
func getShader():
	material = get_node("stalactite_04").get_node("rock5_001").get_surface_override_material(0);
	shader = material.get_next_pass();
	if (material == null or shader == null):
		print("couldn't find material or shader");
		return false;
	return true;

func onPlayerFOV(inView):
	if (!getShader()):
		return;
	
	if (inView == true):
		shader.set("shader_parameter/border_width", 0.1);
		shader.set("shader_parameter/line_sharpness", 10);
		shader.set("shader_parameter/wave", false);
	elif (inView == false):
		shader.set("shader_parameter/border_width", 0.06);
		shader.set("shader_parameter/line_sharpness", 1);
		shader.set("shader_parameter/wave", true);

func onScanner(enable):
	if (!getShader()):
		return;
	
	if (enable == true):
		shader.set("shader_parameter/border_width", 0.06);
	else:
		shader.set("shader_parameter/border_width", 0.0);
		shader.set("shader_parameter/line_sharpness", 1);
		shader.set("shader_parameter/wave", true);
