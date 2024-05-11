extends CharacterBody3D

# setup vars
# UI
@onready var fpsUI = $FirstPersonUI;
@onready var hpLabel = $FirstPersonUI/statusUI/hpLabel;
@onready var scanUI = $scanUI;
@onready var textUI = $scanUI/textUI;
@onready var textHolder = $scanUI/textUI/textHolderName;
@onready var scanTextName = $scanUI/textUI/scanTextName;
@onready var debugLabel = $FirstPersonUI/debugLabel;
@onready var shootPoint = $neck/camOrigin/shootPoint/bulletRay;
@onready var underwaterBG = $FirstPersonUI/underwaterBG;

@onready var upgradeUI = $scanUI/upgradeUI;
@onready var barBg = $scanUI/upgradeUI/barBG;
@onready var bar = $scanUI/upgradeUI/barBG/bar;
@onready var barPercent = $scanUI/upgradeUI/barBG/barPercent;
@onready var itemWheel = $overlayScreen/itemWheel;
@onready var menuUI = $menuUI;

# camera
@onready var neck = $neck;
@onready var pivot = $neck/camOrigin;
@onready var head = $neck/camOrigin/head;
@onready var camera = $neck/camOrigin/head/MainCamera;

# shaders
@onready var pixelShader = $camShaders/pixelShader;
@onready var scanShader = $camShaders/scanShader;
@onready var blurShader = $camShaders/blurShader;
@onready var underwaterShader = $camShaders/underwaterShader

# meshes
@onready var pModel = $playerModel;

#collisions
@onready var standingCollision = $standingCollision;
@onready var crouchingCollision = $crouchingCollision;

# raycasts
@onready var POVRaycast = $neck/camOrigin/head/MainCamera/RayCast3D;
@onready var crouchRaycast = $crouchRaycast;
@onready var leftRay = $rayCasts/leftRay;
@onready var rightRay = $rayCasts/rightRay

# sounds
@export var shootSound: AudioStream;
@export var slashSound: AudioStream;

# preloads
var glowTest = preload("res://Assets/Materials/glowTest.tres");
var waterSplash = preload("res://Assets/Scenes/waterSplash.tscn");
var smallWaterSplash = preload("res://Assets/Scenes/smallWaterSplash.tscn");
var cyanBullet = load("res://Assets/Scenes/Bullets/cyanBullet.tscn");

var saveFilePath = "user://data.tres";

# empty vars
var instance;
var objectOnSight;

# water handler
var canSubmerge = false;
var isUnderwater = false;
var waterHeight = 0.0;
var waterWaves = 0.0;
var curWaterSource;

#mouse params
var mouseSens = 0.2;
var normalGravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var gravity = normalGravity;
var underWaterGravity = gravity * 0.5;

# visuals and effects
var glowSpeed = 1.25;
var glowDirection = 0.01;
var suitGlow = 0.0;
var waterParticles;

# timers
var timer = 0;
var invisFrames = 0;
var actionCooldown = 0;

# speed and gravity
var storedSpeed = 0;
var normalSpeed = 5.0;
var crouchingSpeed = 4.0;
var underWaterSpeed = 2.5;
var curSpeed = normalSpeed;
var normalJump = 9;
var underWaterJump = 7.5;

var jumpStrenght = normalJump;
var maxJumps = 2;
var curJumps = 0;

var dashTimer = 0.0;
const dashTimerMax = 1.0;
var dashVector = Vector2.ZERO;
var dashSpeed = 29.0;
var dashCooldown = 0;
const dashCooldownMax = 75;

# weapons and bullets
var weaponPos = 0;
var weaponDamage = 1;
var weaponModel;
var weaponRaycast = null;
var curWeapon = null;
var weaponAnimPlayer = null
var storedWeapon = null;
var isAttackCharged = false;
var canChargeAttack = false;

# bullet vars
var curBullet = null;
var curState = null;
var attackCharge = 0;
var attackCooldown = 0;
var timesAttacked = 0;
var maxShotsBeforeCharge = 0;
var attackDelay = 15;

# player parameters ---------------------
var paused = false;
var canUnpause = true;

const comboMaxTime = 0.75;
var comboTimer = 0;

var maxHealth = 50;
var curHealth = maxHealth;

var isCrouching = false;
var isDashing = false;
var isWallRunning = false;
var onItemWheel = false;
var meleeWeapon = false;
var vulnerable = true;

