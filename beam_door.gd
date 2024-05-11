extends StaticBody3D

@export var distance = 4.0;

var material;
var shader;

var timer = 0;
var isClosed = false;

var scanText;
var descText: Array[String] = [
	"This gate reacts to any kind of physical stimulus.",
	"Origin unknown."
	];

func _ready():
	scanText = {
	"Name": "Gate",
	"Desc": descText,
	"Danger": 0
	};

func _process(_delta):
	if (isClosed == true):
		closeDoor();

func closeDoor():
	timer += 1;
	if (timer % 360 == 0):
		var tween = create_tween();
		tween.tween_property(self, "position", Vector3(0, -distance, 0), .5).as_relative().set_trans(Tween.TRANS_EXPO);
		await tween.finished;
		isClosed = false;

func onHit(_dmg = 0):
	if (isClosed == true):
		return;
	
	var tween = create_tween();
	tween.tween_property(self, "position", Vector3(0, distance, 0), .5).as_relative().set_trans(Tween.TRANS_EXPO);
	isClosed = true;

func getShader():
	material = $MeshInstance3D.get_surface_override_material(0);
	shader = material.get_next_pass();
	if (material == null or shader == null):
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
	
	if (enable == true):
		shader.set("shader_parameter/border_width", 0.06);
	else:
		shader.set("shader_parameter/border_width", 0.0);
		shader.set("shader_parameter/line_sharpness", 1);
		shader.set("shader_parameter/wave", true);
