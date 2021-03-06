extends Test


const OPTION_BODY_TYPE = "Body Type/%s (%d)"

const OPTION_GRAVITY = "Physics options/Gravity on floor (Kinematic only)"
const OPTION_SLOPE = "Physics options/Stop on slope (Kinematic only)"
const OPTION_SNAP = "Physics options/Use snap (Kinematic only)"
const OPTION_FRICTION = "Physics options/Friction (Rigid only)"
const OPTION_ROUGH = "Physics options/Rough (Rigid only)"
const OPTION_PROCESS_PHYSICS = "Physics options/AnimationPlayer physics process mode"

var _gravity = false
var _slope = false
var _snap = false
var _friction = false
var _rough = false
var _animation_physics = false

var _body_scene = {}
var _key_list = []
var _current_body_index = 0
var _current_body_key = ""
var _current_body = null
var _body_type = ["KinematicBody", "RigidBody"]


func _ready():
	var options = $Options
	var bodies = $Bodies.get_children()
	for i in bodies.size():
		var body = bodies[i]
		var option_name = OPTION_BODY_TYPE % [body.name, i + 1]
		options.add_menu_item(option_name)
		_key_list.append(option_name)
		_body_scene[option_name] = get_packed_scene(body)
		body.queue_free()

	options.add_menu_item(OPTION_GRAVITY, true, false)
	options.add_menu_item(OPTION_SLOPE, true, false)
	options.add_menu_item(OPTION_SNAP, true, false)
	options.add_menu_item(OPTION_FRICTION, true, false)
	options.add_menu_item(OPTION_ROUGH, true, false)
	options.add_menu_item(OPTION_PROCESS_PHYSICS, true, false)

	options.connect("option_selected", self, "_on_option_selected")
	options.connect("option_changed", self, "_on_option_changed")

	spawn_body_index(_current_body_index)


func _input(event):
	var key_event = event as InputEventKey
	if key_event and not key_event.pressed:
		var _index = key_event.scancode - KEY_1
		if _index >= 0 and _index < _key_list.size():
			spawn_body_index(_index)


func _on_option_selected(option):
	if _body_scene.has(option):
		spawn_body_key(option)


func _on_option_changed(option, checked):
	match option:
		OPTION_GRAVITY:
			_gravity = checked
			spawn_body_index(_current_body_index)
		OPTION_SLOPE:
			_slope = checked
			spawn_body_index(_current_body_index)
		OPTION_SNAP:
			_snap = checked
			spawn_body_index(_current_body_index)
		OPTION_FRICTION:
			_friction = checked
			spawn_body_index(_current_body_index)
		OPTION_ROUGH:
			_rough = checked
			spawn_body_index(_current_body_index)
		OPTION_PROCESS_PHYSICS:
			_animation_physics = checked
			spawn_body_index(_current_body_index)


func spawn_body_index(body_index):
	if _current_body:
		_current_body.queue_free()
	_current_body_index = body_index
	_current_body_key = _key_list[body_index]
	var body_parent = $Bodies
	var body = _body_scene[_key_list[body_index]].instance()
	body_parent.add_child(body)
	_current_body = body
	init_body()


func spawn_body_key(body_key):
	if _current_body:
		_current_body.queue_free()
	_current_body_key = body_key
	_current_body_index = _key_list.find(body_key)
	var body_parent = $Bodies
	var body = _body_scene[body_key].instance()
	body_parent.add_child(body)
	_current_body = body
	init_body()


func init_body():
	if _current_body is KinematicBody:
		_current_body._gravity_on_floor = _gravity
		_current_body._stop_on_slopes = _slope
		_current_body._use_snap = _snap
	elif _current_body is RigidBody:
		_current_body.physics_material_override.rough = _rough
		_current_body.physics_material_override.friction = 1.0 if _friction else 0.0

	var animation_player = $Platforms/KinematicPlatform/AnimationPlayer
	animation_player.stop()
	if _animation_physics:
		animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	else:
		animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_IDLE
	animation_player.play("Move")

	$LabelBodyType.text = "Body Type: " + _body_type[_current_body_index]


func get_packed_scene(node):
	node.owner = self
	for child in node.get_children():
		child.owner = node
	var packed_scene = PackedScene.new()
	packed_scene.pack(node)
	return packed_scene
