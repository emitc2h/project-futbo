@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Node:
	print("Scene Name: ", scene.name)
	
	# Create and save scene
	var packed_scene: PackedScene = PackedScene.new()
	packed_scene.pack(scene)
	var save_path: String = "res://scenes/imported/" + scene.name + ".tscn"
	print("Saving scene... " + save_path)
	ResourceSaver.save(packed_scene, save_path)
	
	return scene
