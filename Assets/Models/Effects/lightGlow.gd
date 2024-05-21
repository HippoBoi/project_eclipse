extends OmniLight3D

@export var lightSpeed = 1.0;
@export var minRange = 1.0;
@export var maxRange = 2.0;

var lightDirection = 0.01;

func _process(_delta):
	omni_range += lightDirection * lightSpeed;
	print(omni_range);
	
	if (omni_range >= maxRange):
		lightDirection = -0.01;
	elif (omni_range <= minRange):
		lightDirection = 0.01;
