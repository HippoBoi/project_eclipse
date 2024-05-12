extends CharacterBody3D

const speed = 2.0;
const acc = 10.0;
const minSpeed = 0.05;
const defMaterial = preload("res://Assets/Materials/cralerModel.tres");
const newMaterial = preload("res://Assets/Materials/new_standard_material_3d.tres");

@export var maxInvisFrames: float = 0.25;
@export var barOffset = Vector2(32, 22);

var scanMode = false;
var paused = false;

var debounce = 0;
var invisFrames = 0;
var newPos = Vector3();
var rng = RandomNumberGenerator.new();
var material;
var shader;
var playerDistance;
var cam;

@onready var healthPoints = $HealthPoints
@onready var navAgent = $NavigationAgent3D;
@onready var rayCast = $RayCast3D;
@onready var uiControl = $UI/UIControl
@onready var hpBar = $UI/UIControl/hpBar
@onready var animPlayer = $cralerModel.get_node("animPlayer");
@onready var player = get_tree().get_nodes_in_group("Player")[0];

signal damage;

var descText: Array[String] = [
	"Un enemigo muy épico la verdad el enemigo más épico de todos quée pero quequeu como qué",
	"Este enemigo es además muy épico porque",
	"cuidao que esta bien epiquín y agustín y todos los colores bab"
	];

var scanText;

func _ready():
	calcNewPos();
	cam = get_viewport().get_camera_3d();
	
	scanText = {
	"Name": "Epic Enemy",
	"Desc": descText,
	"Danger": 2
	};

func calcNewPos():
	var randX = rng.randf_range(-10.0, 10.0);
	var randZ = rng.randf_range(-10.0, 10.0);
	var randPos = Vector3(randX, 0, randZ);
	newPos = global_position + randPos;

func _process(delta):
	debounce -= delta;
	invisFrames -= delta;
	if (invisFrames <= 0):
		$cralerModel.get_node("body").set_surface_override_material(0, defMaterial);
	
	if (cam.is_position_in_frustum(global_position) and scanMode == true):
		uiControl.show();
		var barPos = cam.unproject_position(global_position);
		uiControl.set_global_position(barPos - barOffset);
	else:
		uiControl.hide();

func onHit(dmg):
	if (invisFrames <= 0):
		invisFrames = maxInvisFrames;
		damage.emit(dmg);
		hpBar.scale = Vector2(healthPoints.HP / healthPoints.maxHP, 1);
		$cralerModel.get_node("body").set_surface_override_material(0, newMaterial);

func _physics_process(delta):
	if (paused):
		return;
	
	if (player):
		playerDistance = global_position.distance_to(player.global_position);
		
	if (playerDistance > 20):
		if (animPlayer.current_animation != "idle"):
			animPlayer.play("idle");
		
		calcNewPos();
		debounce = 5;
		return;
	
	var direction = Vector3();
	navAgent.target_position = newPos;
	
	direction = navAgent.get_next_path_position() - global_position;
	direction = direction.normalized();
	look_at(Vector3(newPos.x, newPos.y, 0), Vector3.UP);
	
	velocity = velocity.lerp(direction * speed, acc * delta);
	
	if (abs(velocity) >= Vector3(minSpeed, minSpeed, minSpeed)):
		if (animPlayer.current_animation != "walk"):
			animPlayer.play("walk");
	else:
		if (animPlayer.current_animation != "idle"):
			animPlayer.play("idle");
	
	if (rayCast.is_colliding() and debounce < 3):
		debounce = 5;
		calcNewPos();
	elif (debounce <= 0):
		var newDebounceTime = rng.randf_range(4, 6);
		debounce = newDebounceTime;
		calcNewPos();
	
	move_and_slide();

func getShader():
	material = $cralerModel.get_node("body").get_surface_override_material(0);
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
	
	scanMode = enable;
	
	if (enable == true):
		shader.set("shader_parameter/border_width", 0.06);
	else:
		shader.set("shader_parameter/border_width", 0.0);
		shader.set("shader_parameter/line_sharpness", 1);
		shader.set("shader_parameter/wave", true);

func pauseGame(pause):
	paused = pause;
