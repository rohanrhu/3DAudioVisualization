#
# 3D Audio Visualizer
# Copyright (C) 2022, Oğuzhan Eroğlu <rohanrhu2@gmail.com> (https://oguzhaneroglu.com)
#

extends Node3D

@export var strength = 4.0
@export var steps = 16
@export var max_freq = 11050.0
@export var min_db = 60

@export var interpolation_delay = 200
var interpolation_time = 0
var interpolation_direction = false
var interpolation = 1
var interpolation_target = 0

@export var max_distance = 40
@export var min_distance = 25

var spectrum

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	
	$CanvasLayer/MusicSlider.max_value = $AudioStreamPlayer.stream.get_length()
	
	$AudioStreamPlayer.play(0)
	$SliderTimer.start()

func _on_MusicSlider_value_changed(value):
	$AudioStreamPlayer.play(value)

func _on_SliderTimer_timeout():
	var offset = $AudioStreamPlayer.get_playback_position()
	$CanvasLayer/MusicSlider.value = offset

func _process(delta):
	_process_fog(delta)
	_process_autospec(delta)

func _process_fog(delta):
	var magnitude: float = spectrum.get_magnitude_for_frequency_range(7000, $Speakers.max_freq).length()
	var energy = clamp((min_db + linear_to_db(magnitude)) / min_db, 0, 1)
	
	var environment: Environment = $WorldEnvironment.environment
	environment.fog_sky_affect = clamp(energy, 0.2, 1)
	
	energy /= 100
	
	$Ground/MeshInstance3D.get_surface_override_material(0).set_shader_parameter("paleness", clamp(energy, 0, 1))

func _process_autospec(delta):
	var magnitude: float = spectrum.get_magnitude_for_frequency_range(9000, $Speakers.max_freq).length()
	var energy = clamp((min_db + linear_to_db(magnitude)) / min_db, 0, 1)
	
	var time = Time.get_ticks_msec()
	var diff = time - interpolation_time
	interpolation = float(diff) / interpolation_delay
	if interpolation > 1:
		interpolation = 1
	
	if diff >= interpolation_delay:
		interpolation_time = Time.get_ticks_msec()
		interpolation_direction = not interpolation_direction
		interpolation_target = energy * (max_distance - min_distance)
	var current
	if not interpolation_direction:
		current = interpolation_target * interpolation
	else:
		current = interpolation_target * (1 - interpolation)
	
	$Spectator.autospec_distance = min_distance + current
