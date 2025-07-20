class_name CarMeshController
extends Node3D

@export var turning_wheels: Array[Node3D]
@export var body: Node3D
@export var body_tilt: float = 35
@export var body_tilt_lerp: float = 10
@export var max_body_tilt: float = 10

func set_wheels_rotation(new_rotation: float) -> void:
	for wheel in turning_wheels:
		wheel.rotation.y = new_rotation

func set_body_tilt(velocity: float, delta: float) -> void:
	var tilt: float = velocity / body_tilt
	body.rotation.z = lerp(body.rotation.z, tilt, body_tilt_lerp * delta)
	body.rotation_degrees.z = clamp(body.rotation_degrees.z, -max_body_tilt ,max_body_tilt)
