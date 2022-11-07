#
# 3D Audio Visualizer
# Copyright (C) 2022, Oğuzhan Eroğlu <rohanrhu2@gmail.com> (https://oguzhaneroglu.com)
#

extends CharacterBody3D

@onready var nCamera: Camera3D = $Camera

@export var walk_speed: float = 0.05
@export var sprint_factor: float = 2
@export var mouse_sensitivity: float = 0.25

@export var gravity = 9.8

var is_mouse_locked = false

@export var autospec_angle = 0
@export var autospec_duration = 5000
@export var autospec_distance = 20
@export var autospec_height = 12
var autospec_time = 0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var aud = Time.get_ticks_msec() - autospec_time
	if aud > autospec_duration:
		autospec_time = Time.get_ticks_msec()
	
	if not is_mouse_locked:
		autospec_angle = (aud * 2*PI) / autospec_duration
		
		var x = autospec_distance * cos(autospec_angle)
		var y = autospec_distance * sin(autospec_angle)
		nCamera.global_position = Vector3(x, autospec_height, y)
		
		var look_pos = get_tree().root.get_child(0).get_node("Speakers").global_position
		look_pos.y += 10
		
		nCamera.look_at(look_pos)
		
		return
	
	var input_left = Input.get_action_strength("walk_left")
	var input_right = Input.get_action_strength("walk_right")
	var input_forward = Input.get_action_strength("walk_up")
	var input_backward = Input.get_action_strength("walk_down")
	var input_up = int(Input.is_key_pressed(KEY_E))
	var input_down = int(Input.is_key_pressed(KEY_Q))
	var input_sprint = Input.is_action_pressed("sprint")

	var current_walk_speed = walk_speed
	
	if input_sprint:
		current_walk_speed = walk_speed * sprint_factor
	
	var rotation_angle = nCamera.rotation.y
	
	var z_velocity = input_up - input_down

	var velocity = Vector3(0, z_velocity, 0)

	var mv = (input_forward - input_backward)
	var mh = (input_left - input_right)

	var angle = 0

	if mv != 0:
		if mv > 0:
			if mh > 0:
				angle = (rotation_angle - PI) + PI/4
			elif mh < 0:
				angle = (rotation_angle + PI) - PI/4
			else:
				angle = rotation_angle - PI
		elif mv < 0:
			if mh > 0:
				angle = rotation_angle - PI/4
			elif mh < 0:
				angle = rotation_angle + PI/4
			else:
				angle = rotation_angle
	else:
		if mh > 0:
			angle = rotation_angle - PI/2
		else:
			angle = rotation_angle + PI/2

	var dx = sin(angle)
	var dy = cos(angle)

	if mv != 0 or mh != 0:
		velocity.x = dx
		velocity.z = dy

	velocity = velocity.normalized() * current_walk_speed
	move_and_collide(velocity)

func _process(delta):
	pass

func _input(event) -> void:
	if event is InputEventMouseMotion and is_mouse_locked:
		nCamera.rotation.x -= deg_to_rad(event.relative.y * mouse_sensitivity)
		nCamera.rotation.x = clamp(nCamera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		nCamera.rotate_y(-deg_to_rad(event.relative.x * mouse_sensitivity))
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE and not event.echo:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				is_mouse_locked = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				is_mouse_locked = true