const doubleTapDelay = 0.24;
var doubleTapTime = 0;
var lastKeyPressed = 0;
var lastDoubleTap = "";

var direction = Vector3.ZERO;
var lerpSpeed = 14.0;
var crouchSpeed = 10.0;

# camera and scanner
var cameraDebounce = false;
var scanMode = false;
var isScanning = false;
var lockScanMode = false;
var firstPerson = true;

const crouchingCamPos = -1.0;
const headBopSpeed = 10.0;
const headBopIntensity = 0.15;
const headRotationAmount = 5.0;
var headBopVector = Vector2.ZERO;
var headBopIndex = 0.0;
var headBopCurIntensity = 0.0;

# player upgrades
var playerUpgrades: PlayerUpgrades = PlayerUpgrades.new();

func _ready():
	# hide meshes
	$neck/camOrigin/head/MainCamera/weapons/weaponTest/MeshInstance3D.hide();
	$neck/camOrigin/head/MainCamera/weapons/weaponKnife/MeshInstance3D.hide();
	pModel.hide();
	
	# setup vars
	var defaultWeapon = PlayerWeaponList.new();
	defaultWeapon.name = "melee";
	defaultWeapon.atlas = load("res://Assets/Sprites/2.png");
	defaultWeapon.region = Rect2(0, 0, 368, 224);
	playerUpgrades.addWeapon(defaultWeapon);
	itemWheel.options = playerUpgrades.weapons;
	
	playerUpgrades.upgrades.insert(len(playerUpgrades.upgrades), "Dash");
	
	updateWeapon(0);
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func loadGame():
	playerUpgrades = ResourceLoader.load(saveFilePath).duplicate(true);
	global_position = playerUpgrades.playerPos;
	global_transform.basis = playerUpgrades.playerRotation;
	itemWheel.options = playerUpgrades.weapons;
	weaponPos = playerUpgrades.weaponPos;
	updateWeapon(weaponPos);
	print("game loaded!");

func saveGame():
	playerUpgrades.savePlayerPos(global_position, global_transform.basis);
	playerUpgrades.weaponPos = weaponPos;
	ResourceSaver.save(playerUpgrades, saveFilePath);
	print("game saved!");

func _input(event):
	if (paused):
		return;
		
	# handle double tapping
	if (event is InputEventKey and event.is_released()):
		if (lastKeyPressed == event.keycode and doubleTapTime >= 0 and isDashing == false):
			lastDoubleTap = String.chr(event.keycode);
			lastKeyPressed = 0;
		else:
			lastDoubleTap = "";
			lastKeyPressed = event.keycode;
		doubleTapTime = doubleTapDelay;
	
	# handle camera rotation (with mouse)
	if (onItemWheel):
		return;
	
	if (event is InputEventMouseMotion):
		if (firstPerson == true):
			camera.rotate_x(deg_to_rad(event.relative.y * mouseSens * -1));
			self.rotate_y(deg_to_rad(event.relative.x * mouseSens * -1));
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75));
		elif (firstPerson == false):
			rotate_y(deg_to_rad(-event.relative.x * mouseSens));
			pivot.rotate_x(deg_to_rad(-event.relative.y * mouseSens));
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-71), deg_to_rad(71));
	
	# swap between first and third person
	if (event is InputEventMouseButton):
		if (cameraDebounce == true):
			return;
			
		if (event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed):
			changeCameraPerspective(false);
		if (event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed):
			changeCameraPerspective(true);

