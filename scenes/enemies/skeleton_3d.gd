extends Skeleton3D

func collapse() -> void:
	$PhysicalBoneSimulator3D.active = true
	physical_bones_stop_simulation()
