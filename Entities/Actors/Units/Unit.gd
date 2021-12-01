extends Actor

class_name Unit

# New States for units
# NO DIRECT TARGETING in this, units will either be aggressive or passive
const MOVE = 2
const AMOVE = 3
const HOLD = 4

var moveOrderVector : Vector3 = Vector3.ZERO

onready var commandableNode = $Commandable

func _ready():
	# On spawn, move to waypoint/along a specified path
	self.state = AMOVE
	if team == 1:
		self.attackMove(Vector3(8, 0, -8))

func attackMove(movePosition : Vector3):
	moveOrderVector = movePosition
	self.state = AMOVE
	self.move_to(movePosition)

func moveCommand(movePosition : Vector3):
	moveOrderVector = movePosition
	self.state = MOVE
	self.move_to(movePosition)

func moveToTarget():
	if state == AMOVE:
		if attackNode.hasTarget():
			getPathToTarget()
		else:
			path_ind = path.size()
	.moveToTarget()

func _physics_process(delta):
	if state == MOVE:
		if not self.moveProcess():
			# After finishing a MOVE command, unit will sit passively unless attacked
			self.state = HOLD
	# Need to split AOS and AMOVE, because AOS is for when idling and then attacked
	elif state == AMOVE:
		if not attackNode.hasTarget() and path_ind >= path.size():
			# Need to make sure it has finished previous move so that this does not get called every time
			# Could change this later because when target goes out of range, we don't want to follow it anymore
			self.move_to(moveOrderVector)
		else:
			self.aosProcess()
	elif state == HOLD:
		if attackNode.targetInRange:
			self.look_at(attackNode.target.global_transform.origin, Vector3.UP)

func setState(value : int):
	if value == AOS or value == AMOVE or value == HOLD:
		attackNode.mayAttack = true
		state = value
		moveToTarget()
	elif value == IDLE or value == MOVE:
		attackNode.mayAttack = false
		state = value
