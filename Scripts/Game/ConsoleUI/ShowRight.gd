extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
    hide()

func _input(_InputEvent):
    if Input.is_action_pressed("game_go_right"):
        show()
    else:
        hide()
