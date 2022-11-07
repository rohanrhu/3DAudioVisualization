#
# 3D Audio Visualizer
# Copyright (C) 2022, Oğuzhan Eroğlu <rohanrhu2@gmail.com> (https://oguzhaneroglu.com)
#

extends Node3D

enum Mode {
	POINTS,
	LINES
}

@export var mode: Mode = Mode.POINTS
@export var points_strength = 4.0
@export var lines_strength = 1.0
@export var steps = 16
@export var max_freq = 11050.0
@export var min_db = 60

@export var interpolation_delay = 200
var interpolation_time = 0
var interpolation_direction = false

var spectrum

var frequencies = PackedByteArray()
var heights = []

@onready var nSurface = $Box/Surface

func _ready():
	for i in steps:
		frequencies.append(0)

	for i in steps:
		heights.append(0)

	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	_update_shader_freqs()

func _update_shader_freqs():
	var image = Image.create_from_data(steps, 1, false, Image.FORMAT_L8, frequencies)
	var texture = ImageTexture.create_from_image(image)

	nSurface.get_surface_override_material(0).set_shader_parameter("mode", mode)
	nSurface.get_surface_override_material(0).set_shader_parameter("points_factor", points_strength)
	nSurface.get_surface_override_material(0).set_shader_parameter("lines_factor", lines_strength)
	nSurface.get_surface_override_material(0).set_shader_parameter("freqs", texture)
	nSurface.get_surface_override_material(0).set_shader_parameter("freqs_length", steps)

func _process(delta):
	if steps != len(heights):
		frequencies = []
		heights = []

		for i in steps:
			frequencies.append(0)

		for i in steps:
			heights.append(0)

	var time = Time.get_ticks_msec()
	var phz = 0
	var diff = time - interpolation_time
	var curr = float(diff) / interpolation_delay
	if curr > 1:
			curr = 1

	for i in range(1, steps+1):
		var hz = i * max_freq / steps
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(phz, hz).length()
		var energy = clamp((min_db + linear_to_db(magnitude)) / min_db, 0, 1)

		phz = hz

		if diff >= interpolation_delay:
			heights[i-1] = energy * 255

		var height = curr * heights[i-1]
		if interpolation_direction:
			height = (1 - curr) * heights[i-1]
		frequencies[i-1] = int(height)

	if diff >= interpolation_delay:
		interpolation_time = Time.get_ticks_msec()
		interpolation_direction = not interpolation_direction

	_update_shader_freqs()
