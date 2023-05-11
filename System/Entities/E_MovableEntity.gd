extends CharacterBody2D
class_name MovableEntity

@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var SLOW_AIR = 0.875 # Higher is faster
@export var SLOW_FLOOR = 0.8

#@export var fall_hp_value = -50
@export var fall_hit_threshold = 1000
@export var overspeed = 11200 # Escape Velocity

signal update
#signal big_hit # Falling
#signal too_fast # Over speeding


#@onready var animation_sprite = $AnimatedSprite2D # To change animation in child node

var old_velocity = velocity

#func _check_hard_fall(): # Fall damage calculation
#    if old_velocity.y - velocity.y > fall_hit_threshold:
#        big_hit.emit()
#        #Console.writeline(str(" Ouch. Fell a bit too fast."))
#        #$C_HP.change_hp(-50)
#        #$SoundHurt.play()
#        #$Camera.shake(0.25,25,2)
#    if velocity.y > overspeed:
#        too_fast.emit()
#        #Console.writeline(str(" Escaped the world. Bye..."))
#        #$SoundHurt.play()
#        #$C_HP.entity_death.emit()

#func set_animation(x, y):
#    if x<0:
#        animation_sprite.flip_h = true
#        animation_sprite.play("Run")
#    elif x>0:
#        animation_sprite.flip_h = false
#        animation_sprite.play("Run")
#    else:
#        animation_sprite.play("Idle")
#    if y < 0:
#        animation_sprite.play("Jump")
#    elif y > 100 and not is_on_floor():
#        animation_sprite.play("Fall")

func entity_movement(input_vector):
    if not is_on_floor(): # Will take more time to slow down in air
        velocity.x *= SLOW_AIR
    else:
        velocity.x *= SLOW_FLOOR
    old_velocity = velocity
    velocity += input_vector
    #set_animation(input_vector.x, velocity.y)
    #Console.writeline(str("Applied Force: ",force," Applied Vel: ",velocity))
    #force.x=0
    #force.y=0 # Unneccesary, the first line could be force.y=gravity, hence removing the need for this line.
    move_and_slide()

#func _physics_process(_delta):
    #apply_movement()
    #_check_hard_fall()
    #update.emit()
