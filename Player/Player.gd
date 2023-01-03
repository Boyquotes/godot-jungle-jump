extends KinematicBody2D
export (int) var run_speed
export (int) var jump_speed
export (int) var gravity
enum {IDLE, RUN, JUMP, HURT, DEAD}
var state
var anim
var new_anim
var velocity = Vector2()
var life
signal life_changed
signal dead


func hurt():
	if state != HURT:
		change_state(HURT)


func start(pos):
	life = 3
	emit_signal("life_changed", life)
	position = pos
	show()
	change_state(IDLE)
	

func get_input():
	if state == HURT:
		return # don't allow movement while hurt
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	
	# movement occurs in all states
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite.flip_h = true
	# only allow jumping when is on the ground
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
	# IDLE transitions to RUN when moving
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	# RUN transitions to IDLE when standing still
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	# transition to JUMP when falling off an edge
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)


# Called when the node enters the scene tree for the first time.
func _ready():
	change_state(IDLE)


func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			new_anim = 'idle'
		RUN:
			new_anim = 'run'
		HURT:
			new_anim = 'hurt'
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			emit_signal("life_changed", life)
			yield(get_tree().create_timer(0.5), "timeout")
			change_state(IDLE)
			if life <= 0:
				change_state(DEAD)
		JUMP:
			new_anim = 'jump_up'
		DEAD:
			emit_signal("dead")
			hide()


func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	if new_anim != anim:
		anim = new_anim
		$AnimationPlayer.play(anim)
	# move the player
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	if state == JUMP and velocity.y > 0:
		new_anim = 'jump_down'
