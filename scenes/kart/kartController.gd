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

var wish_direction: Vector3 = Vector3.FORWARD
var input_speed: float
var input_steering: float

func _ready():
	ground_ray.add_exception(rigidbody)
	
func _physics_process(_delta: float) -> void:
	rigidbody.apply_force(car_mesh_controller.global_transform.basis.z * input_speed)
	
func _process(delta: float) -> void:
	if on_floor():
		input_speed = get_input_speed()
	else:
		input_speed = 0
	
	input_steering = get_input_steering()
	
	handle_car_mesh_controller(delta)
	
	
	
func get_input_speed() -> float:
	var result: float = 0
	result += Input.get_action_strength("accelerate")
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
