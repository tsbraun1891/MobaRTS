extends Unit

class_name Commander

# Maybe come up with better formations that will split unit based on type
enum FORMATION {
	WEDGE,
	RING,
	COLUMNF,
	COLUMNB
}

const moveIndicator = preload("res://UI/MoveIndicator.tscn")

var _squad := []
# When current formation is set, if there is no current move order,
# we should execute a move order on the commander's current pos so that
# the formation changes
var currentFormation = FORMATION.RING

# Called when the node enters the scene tree for the first time.
func _ready():
	var commandables = get_tree().get_nodes_in_group('units')
	
	for commandable in commandables:
		if commandable.unit != self and commandable.team == 1:
			self.addUnitToSquad(commandable.unit)

func attackMove(movePosition : Vector3):
	.attackMove(movePosition)
	# Tell units in squad where to attack move based on formation
	var formationPositions = getFormation(movePosition)
	
	for i in range(_squad.size()):
		var unit := _squad[i] as Unit
		unit.attackMove(formationPositions[i])

func moveCommand(movePosition : Vector3):
	.moveCommand(movePosition)
	# # Tell units in squad where to move based on formation
	var formationPositions = getFormation(movePosition)
	
	"""for pos in formationPositions:
		pos.y = 0
		var newInd = moveIndicator.instance()
		get_tree().get_root().add_child(newInd)
		newInd.global_transform.origin = pos"""
	
	for i in range(_squad.size()):
		var unit := _squad[i] as Unit
		unit.moveCommand(formationPositions[i])

# Given the position moved to, this function generates move coordinates
# for the number of units in the squad based off of the direction the
# move order is in
func getFormation(movePosition : Vector3) -> Array:
	# As of right now just use the direction from commander's current position
	# to the move order in order to decide on facing. Later may use something
	# a little more accurate like second to last point on simple path.
	var directionToMove := self.global_transform.origin.direction_to(movePosition)
	var squadSize := _squad.size()
	# How much space should be between units
	var spacing := 3.5
	var rhet := []
	
	if squadSize > 0:
		match currentFormation:
			FORMATION.WEDGE:
				var tipOfWedge := movePosition + directionToMove*spacing
				
				for i in range(squadSize):
					var dist := i / 2
					var deg := 145
					if i % 2 == 1:
						# Add 1 to dist for odd numbers
						dist += 1
						deg *= -1
						
					var newPos = tipOfWedge + directionToMove.rotated(Vector3.UP, deg2rad(deg)) * dist * spacing
					
					rhet.append(newPos)
				
			FORMATION.RING:
				# method breaks at > 12
				var offsetRotation := 180
				var rotationAmount := 90
				var rotatedVector = directionToMove
				
				for i in range(squadSize):
					if i % 4 == 0:
						offsetRotation = offsetRotation/2
						rotationAmount = offsetRotation
					else:
						rotationAmount = 90
					
					rotatedVector = rotatedVector.rotated(Vector3.UP, deg2rad(rotationAmount))
					var newPos = movePosition + rotatedVector * spacing
					
					rhet.append(newPos)
				
			FORMATION.COLUMNF:
				pass
				
			FORMATION.COLUMNB:
				pass
				
				
	return rhet

func addUnitToSquad(newUnit : Unit):
	_squad.append(newUnit)

func addListToSquad(newUnits : Array):
	for newUnit in newUnits:
		self.addUnitToSquad(newUnit)

func getUnitsInSquad() -> Array:
	return _squad

# Returns whether unit was successfully removed
func removeUnitFromSquad(unit : Unit) -> bool:
	if _squad.has(unit):
		_squad.erase(unit)
		return true
	else:
		return false

func removeListFromSquad(units : Array) -> bool:
	var rhet := true
	
	for unit in units:
		var res := self.removeUnitFromSquad(unit)
		rhet = (rhet and res)
	
	return rhet

func resetSquad():
	_squad = []
