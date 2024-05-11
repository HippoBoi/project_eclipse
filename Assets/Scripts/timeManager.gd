extends Node

func timeStop(damage: float, intensity: float):
	var stopTime = 0.016;
	if (damage > 1.0):
		stopTime = 0.025;
	stopTime = stopTime * intensity;
	var timer = get_tree().create_timer(stopTime);
	Engine.time_scale = 0.1;
	await timer.timeout;
	Engine.time_scale = 1;
