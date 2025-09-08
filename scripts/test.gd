extends Node2D



func _on_in_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$circel.position = $"out door".position
