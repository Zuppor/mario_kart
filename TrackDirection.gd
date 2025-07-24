class_name TrackDirection
extends Path3D

@export var car: KartController
@export var alignement_error_threshold: float = -.5

func _process(_delta: float) -> void:
	
	var alignment: float = get_direction_alignment(car)
	
	if alignment < alignement_error_threshold:
		print("WRONG WAY!")

func get_direction_alignment(kart: KartController) -> float:
	var offset_on_curve: float = curve.get_closest_offset(kart.rigidbody.global_position)
	
	var pos_xform: Transform3D = curve.sample_baked_with_rotation(offset_on_curve)
	var alignment: float = -kart.car_mesh_controller.global_transform.basis.z.dot(pos_xform.basis.z)
	
	return alignment 

func get_closest_offset(point: Vector3) -> float:
	return curve.get_closest_offset(point)

func get_closest_point(offset: float) -> Vector3:
	return curve.sample_baked(offset)
