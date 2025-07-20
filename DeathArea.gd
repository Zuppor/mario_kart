class_name DeathArea
extends Area3D

@export var track_direction: TrackDirection
@export var offset_penalty: float = 5
@export var y_respawn_offset: float = 5

func _ready() -> void:
	body_entered.connect(on_body_entered)
	
func on_body_entered(body: Node3D):
	if not body.is_in_group("kart"):
		return
	
	var kart: RigidBody3D = body as RigidBody3D
	var offset = track_direction.get_closest_offset(kart.global_position)
	
	offset -= offset_penalty
	var respawn_point = track_direction.get_closest_point(offset)
	respawn_point += Vector3.UP * y_respawn_offset
	
	kart.global_position = respawn_point
	kart.linear_velocity = Vector3.ZERO
	kart.angular_velocity = Vector3.ZERO


func align_forward(xform: Transform3D, normal: Vector3) -> Transform3D:
	xform.basis.z = normal
	xform.basis.x = -xform.basis.y.cross(normal)
	xform.basis = xform.basis.orthonormalized()
	return xform
