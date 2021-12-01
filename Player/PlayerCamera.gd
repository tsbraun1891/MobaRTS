extends Spatial


onready var cameraTween := $cameraTween
onready var PlayerCamera := $"."
onready var cameraNode := $CameraNode
onready var camera := $CameraNode/Camera

var cameraSpeed = 10
var positionRatio = Vector3()
var cameraMovement = Vector3()
var cameraHeight = Vector3()
var heightMovement = 0

const ACCEL = 2
const DECEL = 4
const MAXSPEED = 5

onready var screenSize = get_viewport().size

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	cameraHeight = cameraNode.get_translation()
	
func _input(event):
	if event is InputEventMouseMotion:
		positionRatio = (screenSize-event.position)/screenSize
	elif event is InputEventMouseButton:
		if event.is_pressed():
			# TODO: Advanced zoom to zoom in on mouse pointer, not just center of the screen
			# Probably will be a ratio based on the mouse position
			if event.button_index == BUTTON_WHEEL_UP:
				cameraNode.translation.y = cameraNode.translation.y-1
				cameraNode.translation.z = cameraNode.translation.z-1
			if event.button_index == BUTTON_WHEEL_DOWN:
				cameraNode.translation.y = cameraNode.translation.y+1
				cameraNode.translation.z = cameraNode.translation.z+1
	
	#if Input.is_action_just_pressed("ui_cancel"):
	#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	moveCamera(delta)
	
func moveCamera(delta):
	var cameraPosition = PlayerCamera.get_translation()
	#Determine Mouse Position to see if close to edge
	if positionRatio.x > .95:
		cameraMovement.x = -MAXSPEED
	elif positionRatio.x < .05:
		cameraMovement.x = MAXSPEED
	else:
		cameraMovement.x = 0
				
	if positionRatio.y > .95:
		cameraMovement.z = -MAXSPEED
	elif positionRatio.y < .05:
		cameraMovement.z = MAXSPEED
	else:
		cameraMovement.z = 0
	
	var newPosition = cameraPosition+cameraMovement

	cameraTween.interpolate_property(PlayerCamera,"translation",cameraPosition,newPosition,cameraSpeed*delta,Tween.TRANS_SINE,Tween.EASE_OUT)
	cameraTween.start()
