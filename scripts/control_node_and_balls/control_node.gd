class_name ControlNode
extends Ball

@onready var asset: ControlNodeAsset = $ModelContainer/ControlNodeAsset


func _ready() -> void:
	asset.power_up_shield()


func _on_inert_node_body_entered(body: Node) -> void:
	asset.bounce(inert_node.linear_velocity.length() / 5.0)