func _process(delta):
	checkFOV();
	updateUI();
	handleTimers(delta);
	simulateWaterWaves();
	updateGlowMaterial();
	
	debugLabel.text = "weapon: " + str(curWeapon);
	
	if (Input.is_action_just_pressed("exit")):
		paused = !paused;
		get_tree().call_group("Pausable", "pauseGame", paused);
	
	if (paused):
		return;
	
	# manage item wheel
	if (Input.is_action_just_pressed("itemWheel") and scanMode == false):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
		blurShader.visible = true;
		itemWheel.visible = true;
		onItemWheel = true;
		
	if (Input.is_action_just_released("itemWheel")):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		blurShader.visible = false;
		onItemWheel = false;
		
		var newWeapon = playerUpgrades.weapons.find(itemWheel.getItem(curWeapon));
		if (newWeapon != -1):
			updateWeapon(newWeapon);
	
	if (onItemWheel):
		return;
	
	# clicks
	if (Input.is_action_pressed("primary")):
		if (meleeWeapon == false):
			attack();
		else:
			chargeAttack();
		
	if (Input.is_action_just_pressed("primary")):
		if (scanMode == true and objectOnSight and "scanText" in objectOnSight):
			var lines = objectOnSight.scanText.get("Desc");
			var header = objectOnSight.scanText.get("Name");
			scanObject(header, lines);
	
	if (Input.is_action_just_released("primary")):
		if (meleeWeapon == true):
			attack();
			return;
	
	if (Input.is_action_just_pressed("secondary")):
		toggleScanner();
	
	# keybinds
	if (Input.is_action_just_pressed("restart")):
		canSubmerge = !canSubmerge;
	
	if (Input.is_action_just_pressed("nextWeapon") and scanMode == false):
		weaponPos += 1;
		updateWeapon();
	
	if (Input.is_action_just_pressed("prevWeapon") and scanMode == false):
		weaponPos -= 1;
		updateWeapon();
	
	if (Input.is_action_just_pressed("testButton1")):
		loadGame();
	if (Input.is_action_just_pressed("testButton2")):
		saveGame();

func _physics_process(delta):
	if (paused):
		return;
		
	var input_dir = Input.get_vector("mLeft", "mRight", "mForward", "mBackward");
	
	# handle crouching state
	if (Input.is_action_pressed("crouch")):
		if (isCrouching == false):
			isCrouching = true;
			standingCollision.disabled = true;
			crouchingCollision.disabled = false;
			
			storedSpeed = curSpeed;
			curSpeed -= curSpeed * 0.25;
		camera.position.y = lerp(camera.position.y, crouchingCamPos, delta * crouchSpeed);
	elif (!crouchRaycast.is_colliding()):
		if (isCrouching == true):
			isCrouching = false;
			standingCollision.disabled = false;
			crouchingCollision.disabled = true;
			
			curSpeed = storedSpeed;
		camera.position.y = lerp(camera.position.y, 0.0, delta * crouchSpeed);
	
	# handle dashing state
	if (Input.is_action_pressed("dash") and input_dir != Vector2.ZERO and dashCooldown <= 0
		and isWallRunning == false):
		if (playerUpgrades.upgrades.find("Dash") != -1):
			isDashing = true;
			dashTimer = dashTimerMax;
			dashCooldown = dashCooldownMax;
			dashVector = input_dir;
	
	# dashing
	if (isDashing):
		dashTimer -= 0.05;
		if (dashTimer <= 0):
			isDashing = false;
	
	# handle wall run
	if (Input.is_action_pressed("dash") and (leftRay.is_colliding() or rightRay.is_colliding())):
		isWallRunning = true;
		camera.rotation.z = lerp(camera.rotation.z, deg_to_rad(headRotationAmount), delta * lerpSpeed);
	
	if (Input.is_action_just_released("dash") or (!leftRay.is_colliding()) and !rightRay.is_colliding()):
		isWallRunning = false;
		var tween = create_tween();
		tween.tween_property(camera, "rotation:z", 0.0, 0.1);
	
	# handle head bopping
	headBopCurIntensity = headBopIntensity;
	headBopIndex += (headBopSpeed) * delta;
	
	if (is_on_floor() and !isDashing and input_dir != Vector2.ZERO):
		headBopVector.y = sin(headBopIndex);
		headBopVector.x = sin(headBopIndex/2) * 0.5;
		
		head.position.y = lerp(head.position.y, headBopVector.y * (headBopIntensity / 2), delta * lerpSpeed);
		head.position.x = lerp(head.position.x, headBopVector.x * headBopIntensity, delta * lerpSpeed);
	else:
		head.position.y = lerp(head.position.y, 0.0, delta * lerpSpeed);
		head.position.x = lerp(head.position.x, 0.0, delta * lerpSpeed);
	
	# movement and gravity
	if (!is_on_floor()):
		if (isWallRunning == false):
			velocity.y -= gravity * delta;
		else:
			velocity.y = 0
	else:
		curJumps = 0;
	
	if (isUnderwater):
		if (canSubmerge == false):
			velocity.y = waterWaves;
		curJumps = 0;
	
	if (Input.is_action_just_pressed("ui_accept")):
		if (curJumps < maxJumps):
			velocity.y = jumpStrenght;
			curJumps += 1;
	
	direction = lerp(direction, transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized(), delta * lerpSpeed);
	if (isDashing == true):
		direction = transform.basis * Vector3(dashVector.x, 0, dashVector.y).normalized();
	
	if direction:
		velocity.x = direction.x * curSpeed;
		velocity.z = direction.z * curSpeed;
		
		if (isDashing):
			velocity.x = direction.x * dashTimer * dashSpeed;
			velocity.z = direction.z * dashTimer * dashSpeed;
	else:
		velocity.x = move_toward(velocity.x, 0, curSpeed);
		velocity.z = move_toward(velocity.z, 0, curSpeed);
	
	move_and_slide();
	
	# underwater simulation
	if (curWaterSource != null):
		var depth = waterHeight - global_position.y;
		if (depth > 2.3):
			underwaterShader.visible = true;
			underwaterBG.visible = true;
		if (depth > 1.55):
			underWaterPhysics(true);
			return;
		
		underwaterShader.visible = false;
		underwaterBG.visible = false;
		underWaterPhysics(false);

