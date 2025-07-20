extends Camera3D

@export var lerp_speed: float = 3

@export var target: Node3D
@export var offset_from_target: Vector3 = Vector3.ZERO
@export var look_offset: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if !target:
		return
		
	var target_pos: Transform3D = target.global_transform.translated_local(offset_from_target)
	global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
	
	look_at(target.global_position + look_offset, Vector3.UP)
