class_name ImpactDetector
extends Node

@export var rigidbody: RigidBody3D
@export var threshold: float = 5
var previous_velocity: float = 0

signal on_impact

func _process(_delta: float) -> void:
	
	var curr_velocity: float = rigidbody.linear_velocity.length()
	var velocity_diff: float = previous_velocity - curr_velocity
	
	if velocity_diff > threshold:
		on_impact.emit()
	
	previous_velocity = curr_velocity
