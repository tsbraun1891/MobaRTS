extends Spatial

# The Commandable class functions as an interface
# All actors who can be commanded by commanders will have this interface
class_name Commandable

var unit : Unit
var team : int

func _ready():
	$SelectionRing.hide()
	unit = get_parent() as Actor
	team = unit.team

func select():
	$SelectionRing.show()
 
func deselect():
	$SelectionRing.hide()

func attackMove(targetPos):
	unit.attackMove(targetPos)

func moveCommand(targetPos):
	unit.moveCommand(targetPos)
