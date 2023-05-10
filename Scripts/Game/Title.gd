extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
    Console.writeline("Title screen ready.")

func _on_Play_button_button_up():
    get_tree().change_scene_to_file("res://Scenes/Levels/Level1.tscn")
