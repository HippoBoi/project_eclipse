extends Node3D

@export var dmg = 1.0;

@onready var hitbox = $hitBox/collisionShape;

const dmgParticles = preload("res://Assets/Scenes/hitParticles.tscn");

func _on_timer_timeout():
	hitbox.disabled = true;

func _on_body_entered(body):
	if (body.has_method("onHit")):
		var particles = Global.instantiate_node(dmgParticles, body.global_position, body);
		particles.look_at(self.global_transform.origin, Vector3.UP);
		particles.rotate_y(deg_to_rad(180));
		particles.emitting = true;
		TimeManager.timeStop(dmg, 1.0);
		body.onHit(dmg);
