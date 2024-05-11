extends MeshInstance3D

func _on_area_3d_body_entered(body):
	if (body.has_method("changeWaterHeight")):
		body.changeWaterHeight(self);
