extends MeshInstance3D

@export var isWeapon : bool = false;
@export var item : String = "";
@export var line1: String = "";
@export var line2: String = "";
@export var line3: String = "";
@export var line4: String = "";

var descText: Array[String] = [];

var debounce = 0;

func _ready():
	if (item == ""):
		print("no item was given for " + self.name);
	
	descText.insert(len(descText), line1);
	if (line2 != ""):
		descText.insert(len(descText), line2);
	if (line3 != ""):
		descText.insert(len(descText), line3);
	if (line4 != ""):
		descText.insert(len(descText), line4);

func _process(delta):
	if (debounce > 0):
		debounce -= delta;

func onBodyEntered(body):
	if (body.has_method("grantUpgrade")):
		body.grantUpgrade(item, descText, isWeapon);