func updateUI():
	hpLabel.text = "Health: " + str(curHealth) + "/" + str(maxHealth);

func handleTimers(delta = 0):
	if (paused):
		return;
	
	doubleTapTime -= delta;
	
	if (comboTimer > 0):
		comboTimer -= delta;
	else:
		timesAttacked = 0;
	
	if (attackCooldown > 0):
		attackCooldown -= delta;
	
	if (dashCooldown > 0):
		dashCooldown -= 1;
	
	if (cameraDebounce == true):
		timer += 1;
		if (timer % 60 == 0):
			cameraDebounce = false;
	
	if (vulnerable == false):
		invisFrames += 1;
		if (invisFrames % 60 == 0):
			vulnerable = true;
			
	if (actionCooldown > 0):
		actionCooldown -= 1;

func simulateWaterWaves():
	if (!isUnderwater):
		waterWaves = -1.9;
		return;
	waterWaves += 0.1;

func updateWeapon(pos = -1):
	# update pos in list
	if (pos != -1):
		weaponPos = pos;
	
	if (weaponPos < 0):
		weaponPos = len(playerUpgrades.weapons) - 1;
	elif (weaponPos >= len(playerUpgrades.weapons)):
		weaponPos = 0;
	curWeapon = playerUpgrades.weapons[weaponPos].name;
	
	# update bullet
		# hide previous weapon before changing
	if (weaponModel):
		weaponAnimPlayer.play("bringDown");
		await get_tree().create_timer(.35).timeout;
		weaponModel.hide();
	
	#reset weapon vars
	attackCharge = 0;
	
	match (curWeapon):
		"default":
			weaponModel = $neck/camOrigin/head/MainCamera/weapons/weaponTest/MeshInstance3D;
			curBullet = cyanBullet;
			weaponDamage = 1;
			attackDelay = 0.24;
			maxShotsBeforeCharge = 2;
			meleeWeapon = false;
		"melee":
			weaponModel = $neck/camOrigin/head/MainCamera/weapons/weaponKnife/MeshInstance3D;
			weaponDamage = 1;
			attackDelay = 0.24;
			meleeWeapon = true;
		_:
			weaponModel = $neck/camOrigin/head/MainCamera/weapons/weaponTest/MeshInstance3D;
			attackDelay = 0.25;
			meleeWeapon = false;
			curBullet = cyanBullet;
	
	weaponRaycast = weaponModel.get_parent().get_node("bulletRay");
	weaponAnimPlayer = weaponModel.get_parent().get_node("animPlayer");
	
	weaponModel.show();
	weaponAnimPlayer.play("bringUp");

func updateGlowMaterial():
	suitGlow += glowDirection * glowSpeed;
	
	if (suitGlow >= 1):
		glowDirection = -0.01;
	if (suitGlow <= 0):
		glowDirection = 0.01;
		
	glowTest.albedo_color = Color(suitGlow * 0.2, suitGlow * 0.8, suitGlow * 0.65, 0.0);
	glowTest.emission = glowTest.albedo_color;

