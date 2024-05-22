extends Node

@onready var textBoxScene = preload("res://Assets/Scenes/textBoxTest.tscn");
@onready var textBoxDialogueScene = preload("res://Assets/Scenes/textBoxDialogue.tscn");

var dialogueLines: Array[String] = [];
var currentLineIndex = 0;

var textBox;
var textBoxPosition;
var curDialogueType;
var pauseMovement;

var isDialogueActive = false;
var canAdvance = false;

func startDialogue(pos: Vector2, lines: Array[String], type: String = "", pause: bool = false):
	if (isDialogueActive):
		return;
	dialogueLines = lines;
	textBoxPosition = pos;
	curDialogueType = type;
	pauseMovement = pause;
	showTextbox();
	
	if (pause):
		get_tree().call_group("Pausable", "pauseGame", true);
	
	isDialogueActive = true;
	
func showTextbox():
	get_tree().call_group("Player", "scanDialogue", "start", pauseMovement);
	if (curDialogueType == "scanner"):
		textBox = textBoxScene.instantiate();
	else:
		textBox = textBoxDialogueScene.instantiate();
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
	get_tree().call_group("Pausable", "pauseGame", false);
	isDialogueActive = false;
	currentLineIndex = 0;
