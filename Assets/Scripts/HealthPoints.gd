extends Node3D

@onready var parent = get_parent();

@export var maxHP: float = 1.0;
@export var HP: float = 1.0;

func damage(dmg):
	HP -= dmg;
	if (HP <= 0):
		dead();

func dead():
	if (parent):
		parent.queue_free();

func _on_enemy_test_damage(dmg):
	damage(dmg);
