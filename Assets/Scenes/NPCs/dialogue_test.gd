extends Node3D

var dialogues: Array[String] = ["hello", "this is a test", "testing the textbox"];
var timer = 0.0;
	
func startDialogue():
	DialogueManager.startDialogue(Vector2(320, 305), dialogues, "dialogue");

func _process(delta):
	timer += delta;
	if (timer >= 3.0):
		timer = -10000;
		startDialogue();
