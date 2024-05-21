extends Node3D

var speed = 40.0;
var timeAlive = 0.0;
@export var dmg = 1.0;

var stopMoving = false;
var gamePaused = false;

@onready var mesh = $MeshInstance3D;
@onready var rayCast = $RayCast3D;
@onready var parts = $GPUParticles3D;
@onready var waterParticles = $waterParticles;

func _process(delta):
	if (gamePaused):
		return;
	
	if (rayCast.is_colliding()):
		if (!rayCast.get_collider().is_in_group("Water")):
			if (rayCast.get_collider().has_method("onHit")):
				rayCast.get_collider().onHit(dmg);
				rayCast.enabled = false;
			mesh.hide();
			stopMoving = true;
			parts.emitting = true;
			timeAlive += delta;
			if (timeAlive > 3.0):
				queue_free();
			return;
		
		waterParticles.emitting = true;
		
	if (stopMoving == true):
		return;
		
	position += transform.basis * Vector3(0, 0, -speed) * delta;

func pauseGame(pause):
	gamePaused = pause;
