@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Node:
	print("Scene Name: ", scene.name)
	
	var terrainNode: Node3D = scene.get_node("terrain")
	var staticBody3D: StaticBody3D = terrainNode.get_node("StaticBody3D")
	
	#Remove the terrain collider body from the terrain node
	staticBody3D.set_owner(null)
	terrainNode.remove_child(staticBody3D)
	
	#Put the staticBody3D directly in the scene
	scene.add_child(staticBody3D)
	staticBody3D.set_owner(scene)
	
	#Set the proper collision mask/layer for terrain
	staticBody3D.set_collision_layer_value(1, false)
	staticBody3D.set_collision_layer_value(2, true)
	
	staticBody3D.set_collision_mask_value(1, true)
	staticBody3D.set_collision_mask_value(3, true)
	
	#Delete the terrain node
	scene.remove_child(terrainNode)
	terrainNode.queue_free()
	
	# Create and save scene
	var packed_scene: PackedScene = PackedScene.new()
	packed_scene.pack(scene)
	var save_path: String = "res://scenes/imported/" + scene.name + ".tscn"
	print("Saving scene... " + save_path)
	ResourceSaver.save(packed_scene, save_path)
	
	return scene
