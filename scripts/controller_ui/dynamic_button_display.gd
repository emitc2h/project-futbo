extends TextureRect

@export_group("Preloaded Textures")
@export var xbox_texture: CompressedTexture2D
@export var switch_texture: CompressedTexture2D
@export var steam_deck_texture: CompressedTexture2D
@export var keyboard_texture: CompressedTexture2D
@export var playstation_texture: CompressedTexture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var joypads := Input.get_connected_joypads()
	if joypads.is_empty():
		self.texture = keyboard_texture
	else:
		var device_id: int = joypads[0]
		var device_name: String = Input.get_joy_name(device_id)
		print(device_name)
	
