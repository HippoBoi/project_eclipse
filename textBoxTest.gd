extends MarginContainer

@onready var label = $MarginContainer/Label;
@onready var timer = $letterDisplayTimer;

const maxWidth = 256;

var text = "";
var letterIndex = 0;
var letterTime = 0.001;
var spaceTime = 0.03;
var puntuactionTime = 0.05;
var periodTime = 0.1;

signal finishedDisplaying;

func createTextBox(textToDisplay: String):
	text = textToDisplay;
	label.text = textToDisplay;
	
	await resized;
	
	custom_minimum_size.x = min(size.x, maxWidth);
	if (size.x > maxWidth):
		label.autowrap_mode = TextServer.AUTOWRAP_WORD;
		await resized; # x resize
		await resized; # y resize
		
		custom_minimum_size.y = size.y;
	global_position.x -= size.x / 2;
	global_position.y -= size.y / 2;
	
	label.text = "";
	displayLetter();

func displayLetter():
	label.text += text[letterIndex]
	letterIndex += 1;
	if (letterIndex >= text.length()):
		finishedDisplaying.emit();
		return;
	
	match text[letterIndex]:
		"!", ",", "?":
			timer.start(puntuactionTime);
		".":
			timer.start(periodTime);
		" ":
			timer.start(spaceTime);
		_:
			timer.start(letterTime);


func _on_letter_display_timer_timeout():
	displayLetter();
