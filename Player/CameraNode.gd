extends Spatial

onready var selection_box = $SelectionBox
onready var camera := $Camera

var selected_units = []
var start_sel_pos := Vector2()
var team := 1

const ray_length = 1000

# TODO: USE _unhandled_input TO MAKE SURE THAT ONLY THINGS NOT HANDLED BY UI ARE ISSUED AS COMMANDS

func _process(delta):
	var m_pos = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("command"):
		move_selected_units(m_pos)
	elif Input.is_action_just_pressed("attack"):
		amove_selected_units(m_pos)
	if Input.is_action_just_pressed("select"):
		selection_box.start_sel_pos = m_pos
		start_sel_pos = m_pos
	if Input.is_action_pressed("select"):
		selection_box.m_pos = m_pos
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
	if Input.is_action_just_released("select"):
		select_units(m_pos)

func move_selected_units(m_pos):
	var result = raycast_from_mouse(m_pos, 1)
	if result:
		for unit in selected_units:
			unit.moveCommand(result.position)

func amove_selected_units(m_pos):
	var result = raycast_from_mouse(m_pos, 1)
	if result:
		for unit in selected_units:
			unit.attackMove(result.position)

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = camera.project_ray_origin(m_pos)
	var ray_end = ray_start + camera.project_ray_normal(m_pos) * ray_length
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask)
	
func select_units(m_pos):
	var new_selected_units = []
	if m_pos.distance_squared_to(start_sel_pos) < 16:
		var u = get_unit_under_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(start_sel_pos, m_pos)
	
	for unit in selected_units:
		unit.deselect()
	if new_selected_units.size() != 0:
		for unit in new_selected_units:
			unit.select()
		
	selected_units = new_selected_units

func get_unit_under_mouse(m_pos):
	var result = raycast_from_mouse(m_pos, 3)
	if result and "team" in result.collider and result.collider.team == team and result.collider.has_node("Commandable"):
		return result.collider.get_node("Commandable")
 
func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = []
	# Could add a selection point in the middle of the body (using Commandable) and check if that is in as well 
	# so you don't only have the base to select
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.team == team and box.has_point(camera.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units
