extends Resource;
class_name PlayerUpgrades;

@export var upgrades: Array[String];
@export var weapons: Array[PlayerWeaponList];
@export var weaponPos: int;
@export var playerPos: Vector3;
@export var playerRotation: Basis;

func addUpgrade(upgradeId):
	if (upgrades.find(upgradeId) == -1): # if upgradeId can't be found
		upgrades.insert(len(upgrades), upgradeId);

func addWeapon(weaponListObject):
	if (weapons.find(weaponListObject) == -1): # if weapon can't be found
		weapons.insert(len(weapons), weaponListObject);

func savePlayerPos(lastPos, lastRot):
	playerPos = lastPos;
	playerRotation = lastRot;
