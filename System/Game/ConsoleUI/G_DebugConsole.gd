extends Control

# Unrelated: TouchScreenButton(s) get their brightness,contrast changed by -50,-20 when pressed.
# NES Palette + Blur on sprites.

@onready var ConsoleOut = $DebugLayer/ConsoleOutlinePanel/ConsoleIOPanel/ScrollContainer/ConsoleOut
@onready var ConsoleIn = $DebugLayer/ConsoleOutlinePanel/ConsoleIOPanel/ConsoleIn
@onready var Scroll = $DebugLayer/ConsoleOutlinePanel/ConsoleIOPanel/ScrollContainer

func _ready():
    $DebugLayer.hide() # Can just hide in editor instead

# Writes a string + "\n" to our Label.
func writeline(string):
    ConsoleOut.text = ConsoleOut.text.right(1000) # Only keep the last 1000 chars before writing our next line.
    ConsoleOut.text += (string + "\n")
    #print(ConsoleOut.text)
    
func _on_console_in_text_submitted(new_text):
    writeline(new_text)
    ConsoleIn.text = ""
    # TODO: Some console command code here

# Makes the Debug Canvas Layer Visible when "game_console is pressed"
func _process(_delta):
    if Input.is_action_just_pressed("game_console"):
        $DebugLayer.visible = not $DebugLayer.visible
