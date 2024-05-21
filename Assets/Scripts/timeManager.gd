extends Node

func timeStop(damage: float, intensity: float):
	var stopTime = 0.02;
	if (damage > 2.0):
		stopTime = 0.028;
	stopTime = stopTime * intensity;
	var timer = get_tree().create_timer(stopTime);
	Engine.time_scale = 0.1;
	await timer.timeout;
	Engine.time_scale = 1;
