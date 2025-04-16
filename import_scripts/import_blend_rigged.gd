@tool
extends EditorScenePostImport

func get_all_bone_names(skeleton: Skeleton3D, idx: int) -> Array[String]:
	var bone_names: Array[String]
	
	for child_idx in skeleton.get_bone_children(0):
		print("--- --- ", child_idx)
	
	return bone_names

func _post_import(scene: Node) -> Node:
	print("Scene Name: ", scene.name)
	
	var skeleton: Skeleton3D = scene.get_node("Armature").get_node("Skeleton3D")
	
	print("--- ", skeleton.name)
	print("--- number of bones: ", skeleton.get_bone_count())
	
	for child_idx in skeleton.get_bone_children(0):
		print("--- --- ", child_idx)
	
	return scene
