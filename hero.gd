extends KinematicBody2D

signal hit
signal dead

export (int) var speed
export (int) var health
export (float) var cooldown

var velocity = Vector2()
var multiplier = 1.0
var can_shoot = true
var alive = true

func _ready():
	$Cooldown.wait_time = cooldown
	
func control(delta):
	velocity = Vector2()
	multiplier = 1.0
	if Input.is_action_pressed('sprint'):
        multiplier = 2.0
	if Input.is_action_pressed('ui_right'):
        velocity.x += 1
	if Input.is_action_pressed('ui_left'):
        velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
        velocity.y += 1
	if Input.is_action_pressed('ui_up'):
        velocity.y -= 1
	velocity = velocity.normalized() * speed * multiplier

func _physics_process(delta):
	if not alive:
		return
	control(delta)
	move_and_slide(velocity)
