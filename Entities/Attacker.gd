# The Attacker class will function as if it was an interface
# The idea is this scene should be able to be plugged into any existing entity, and work out of the box
# It will handle targeting, attacking, and dealing damage to units
# Should release a signal when
extends Spatial

signal attacking
signal attackStopped
signal windup
signal newTarget

const recheckTargetTime := 1.0

# DetectionRange and attackRange should be the same for static Attackers
export(float) var detectionRange = 30.0
export(float) var attackRange = 1.5
# Time beteween attacks
export(float) var attackCooldown = 2.0
# Time it takes to actually attack (like animation)
export(float) var windupTime = .75
export(float) var attackValue = 40.0

onready var detectionCollision := $DetectionArea/CollisionShape
onready var attackCollision := $AttackArea/CollisionShape
onready var attackArea := $AttackArea
onready var attackTimer := $AttackTimer
onready var windupTimer := $WindupTimer
onready var recheckTimer := $RecheckTarget
onready var entity : Entity = get_parent()

var enemiesInRange := []
var target : Entity = null setget setTarget
var targetOfAttack : Entity = null 
var attacking : bool = false
var targetInRange : bool = false
var mayAttack : bool = false

func _ready():
	if detectionRange <= 0:
		detectionRange = attackRange
		
	var attackShape : SphereShape = SphereShape.new()
	attackShape.radius = attackRange
	attackCollision.shape = attackShape
	
	var detectionShape : SphereShape = SphereShape.new()
	detectionShape.radius = detectionRange
	detectionCollision.shape = detectionShape
	
	attackTimer.wait_time = attackCooldown
	windupTimer.wait_time = windupTime
	recheckTimer.wait_time = recheckTargetTime

func attackTarget():
	if mayAttack and target:
		windupTimer.start()
		targetOfAttack = target
		emit_signal("attacking")
	else:
		attackTimer.start()

func damageTarget():
	attacking = false
	attackTimer.start()
	targetOfAttack.takeDamage(attackValue)

# Connect target's death signal to _on_target_death, and disconnect old signal
func setTarget(newTarget : Entity):
	if target:
		target.disconnect("death", self, "_on_target_death")
	target = newTarget
	targetInRange = false
	if newTarget:
		newTarget.connect("death", self, "_on_target_death")
		# Have to manually check overlap on new assignment
		if attackArea.overlaps_body(newTarget):
			targetInRange = true
			if attackTimer.is_stopped():
				attackTarget()
	
	emit_signal("newTarget")

func getNewTarget():
	if enemiesInRange.size() > 0:
		self.target = enemiesInRange[0]
	else:
		self.target = null
		targetInRange = false

func hasTarget():
	return target != null

func isAttacking():
	return not windupTimer.is_stopped()

# If Target dies, get a new target
func _on_target_death():
	enemiesInRange.erase(target)
	self.getNewTarget()
	
	# Reset all attacking, only do this on target death 
	windupTimer.stop()
	emit_signal("attackStopped")

func _on_DetectionArea_body_entered(body):
	var newBody := body as Entity
	if not (newBody.team == entity.team or entity.allies.has(newBody.team)):
		if enemiesInRange.size() <= 0:
			self.target = newBody
		enemiesInRange.append(newBody)

func _on_DetectionArea_body_exited(body):
	enemiesInRange.erase(body)
	if body == target:
		getNewTarget()

# When body enters attack range, check if body is target
func _on_AttackArea_body_entered(body):
	if target and body == target:
		targetInRange = true
		if attackTimer.is_stopped():
			self.attackTarget()

# Target left attack range
func _on_AttackArea_body_exited(body):
	if target and body == target:
		targetInRange = false

func _on_AttackTimer_timeout():
	if targetInRange:
		self.attackTarget()

func _on_RecheckTarget_timeout():
	if not self.isAttacking():
		var minDist = detectionRange
		var minPos = -1
		for i in range(enemiesInRange.size()):
			var enemyEntity = enemiesInRange[i] as Entity
			var distToEnemy = self.global_transform.origin.distance_to(enemyEntity.global_transform.origin)
			if distToEnemy < minDist:
				minDist = distToEnemy
				minPos = i
				
		if minPos >= 0 and enemiesInRange[minPos] != target:
			self.target = enemiesInRange[minPos]
