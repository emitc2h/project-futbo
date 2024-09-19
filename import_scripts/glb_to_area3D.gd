@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Area3D:
	print(scene.name)
	
	print("Starting post-import processing.")
	# Ensure there is exactly one child (the main MeshInstance3D)
	if scene.get_child_count() != 1:
		push_error("Scene should have exactly one child.")
		return scene

	# Get the main MeshInstance3D
	var mesh_model: MeshInstance3D = scene.get_child(0) as MeshInstance3D

	# Check if the child is a MeshInstance3D
	# This is used for the MeshInstance3D on the imported model
	if not mesh_model is MeshInstance3D:
		push_error("Scene's first child should be MeshInstance3D.")
		return scene
	
	# Detach the main MeshInstance3D from the scene
	mesh_model.set_owner(null) # Seems like this shouldn't need to be here, but it does. Perhaps a bug.
	scene.remove_child(mesh_model) # without the line above, this makes a warning
	
	# Create a new Area3D and configure it
	# This will be the root node of the returned scene
	var area3D: Area3D = Area3D.new()
	area3D.name = scene.name
	
	var collisionShape3D: CollisionShape3D = CollisionShape3D.new()
	collisionShape3D.name = "CollisionShape3D"
	collisionShape3D.shape = mesh_model.mesh.create_convex_shape()

	area3D.add_child(collisionShape3D)
	collisionShape3D.set_owner(area3D)
	
	# Free the original scene root, as it's no longer needed
	scene.queue_free()
	
	print("Finished setting up Area3D and collision shapes.")
	
	# Create and save scene
	var packed_scene: PackedScene = PackedScene.new()
	packed_scene.pack(area3D)
	var save_path: String = "res://scenes/" + area3D.name + ".tscn"
	print("Saving scene... " + save_path)
	ResourceSaver.save(packed_scene, save_path)
	
	return area3D
