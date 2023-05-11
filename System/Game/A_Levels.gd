extends Node2D
class_name Level

# Button pauses go though this script. Bruh.
@onready var HitpointsBar = $InfoLayer/game_ui/HitpointsBar
@onready var FuelBar = $InfoLayer/game_ui/FuelBar
@onready var PauseMenuInvoker = $InfoLayer/game_ui/PauseMenuButton
@onready var PauseScreen = $InfoLayer/game_ui/Panel
@onready var PauseText = $InfoLayer/game_ui/Panel/PauseOrDead
@onready var PauseContinue = $InfoLayer/game_ui/Panel/Buttons/Continue
@onready var PauseRetry = $InfoLayer/game_ui/Panel/Buttons/Retry
@onready var PlayerBody = $Player
@onready var PlayerHealth = $Player/C_HP
@onready var DebugMsg = $/root/Console/DebugLayer/DebugDisplay
@onready var MissionFailedTimer = $MissionFailed

func _connections():
    PlayerHealth.hp_delta.connect(_on_Player_hp_delta)
    PlayerBody.fuel_change.connect(_on_Player_fuel_change)
    PlayerHealth.entity_death.connect(_on_Player_death)
    PlayerBody.update.connect(_on_Player_update)
    PauseMenuInvoker.toggled.connect(_on_Pause_menu_toggle)
    PauseContinue.pressed.connect(_on_Continue_button_press)

func _ready():
    GameTotal.please_pause(0, false) # This quick fix to fix the fact that
    GameTotal.please_pause(1, false) # Toggle buttons seem to be getting stuck, setting pause to true in an unwanted fashion.
    _connections()
    Console.writeline("Level loaded.")

func _on_Continue_button_press():
    GameTotal.please_pause(1, false)
    PauseScreen.hide()
    PauseMenuInvoker.set_pressed(false)

func _on_Player_hp_delta(hp):
    HitpointsBar.value += hp

func _on_Player_fuel_change(change):
    FuelBar.value += change

func _on_Player_death():
    Console.writeline("Player died.") # This basically freezes the player while the world goes on for a second.
    PlayerBody.set_physics_process(false)
    # Fade effect for death. Technically 'before' death
    var tween = get_tree().create_tween()
    tween.tween_property(PlayerBody, "modulate", Color.RED, 1)
    tween.tween_property(PlayerBody, "scale", Vector2(), 0.1)
    MissionFailedTimer.start()
    await(MissionFailedTimer.timeout)
    tween.tween_callback(PlayerBody.queue_free) # Do this only after pausing the level.
    GameTotal.please_pause(0, true)
    # Make our pause screen more like a death screen
    PauseText.text = "You died bruh"
    PauseContinue.hide()
    PauseMenuInvoker.set_pressed(true)
    PauseScreen.show()

func _on_Pause_menu_toggle(button):
    GameTotal.please_pause(1, button)
    PauseScreen.visible = button
    
func _notification(what):
    if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
        GameTotal.please_pause(1, true)
        PauseMenuInvoker.set_pressed(true)
        PauseScreen.visible = true

func _on_Player_update():
    DebugMsg.text = str("Player Info: \n Real Velocity: ", PlayerBody.get_real_velocity(), "\n Fuel: ", PlayerBody.get_fuel(),"\n HP: ", PlayerHealth.get_hp())