func underWaterPhysics(enable):
	if (isUnderwater != enable):
		isUnderwater = enable;
		
		if (canSubmerge == true):
			waterParticles = waterSplash;
		else:
			waterParticles = smallWaterSplash;
		
		if (enable == true):
			var splash = Global.instantiate_node(waterParticles, global_position, self);
			splash.emitting = true;
			curSpeed = underWaterSpeed;
			gravity = underWaterGravity;
			jumpStrenght = underWaterJump;
		else:
			curSpeed = normalSpeed;
			gravity = normalGravity;
			jumpStrenght = normalJump;

func attack():
	if (curWeapon == null or scanMode == true or attackCooldown > 0):
		return;
	
	weaponAnimPlayer.stop();
	attackCooldown = attackDelay;
	timesAttacked += 1;
	
	if (meleeWeapon):
		var hitbox = weaponModel.get_parent().get_node("hitBox").get_node("collisionShape");
		var hitboxDuration = 0.2;
		var hitBoxTimer = weaponModel.get_parent().get_node("Timer");
		var slashAnims = ["slashAnim1", "slashAnim2", "slashAnim3"];
		
		if (attackCharge < 35):
			weaponDamage = 1;
			weaponAnimPlayer.play(slashAnims[timesAttacked - 1]);
			$neck/camOrigin/head/MainCamera/slashEffect.get_node("animPlayer").play("slashAnim");
		else:
			weaponDamage = 2;
			weaponAnimPlayer.play("slashCharged");
			$neck/camOrigin/head/MainCamera/slashEffect2.get_node("animPlayer").play("slashAnim");
		hitbox.get_parent().get_parent().dmg = weaponDamage;
		
		hitBoxTimer.start(hitboxDuration);
		hitbox.disabled = false;
		
		if (timesAttacked >= 3):
			timesAttacked = 0;
		
		comboTimer = comboMaxTime;
		attackCharge = 0;
		
		AudioManager.playSound(slashSound, randf_range(0.6, 1.5));
		
		return;
	
	weaponAnimPlayer.play("shootAnim");
	AudioManager.playSound(shootSound);
	
	var origin = weaponRaycast;
	if (firstPerson == false):
		origin = shootPoint;
	
	instance = curBullet.instantiate();
	instance.position = origin.global_position;
	instance.transform.basis = camera.global_transform.basis;
	get_parent().add_child(instance);


func chargeAttack():
	if (scanMode == true):
		return;
	
	if (!weaponAnimPlayer.is_playing()):
		weaponAnimPlayer.play("chargAnim");
	attackCharge += 1;

func changeWaterHeight(water):
	curWaterSource = water;
	waterHeight = water.global_position.y;

func checkFOV():
	if (scanMode == false):
		if (objectOnSight and objectOnSight.has_method("onPlayerFOV")):
			objectOnSight = null;
		return;
	
	if (POVRaycast.is_colliding()):
		var colliding = POVRaycast.get_collider();
		
		if (colliding != objectOnSight):
			if (colliding and colliding.has_method("onPlayerFOV")):
				colliding.onPlayerFOV(true);
			if (objectOnSight and objectOnSight.has_method("onPlayerFOV")):
				objectOnSight.onPlayerFOV(false);
				
			objectOnSight = colliding;

func scanObject(header: String = "Unknown", text: Array[String] = ["Unable to identify."]):
	if (isScanning):
		return;
		
	scanTextName.text = header;
	isScanning = true;
	lockScanMode = true;
	
	textHolder.set("position", Vector2(32, -50));
	scanTextName.set("position", Vector2(32, -50));
	textUI.show();
	
	await get_tree().create_timer(0.25).timeout;
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true);
	tween.tween_property(textHolder, "position:y", 30, 1);
	tween.tween_property(scanTextName, "position:y", 40, 1);
	
	await get_tree().create_timer(0.65).timeout;
	
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO);
	
	DialogueManager.startDialogue(Vector2(320, 195), text, "scanner");

func scanDialogue(action):
	if (action == "start"):
		lockScanMode = false;
		return;
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true);
	tween.tween_property(textHolder, "position:y", -50, 1);
	tween.tween_property(scanTextName, "position:y", -50, 1);
	
	await get_tree().create_timer(0.25).timeout;
	
	textUI.hide();
	isScanning = false;

