class_name EngineSound
extends AudioStreamPlayer3D

@export var pitch_curve: Curve
@export var pitch_lerp: float = 1

func _process(delta: float) -> void:
	var acceleration_strength: float = Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
	
	var effect := AudioServer.get_bus_effect(1, 0) as AudioEffectPitchShift
		
	var target_pitch: float = pitch_curve.sample_baked(acceleration_strength)
	
	effect.pitch_scale = lerpf(effect.pitch_scale, target_pitch, pitch_lerp * delta)
