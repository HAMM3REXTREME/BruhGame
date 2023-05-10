extends Node

@onready var DebugBtn = $/root/Console/DebugLayer/PauseButton
@onready var DebugMsg = $/root/Console/DebugLayer/DebugDisplay
#@onready var ConsoleIn = $/root/Console/DebugLayer/ConsoleOutlinePanel/ConsoleIOPanel/ConsoleIn

signal game_paused(paused)

# The game will pause even if one of them is true.
var pauseInvokers = [false, false, false] # Game, User, Debug


func _connections():
    DebugBtn.toggled.connect(_on_Debug_pause_toggle)

# Called when the node enters the scene tree for the first time.
func _ready():
    _connections()
    Console.writeline("Ready")


func _on_Debug_pause_toggle(button):
    GameTotal.please_pause(2, button)


# Makes the whole thing paused even if one button is active, hopefully
func please_pause(pauseSlot, pause):
    pauseInvokers[pauseSlot] = pause
    if true in pauseInvokers:
        get_tree().paused = true
        game_paused.emit(true)
        return
    game_paused.emit(false)
    get_tree().paused = false
    

