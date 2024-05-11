extends Node

@onready var textBoxScene = preload("res://Assets/Scenes/textBoxTest.tscn");

var dialogueLines: Array[String] = [];
var currentLineIndex = 0;

var textBox;
var textBoxPosition;
var curDialogueType;

var isDialogueActive = false;
var canAdvance = false;

func startDialogue(pos: Vector2, lines: Array[String], type = ""):
	if (isDialogueActive):
		return;
	dialogueLines = lines;
	textBoxPosition = pos;
	curDialogueType = type;
	showTextbox();
	
	isDialogueActive = true;
	
func showTextbox():
	get_tree().call_group("Player", "scanDialogue", "start");
	textBox = textBoxScene.instantiate();
	textBox.finishedDisplaying.connect(onTextBoxFinishedDisplaying);
	get_tree().root.add_child(textBox);
	textBox.global_position = textBoxPosition;
	textBox.createTextBox(dialogueLines[currentLineIndex]);
	canAdvance = false;
	
func onTextBoxFinishedDisplaying():
	canAdvance = true;
	
func _input(event):
	if (event.is_action_pressed("primary") and isDialogueActive and canAdvance):
		textBox.queue_free();
		currentLineIndex += 1;
		if (currentLineIndex >= dialogueLines.size()):
			endDialogue();
			return;
			
		showTextbox();
		
	if (isDialogueActive == true and event.is_action_pressed("secondary")
		and curDialogueType == "scanner"):
		textBox.queue_free();
		endDialogue();

func endDialogue():
	get_tree().call_group("Player", "scanDialogue", "end");
	isDialogueActive = false;
	currentLineIndex = 0;
	print("should close now");
