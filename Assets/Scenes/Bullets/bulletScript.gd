extends Node3D

var speed = 40.0;
@export var dmg = 1.0;

var stopMoving = false;

@onready var mesh = $MeshInstance3D;
@onready var rayCast = $RayCast3D;
@onready var parts = $GPUParticles3D;
@onready var waterParticles = $waterParticles;

func _process(delta):
	if (rayCast.is_colliding()):
		if (!rayCast.get_collider().is_in_group("Water")):
			if (rayCast.get_collider().has_method("onHit")):
				rayCast.get_collider().onHit(dmg);
				rayCast.enabled = false;
			mesh.hide();
			stopMoving = true;
			parts.emitting = true;
			await get_tree().create_timer(1.0).timeout;
			queue_free();
			return;
		
		waterParticles.emitting = true;
		
	if (stopMoving == true):
		return;
		
	position += transform.basis * Vector3(0, 0, -speed) * delta;

func _on_timer_timeout():
	queue_free();
