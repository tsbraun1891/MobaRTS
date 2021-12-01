extends Entity

class_name Actor

export var pathRecalculationTime := 0.5
export(bool) var debug = false

const move_speed = 8
# States
# AOS = AttackOnSight
const IDLE = 0
const AOS = 1

onready var nav := get_parent() as Navigation
onready var attackNode := $Attacker
onready var pathTimer := $PathTimer
onready var animation := $AnimationPlayer

var path = []
var path_ind = 0
var state = IDLE setget setState
 
func _ready():
	attackNode.connect("attacking", self, "_on_attacking")
	attackNode.connect("newTarget", self, "moveToTarget")
	attackNode.connect("attackStopped", self, "stopAttack")
	pathTimer.connect("timeout", self, "moveToTarget")
	
	pathTimer.wait_time = pathRecalculationTime
 
func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, nav.get_closest_point(target_pos))
	path_ind = 0

func getPathToTarget():
	move_to(attackNode.target.global_transform.origin)
	if pathTimer.is_stopped():
		pathTimer.start()

func moveToTarget():
	if state == AOS:
		if attackNode.hasTarget():
			getPathToTarget()
		else:
			path_ind = path.size()
 
func _physics_process(delta):
	if state == AOS:
		self.aosProcess()

func moveProcess() -> bool:
	var morePath : bool = path_ind < path.size()
	if morePath:
		var move_vec = (path[path_ind] - global_transform.origin)
		if path_ind > 0:
			self.look_at(self.translation+move_vec, Vector3.UP)
		if move_vec.length() < 1:
			path_ind += 1
		else:
			move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))
	
	return morePath

func aosProcess():
	if not (attackNode.targetInRange or attackNode.isAttacking()):
		moveProcess()
	elif attackNode.hasTarget():
		self.look_at(attackNode.target.global_transform.origin, Vector3.UP)

func takeDamage(value):
	if self.state == IDLE:
		self.state = AOS
	.takeDamage(value)

func setState(value : int):
	if value == AOS:
		attackNode.mayAttack = true
		state = value
		moveToTarget()
	elif value == IDLE:
		attackNode.mayAttack = false
		state = value

func stopAttack():
	animation.stop(true)
	animation.play("RESET")

func _on_attacking():
	# Play attack animation
	animation.playback_speed = 1/attackNode.windupTime
	animation.play("Attack")
