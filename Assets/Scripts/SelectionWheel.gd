@tool
extends Control

const spriteSize = Vector2(64, 64);

@export var bgColor: Color;
@export var lineColor: Color;
@export var highlightColor: Color;

@export var innerRadius: int = 32;
@export var outerRadius: int = 128;
@export var lineWidth: int = 2;

@export var options: Array[PlayerWeaponList];
var selectedWeapon = 0;

func _draw():
	var offset = spriteSize / -2.0;
	draw_circle(Vector2.ZERO, outerRadius, bgColor);
	draw_arc(Vector2.ZERO, innerRadius, 0, PI * 2, 256, lineColor, lineWidth, true);
	
	if (len(options) > 1):
		for i in range(len(options)):
			var rads = TAU * i / (len(options));
			var point = Vector2.from_angle(rads);
			draw_line(
				point * innerRadius,
				point * outerRadius,
				lineColor,
				lineWidth,
				true
			);
			
			var startRads = (TAU * (i - 1)) / len(options);
			var endRads = (TAU * i) / len(options);
			var midRads = (startRads + endRads) / 2.0 * -1;
			@warning_ignore("integer_division")
			var middleRadious = (innerRadius + outerRadius) / 2;
			
			if (selectedWeapon == i):
				var pointsPerArc = 32;
				var pointsInner = PackedVector2Array();
				var pointsOuter = PackedVector2Array();
				
				for j in range(pointsPerArc + 1):
					var angle = startRads + j * (endRads - startRads) / pointsPerArc;
					pointsInner.append(innerRadius * Vector2.from_angle(TAU - angle));
					pointsOuter.append(outerRadius * Vector2.from_angle(TAU - angle));
				
				pointsOuter.reverse();
				draw_polygon(
					pointsInner + pointsOuter,
					PackedColorArray([highlightColor])
				);
			
			var drawPos = middleRadious * Vector2.from_angle(midRads) + offset;
			draw_texture_rect_region(
				options[i].atlas,
				Rect2(drawPos, spriteSize),
				options[i].region
			);
		
		draw_texture_rect_region(
			options[selectedWeapon].atlas,
			Rect2(offset, spriteSize),
			options[selectedWeapon].region
		);

func _process(_delta):
	var mousePos = get_local_mouse_position();
	var mouseRadius = mousePos.length();
	
	if (mouseRadius >= innerRadius):
		var mouseRads = fposmod(mousePos.angle() * -1, TAU);
		selectedWeapon = ceil((mouseRads / TAU) * len(options));
		if (selectedWeapon == len(options)):
			selectedWeapon = 0;
	
	queue_redraw();

func getItem(curWeapon = null):
	visible = false;
	
	if (curWeapon and curWeapon == options[selectedWeapon].name):
		return;
	return options[selectedWeapon];

func addItem(item):
	options.insert(len(options), item);
	print("added");

func removeItem(item):
	var itemIndex = options.find(item);
	options.remove_at(itemIndex);
	print("removed " + item.name + " at index " + str(itemIndex));