func toggleScanner(forceMode = null):
	if (actionCooldown > 0 or lockScanMode == true):
		return;
	
	POVRaycast.force_raycast_update();
	
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_method(setPixelation, 0.06, 0.001, 0.6);
	
	scanMode = !scanMode;
	if (forceMode):
		print("forcing: " + str(forceMode));
		scanMode = forceMode;
	actionCooldown = 45;
	
	if (scanMode == true):
		tween.tween_method(setScanShader, 0.0, 0.5, 0.5);
		if (curWeapon != null):
			storedWeapon = curWeapon;
			curWeapon = null;
		scanUI.show();
	else:
		tween.tween_method(setScanShader, 1.0, 0.0, 0.5);
		if (storedWeapon):
			curWeapon = storedWeapon;
		scanUI.hide();
	
	get_tree().call_group("Scanneable", "onScanner", scanMode);

func grantUpgrade(item: String, desc: Array[String], isWeapon = false):
	if (isScanning):
		return;
	
	# add the item to the list
	if (playerUpgrades.upgrades.find(item) != -1):
		return;
	playerUpgrades.upgrades.insert(len(playerUpgrades.upgrades), item);
	
	if (isWeapon):
		var newItem = PlayerWeaponList.new();
		newItem.name = item;
		newItem.atlas = load("res://Assets/Sprites/1.png");
		newItem.region = Rect2(0, 0, 368, 224);
		playerUpgrades.addWeapon(newItem);
		itemWheel.options = playerUpgrades.weapons;
	
	# animation
	var tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC);
	toggleScanner(true);
	lockScanMode = true;
	scanUI.show();
	upgradeUI.show();
	barPercent.text = "0%";
	bar.scale.x = 0;
	
	tween.tween_property(bar, "scale:x", 1, 1.65);
	tween.tween_method(tweenText, 0, 94, 1.27);
	
	await get_tree().create_timer(1.3).timeout;
	barPercent.text = "Upgrade Compatible";
	
	await get_tree().create_timer(1.6).timeout;
	upgradeUI.hide();
	scanObject(item, desc);
	
	print(playerUpgrades.upgrades);

func setPixelation(value: float):
	pixelShader.get_material().set("shader_parameter/size_x", value);
	pixelShader.get_material().set("shader_parameter/size_y", value);

func setScanShader(value: float):
	scanShader.get_material().set("shader_parameter/intensity", value);
	scanShader.get_material().set("shader_parameter/intensity", value);

func tweenText(value: float):
	barPercent.text = str(value) + "%";

func changeCameraPerspective(FPS):
	if (firstPerson == FPS):
		return;
	cameraDebounce = true;
	timer = 0;
	firstPerson = FPS;
	
	var tween = create_tween();
	if (firstPerson == true): # zooming in
		tween.set_parallel(true);
		tween.tween_property(camera, "position", Vector3(0, 0, 0), 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT);
		tween.tween_property(pivot, "rotation", Vector3(0, 0, 0), 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT);
		await tween.finished;
		pModel.hide();
		weaponModel.show();
		fpsUI.show();
		
	else: # zooming out
		tween.set_parallel(true);
		tween.tween_property(camera, "position", Vector3(-.5, .5, 3), 1).set_trans(Tween.TRANS_EXPO).set_ease(tween.EASE_OUT);
		tween.tween_property(camera, "rotation", Vector3(0, 0, 0), 1).set_trans(Tween.TRANS_EXPO).set_ease(tween.EASE_OUT);
		pModel.show();
		weaponModel.hide();
		fpsUI.hide();

func hurtPlayer(dmg):
	if (vulnerable == false or paused):
		return;
		
	vulnerable = false;
	curHealth -= dmg;
	curHealth = clamp(curHealth, 0, maxHealth);
	
	if (curHealth <= 0):
		print("DED");
	print("damage player: " + str(dmg));

func restart():
	get_tree().reload_current_scene();

func upgradesInventory():
	var upgradesList = $menuUI/upgradesList/grid;
	if (!upgradesList): return;
	
	for label in upgradesList.get_children():
		label.queue_free();
	
	for upgrade in playerUpgrades.upgrades:
		var newUpgrade = Label.new();
		newUpgrade.text = "- " + upgrade;
		newUpgrade.name = upgrade;
		$menuUI/upgradesList/grid.add_child(newUpgrade);

func pauseGame(pause):
	upgradesInventory();
	
	print("pausing: " + str(pause));
	paused = pause;
	menuUI.visible = pause;
	if (pause):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
		return;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func playerDied():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;

func _onContinueButton():
	pauseGame(false);
