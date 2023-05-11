extends MovableEntity

# TODO: Refactor this, make a proper entity system.
# This is just the player character with no multipurpose use.
# On hold until I decide what entities (vehicles, pickups, items, mobs, bosses) I want.

@export var fuel_spawn = 100
var fuel = fuel_spawn

#@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

#@export var SLOW_AIR = 0.875 # Higher is faster
#@export var SLOW_FLOOR = 0.8

@export var fall_hp_value = -50
#@export var fall_hit_threshold = 1000
#@export var overspeed = 11200 # Escape Velocity

@export var JET_PUSH = 25
@export var BUTTON_PUSH = 50
@export var JUMP_PUSH = 250

#@export var fall_hit_threshold = 1000
#const TOO_FAST = 11200 # Escape Velocity

signal jump
signal jet_pressed
signal left_pressed
signal right_pressed
signal dash

#signal hp_delta(hp)
signal fuel_change(fuel)

#signal player_dead
#signal update

@onready var animation_sprite = $AnimatedSprite2D # To change animation in child node


#var old_velocity = velocity

#func change_hp(hp):
#    hp_current += hp
#    hp_delta.emit(hp)

func change_fuel(tank):
        fuel +=tank
        fuel_change.emit(tank)

#func get_hp():
#    return hp_current

func get_fuel():
    return fuel

func regen(): # Kicks in every n seconds to replenish resources.
    if fuel < 100:
        change_fuel(1)
    #if hp_current < 100:
    #    change_hp(0.5)

func _check_hard_fall(): # Fall damage calculation
    if old_velocity.y - velocity.y > fall_hit_threshold:
        Console.writeline(str(" Ouch. Fell a bit too fast."))
        $C_HP.change_hp(-50)
        $SoundHurt.play()
        $Camera.shake(0.25,25,2)
    if velocity.y > overspeed:
        Console.writeline(str(" Escaped the world. Bye..."))
        $SoundHurt.play()
        $C_HP.entity_death.emit()
        #hp_current = 420 # Doing this fixes a mysterious bug
    #if $C_HP.get_hp() <= 0:
        #hp_current = 420

func set_animation(x, y):
    if x<0:
        animation_sprite.flip_h = true
        animation_sprite.play("Run")
    elif x>0:
        animation_sprite.flip_h = false
        animation_sprite.play("Run")
    else:
        animation_sprite.play("Idle")
    if y < 0:
        animation_sprite.play("Jump")
    elif y > 100 and not is_on_floor():
        animation_sprite.play("Fall")



func _get_player_input():
    var force = Vector2(0, gravity)
    if Input.is_action_pressed("game_go_right"):
        force.x += BUTTON_PUSH
        right_pressed.emit()
    if Input.is_action_pressed("game_go_left"):
        force.x -= BUTTON_PUSH
        left_pressed.emit()
    if Input.is_action_pressed("game_jet") and fuel > 0:
        force.y -= JET_PUSH
        fuel -=0.5
        fuel_change.emit(-0.5)
        jet_pressed.emit()
    if Input.is_action_pressed("game_slide"):
        force.y += JET_PUSH
        dash.emit()
    if Input.is_action_pressed("game_jump") and is_on_floor():
        force.y -= JUMP_PUSH
        jump.emit()   
    set_animation(force.x, velocity.y) 
    return force



func _physics_process(_delta):
    entity_movement(_get_player_input())
    _check_hard_fall()
    update.emit()

func _on_regen_timer_timeout():
    $C_HP.regen()
    regen()
    update.emit()

func _on_c_hp_entity_death():
    Console.writeline(str("This ",$C_HP.get_last_hit(), " HP hit made you go to " , $C_HP.get_hp(), " HP. Bruh."))
    $RegenTimer.paused = true

func _on_c_hp_hp_delta(hp):
    if hp>0:
        return
    $SoundHurt.play()
    $Camera.shake(0.25,25,5)
