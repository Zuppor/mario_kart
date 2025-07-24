class_name TireSmoke
extends GPUParticles3D

@export var kart: KartController

func _ready() -> void:
	kart.on_drift_start.connect(on_drift_start)
	kart.on_drift_end.connect(on_drift_end)

func on_drift_start():
	emitting = true

func on_drift_end():
	emitting = false
