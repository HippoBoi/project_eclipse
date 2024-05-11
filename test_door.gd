extends StaticBody3D

var timer = 0;
var isClosed = false;

func _process(delta):
	if (isClosed == true):
		closeDoor();

func closeDoor():
	timer += 1;
	if (timer % 360 == 0):
		var tween = create_tween();
		tween.tween_property(self, "rotation", Vector3(0, deg_to_rad(0), 0), .25);
		await tween.finished;
		isClosed = false;

func onHit():
	if (isClosed == true):
		return;
	
	var tween = create_tween();
	tween.tween_property(self, "rotation", Vector3(0, deg_to_rad(90), 0), .25);
	isClosed = true;
