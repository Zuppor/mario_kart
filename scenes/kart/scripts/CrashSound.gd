extends AudioStreamPlayer3D

@export var impact_detector: ImpactDetector

func _ready() -> void:
	impact_detector.on_impact.connect(on_impact)
	
func on_impact():
	play()
