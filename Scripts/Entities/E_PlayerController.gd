extends CharacterBody2D

# TODO: Refactor this, make a proper entity system.
# This is just the player character with no multipurpose use.
# On hold until I decide what entities (vehicles, pickups, items, mobs, bosses) I want.

var fuel = 100
var hp_current = 100

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const SLOW_AIR = 0.875 # Higher is faster
const SLOW_FLOOR = 0.8

const JET_PUSH = 25
const BUTTON_PUSH = 50
const JUMP_PUSH = 250

const FALL_HIT = 1000
const TOO_FAST = 11200 # Escape Velocity

signal jump
signal jet_pressed
signal left_pressed
signal right_pressed
signal dash

signal hp_delta(hp)
signal fuel_change(fuel)

signal player_dead
signal update

@onready var animation_sprite = $AnimatedSprite2D # To change animation in child node

var force = Vector2(0,0)
var old_velocity = velocity

func change_hp(hp):
    hp_current += hp
    hp_delta.emit(hp)

func change_fuel(tank):
        fuel +=tank
        fuel_change.emit(tank)

func get_hp():
    return hp_current

func get_fuel():
    return fuel

func regen(): # Kicks in every n seconds to replenish resources.
    if fuel < 100:
        change_fuel(1)
    if hp_current < 100:
        change_hp(0.5)

func hard_fall(): # Fall damage calculation
    if old_velocity.y - velocity.y > FALL_HIT:
        Console.writeline(str(" Ouch. Fell a bit too fast."))
        change_hp(-50)
        $SoundHurt.play()
        $Camera.shake(0.25,25,2)
    if velocity.y > TOO_FAST:
        Console.writeline(str(" Escaped the world. Bye..."))
        $SoundHurt.play()
        player_dead.emit()
        hp_current = 420 # Doing this fixes a mysterious bug
    if hp_current <= 0:
        Console.writeline(str(" Only ", hp_current, " HP. Bruh."))
        $SoundHurt.play()
        $Camera.shake(0.25,25,5)
        player_dead.emit()
        hp_current = 420

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

func movement():
    force.x=0 # Nothing  by default on the x axis
    force.y = gravity # Constant force of gravity
    if not is_on_floor(): # Will take more time to slow down in air
        velocity.x *= SLOW_AIR
    else:
        velocity.x *= SLOW_FLOOR
    # Apply forces to our variable which will be set to 0 at the end
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
    old_velocity = velocity
    velocity += force
    set_animation(force.x, velocity.y)
    #Console.writeline(str("Applied Force: ",force," Applied Vel: ",velocity))
    #force.x=0
    #force.y=0 # Unneccesary, the first line could be force.y=gravity, hence removing the need for this line.
    move_and_slide()

func _physics_process(_delta):
    movement()
    hard_fall()
    update.emit()

func _on_timer_timeout():
    regen()
    update.emit()
