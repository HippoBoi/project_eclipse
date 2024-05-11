extends Node3D

@onready var animPlayer = $AnimationPlayer;
@onready var area3D = $MeshInstance3D/Area3D
@onready var glowMaterial = $MeshInstance3D/rock_10/rock10.get_surface_override_material(1);

@export var hitsNeeded = 1;
var curHits = 0;
var maxInvisFrames = 0.25;

const maxGlow = 0.8;
const minGlow = 0.0;
const glowSpeed = 0.5;
const glowTimer = 3;

var glowColor = maxGlow;
var glowDirection = 0.0;
var glowWaitTime = 0;

var fallen = false;

func _ready():
	area3D.monitoring = true;

func _process(delta):
	if (glowWaitTime <= 0):
		if (fallen):
			if (glowColor > 0.0):
				glowColor -= 0.01;
		else:
			glowColor += glowDirection * glowSpeed;
			if (glowColor >= maxGlow):
				glowDirection = -0.01;
			if (glowColor <= minGlow and glowDirection < 0):
				glowWaitTime = glowTimer;
				glowDirection = 0.01;
			
		glowMaterial.emission = Color(glowColor * 0.7, glowColor * 0.55, glowColor, 0.0);
		return;
	glowWaitTime -= delta;
	print(glowWaitTime);

func fallRock():
	curHits += 1;
	if (curHits >= hitsNeeded and fallen == false):
		fallen = true;
		animPlayer.play("falling");
		print("ouch");

func _on_area_3d_area_entered(_area):
	fallRock();
	
