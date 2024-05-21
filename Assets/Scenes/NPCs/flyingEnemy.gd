extends CharacterBody3D

# setup
@onready var player = get_tree().get_nodes_in_group("Player")[0];
@onready var uiControl = $UI/UIControl;
@onready var hpBar = $UI/UIControl/hpBar;
@onready var healthPoints = $HealthPoints;

@export var barOffset = Vector2(32, 22);
@export var maxInvisFrames: float = 0.25;

# materials
const newMaterial = preload("res://Assets/Materials/new_standard_material_3d.tres");
var defMaterial;
var material;
var shader;

signal damage;

# bools
var scanMode = false;
var paused = false;

# numbers
const maxUIDistance = 30.0;
var invisFrames = 0;
var flyTimer = 0;
var playerDistance = 0.0;
@export var speed = 0.1;
@export var amplitude = 0.5;

# undefined vars
var scanText;
var cam;
var descText: Array[String] = [
	"Flying enemy default text.",
	"It flies."
];

func _ready():
	defMaterial = $enemyModel.get_surface_override_material(0);
	cam = get_viewport().get_camera_3d();
	
	scanText = {
	"Name": "Flying Enemy",
	"Desc": descText,
	"Danger": 3
	};

func _process(delta):
	invisFrames -= delta;
	if (invisFrames <= 0 and defMaterial):
		$enemyModel.set_surface_override_material(0, defMaterial);
	
	if (cam.is_position_in_frustum(global_position) and scanMode == true):
		uiControl.show();
		var barPos = cam.unproject_position(global_position);
		uiControl.set_global_position(barPos - barOffset);
		uiControl.modulate.a = min(0.9, (maxUIDistance / playerDistance * 2) / (maxUIDistance));
	else:
		uiControl.hide();
	
func _physics_process(delta):
	if (paused):
		return;
	
	if (player):
		playerDistance = global_position.distance_to(player.global_position);
	
	velocity.y += speed;
	flyTimer -= delta;
	if (flyTimer <= 0):
		velocity.y = 0;
		flyTimer = amplitude
		speed *= -1;
	move_and_slide();

func onHit(dmg):
	if (invisFrames <= 0):
		invisFrames = maxInvisFrames;
		damage.emit(dmg);
		hpBar.scale = Vector2(healthPoints.HP / healthPoints.maxHP, 1);
		$enemyModel.set_surface_override_material(0, newMaterial);

func getShader():
	material = $enemyModel.get_surface_override_material(0);
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
