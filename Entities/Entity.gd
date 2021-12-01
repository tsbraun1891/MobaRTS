extends KinematicBody

class_name Entity

signal death

export(int) var maxHealth = 100 setget setMaxHealth
export(int) var armor = 0
export(float) var healthbarHeight = 0.0
export var team = 0
export(Array, int) var allies = []

onready var healthbar := $HealthBar
onready var deathTimer := $DeathTimer

var health := 100 setget setHealth
var team_colors = {
	0: preload("res://Entities/Actors/NeutralMat.tres"),
	1: preload("res://Entities/Actors/PlayerMat.tres"),
	2: preload("res://Entities/Actors/AllyMat.tres"),
	3: preload("res://Entities/Actors/EnemyMat.tres")
}

func _ready():
	healthbar.translation.y = healthbarHeight
	health = maxHealth
	if team in team_colors:
		$MeshInstance.material_override = team_colors[team]

func setMaxHealth(value):
	if value and value > 0:
		var oldMax = maxHealth
		maxHealth = value
		if healthbar:
			healthbar.setMaxValue(value)
		if oldMax < maxHealth:
			self.health += (maxHealth - oldMax)
		else:
			self.health = self.health 
		
		if healthbar:
			healthbar.updateHealthbar(self.health)

func setHealth(value):
	if value != null:
		health = clamp(value, 0, maxHealth)
		if healthbar:
			healthbar.updateHealthbar(health)

# Entity takes damage and then returns True if still alive
func takeDamage(damageValue):
	self.health -= damageValue
	
	if self.health <= 0:
		emit_signal("death")
		deathTimer.start()

func _on_DeathTimer_timeout():
	queue_free()
