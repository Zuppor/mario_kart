class_name KartController
extends Node3D

@export_category("Nodes")
@export var rigidbody: RigidBody3D
@export var ground_ray: RayCast3D
@export var car_mesh_controller: CarMeshController

@export_category("Parameters")
@export var acceleration: float = 50
@export var steering: float = 21
@export var turn_speed: float = 5
@export var turn_stop_limit: float = .75
@export var mesh_offset: Vector3

@export_group("Sounds")
@export var audio_player: AudioStreamPlayer3D

var wish_direction: Vector3 = Vector3.FORWARD
var input_speed: float
var input_steering: float

var drifting: bool:
	get:
		return drifting
	set(value):
		if value and not drifting:
			on_drift_start.emit()
		elif (not value and drifting):
			on_drift_end.emit()
		drifting = value

signal on_drift_start()
signal on_drift_end()

func _ready():
	ground_ray.add_exception(rigidbody)
	
func _physics_process(_delta: float) -> void:
	rigidbody.apply_force(car_mesh_controller.global_transform.basis.z * input_speed)
	
func _process(delta: float) -> void:
	input_speed = get_input_speed()
	
	if not on_floor():
		input_speed = 0
	
	input_steering = get_input_steering()
	
	handle_car_mesh_controller(delta)
	
	var kart_alignment_with_velocity: float = rigidbody.linear_velocity.normalized().dot(car_mesh_controller.global_transform.basis.z)
	self.drifting = rigidbody.linear_velocity.length() > 5.5 and kart_alignment_with_velocity < 0.9 and on_floor()
		
	
	
func get_input_speed() -> float:
	var result: float = 0
	
	var acceleration_strength: float = Input.get_action_strength("accelerate")
	
	var effect := AudioServer.get_bus_effect(1, 0) as AudioEffectPitchShift
	if acceleration_strength > 0:
		effect.pitch_scale += .001
	else:
		effect.pitch_scale -= .001
	effect.pitch_scale = clampf(effect.pitch_scale, 1, 1.7)
	
	result += acceleration_strength
	result -= Input.get_action_strength("brake")
	result *= acceleration
	return result

func get_input_steering() -> float:
	var result: float = 0
	result += Input.get_action_strength("steer_left")
	result -= Input.get_action_strength("steer_right")
	result *= deg_to_rad(steering)
	return result

func on_floor() -> bool:
	return ground_ray.is_colliding()
	
func handle_car_mesh_controller(delta: float) -> void:
	car_mesh_controller.global_position = rigidbody.global_position + mesh_offset
	
	car_mesh_controller.set_wheels_rotation(input_steering)
	
	if rigidbody.linear_velocity.length() > turn_stop_limit:
		var new_basis: Basis = car_mesh_controller.global_transform.basis.rotated(car_mesh_controller.global_transform.basis.y, input_steering)
		car_mesh_controller.global_transform.basis = car_mesh_controller.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh_controller.global_transform = car_mesh_controller.global_transform.orthonormalized()
		
		car_mesh_controller.set_body_tilt(input_steering * rigidbody.linear_velocity.length(), delta)
	
	if on_floor():
		var floor_normal: Vector3 = ground_ray.get_collision_normal()
		var xform: Transform3D = align_up(car_mesh_controller.global_transform, floor_normal.normalized())
		car_mesh_controller.global_transform = car_mesh_controller.global_transform.interpolate_with(xform, delta * 10)

func align_up(xform: Transform3D, normal: Vector3) -> Transform3D:
	xform.basis.y = normal
	xform.basis.x = -xform.basis.z.cross(normal)
	xform.basis = xform.basis.orthonormalized()
	return xform
