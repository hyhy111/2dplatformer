extends Control

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/options_meun.tscn")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/meun.tscn")

func _on_settings_pressed() -> void:
	pass # Replace with function body.
