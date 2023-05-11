extends Node

@onready var ParentEntity = get_parent()
var last_hit

func _ready():
    if not ParentEntity is PhysicsBody2D:
        Console.writeline("Error: C_HP as child of non-PhysicsBody2D")
        return 1
        queue_free()


# Health manager for entities.
@export var hp_spawn = 100
@export var hp_max: int
@export var regen_chunk = 0.5
var hp_current = hp_spawn

#@export var fall_hp_value = -50
#@export var fall_hit_threshold = 1000
#@export var overspeed = 11200 # Escape Velocity

signal hp_delta(hp) # For ProgressBars
signal entity_death

# Setters and getters for hp.
func change_hp(hp):
    hp_current += hp
    last_hit = hp
    hp_delta.emit(hp)
    if hp_current <= 0:
        entity_death.emit()

func get_hp():
    return hp_current

func get_last_hit():
    return last_hit


func regen(): # Regenerate health when called. Usually called using a timer.
    if hp_current < hp_spawn:
        change_hp(regen_chunk)
        hp_delta.emit(regen_chunk)

#func _check_velocity_hits(): # Fall damage calculation
#    print(str(old_velocity - ParentEntity.velocity))
#    if old_velocity.y - ParentEntity.velocity.y > fall_hit_threshold:
#        Console.writeline(str(ParentEntity ," Ouch. Fell a bit too fast."))
#        change_hp(-50)
#        hp_delta.emit(-50)
#    if ParentEntity.velocity.y > overspeed:
#        Console.writeline(str(old_velocity, " and ", ParentEntity.velocity))
#        Console.writeline(str(" Escaped the world. Bye..."))
#        entity_death.emit()
#        hp_current = 420 # Doing this fixes a mysterious bug
#    if hp_current <= 0:
#        Console.writeline(str(" Only ", hp_current, " HP. Bruh."))
#        entity_death.emit()
#        hp_current = 420
