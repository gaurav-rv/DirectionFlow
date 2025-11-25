extends Node2D
class_name Pipe2D

# Include utility enums
const PipeUtil = preload("res://scripts/pipe_util.gd")

# Pipe attributes as specified in ReadMe
@export var state: PipeUtil.PipeState = PipeUtil.PipeState.NOT_UTILIZED
@export var pipe_type: PipeUtil.PipeType = PipeUtil.PipeType.STRAIGHT
@export var x_pos: int = 0 # Relative to grid
@export var y_pos: int = 0 # Relative to grid
@export var orientation: float = 0.0 # 0, 90, 180, 270 degrees

# Animation and visual properties
@export var tile_size: Vector2 = Vector2(64, 64)
@export var rotation_duration: float = 0.3
@export var state_transition_duration: float = 0.2


# Internal components

# This will contain a list of openings based on pipe type and orientation
var openingList = []

var tween: Tween
var current_rotation_angle: float = 0.0
# Sprite2D reference for the pipe visual
@onready var sprite = $Sprite2D

# Signals for game logic
signal pipe_clicked(pipe: Pipe2D)
signal rotation_completed(pipe: Pipe2D)
signal state_changed(pipe: Pipe2D, new_state: PipeUtil.PipeState)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_pipe(PipeUtil.PipeType.STRAIGHT)
	setup_input_handling()

func setup_pipe(pipe_type: PipeUtil.PipeType) -> void:
	# Create sprite component if not already present
	if not sprite:
		sprite = Sprite2D.new()
		add_child(sprite)
	
	self.pipe_type = pipe_type
	if (pipe_type == PipeUtil.PipeType.STRAIGHT):
		openingList = [PipeUtil.Direction.NORTH, PipeUtil.Direction.SOUTH]
	elif (pipe_type == PipeUtil.PipeType.CURVED):
		openingList = [PipeUtil.Direction.NORTH, PipeUtil.Direction.EAST]
	elif (pipe_type == PipeUtil.PipeType.T_JUNCTION):
		openingList = [PipeUtil.Direction.NORTH, PipeUtil.Direction.EAST, PipeUtil.Direction.WEST]
	elif (pipe_type == PipeUtil.PipeType.CROSS):
		openingList = [PipeUtil.Direction.NORTH, PipeUtil.Direction.EAST, PipeUtil.Direction.SOUTH, PipeUtil.Direction.WEST]
	setImageBasedOnDirection()

	# Set initial position based on grid coordinates
	position = Vector2(x_pos * tile_size.x, y_pos * tile_size.y)
	
	# Set initial rotation
	rotation_degrees = orientation
	
	# Update visual representation based on state
	# update_visual_state()

func setup_input_handling() -> void:
	# Enable input processing for clicking
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			# Check if click is within this pipe's bounds
			var local_pos = to_local(mouse_event.global_position)
			if is_point_in_bounds(local_pos):
				on_pipe_clicked()

func is_point_in_bounds(local_pos: Vector2) -> bool:
	var half_size = tile_size / 2
	return abs(local_pos.x) <= half_size.x and abs(local_pos.y) <= half_size.y

func on_pipe_clicked() -> void:
	pipe_clicked.emit(self)
	rotate_pipe()

# Rotate the pipe by 90 degrees clockwise
func rotate_pipe() -> void:
	print("Rotating pipe at position (%d, %d)" % [x_pos, y_pos])
	if (current_rotation_angle == 270):
		current_rotation_angle = 0
	else:
		current_rotation_angle += 90
	
	# Animate rotation
	if (current_rotation_angle == 0):
		sprite.flip_h = false
		sprite.flip_v = false
		if(pipe_type == PipeUtil.PipeType.CURVED):
			openingList = [PipeUtil.Direction.SOUTH, PipeUtil.Direction.EAST]
	elif (current_rotation_angle == 90):
		sprite.flip_h = true
		sprite.flip_v = false
		if(pipe_type == PipeUtil.PipeType.CURVED):
			openingList = [PipeUtil.Direction.EAST, PipeUtil.Direction.NORTH]
	elif (current_rotation_angle == 180):
		sprite.flip_h = false
		sprite.flip_v = true
		if(pipe_type == PipeUtil.PipeType.CURVED):
			openingList = [PipeUtil.Direction.NORTH, PipeUtil.Direction.WEST]
	elif (current_rotation_angle == 270):
		sprite.flip_h = true
		sprite.flip_v = true
		if(pipe_type == PipeUtil.PipeType.CURVED):
			openingList = [PipeUtil.Direction.WEST, PipeUtil.Direction.SOUTH]
	

func set_visual_rotation(angle: float) -> void:
	rotation_degrees = angle

# Set the pipe state with animation
func set_pipe_state(new_state: PipeUtil.PipeState) -> void:
	if state != new_state:
		var old_state = state
		state = new_state
		animate_state_transition(old_state, new_state)
		state_changed.emit(self, new_state)

func setImageBasedOnDirection() -> void:
	# Placeholder: Set the sprite texture based on start and end directions
	# In a real implementation, you would load different textures for different pipe types
	var texture_path: String
	if (pipe_type == PipeUtil.PipeType.STRAIGHT):
		texture_path = PipeUtil.STRAIGHT_PIPE
	elif (pipe_type == PipeUtil.PipeType.CURVED):
		texture_path = PipeUtil.CURVED_PIPE
	else:
		texture_path = "res://assets/top_to_bottom_dir.png" # Fallback
	var texture = load(texture_path)
	if texture:
		sprite.texture = texture
	else:
		# Fallback texture if specific one not found
		sprite.texture = load("res://assets/pipes/pipe_default.png")

func animate_state_transition(_from_state: PipeUtil.PipeState, to_state: PipeUtil.PipeState) -> void:
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Animate scale or modulate based on state
	match to_state:
		PipeUtil.PipeState.UTILIZED:
			tween.parallel().tween_property(self, "modulate", Color.GREEN, state_transition_duration)
			tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), state_transition_duration * 0.5)
			tween.tween_property(self, "scale", Vector2.ONE, state_transition_duration * 0.5)
		PipeUtil.PipeState.NOT_UTILIZED:
			tween.tween_property(self, "modulate", Color.WHITE, state_transition_duration)

func update_visual_state() -> void:
	# Update visual representation based on current state
	match state:
		PipeUtil.PipeState.UTILIZED:
			modulate = Color.GREEN
		PipeUtil.PipeState.NOT_UTILIZED:
			modulate = Color.WHITE

func get_reverse_direction(dir: PipeUtil.Direction) -> PipeUtil.Direction:
	match dir:
		PipeUtil.Direction.NORTH:
			return PipeUtil.Direction.SOUTH
		PipeUtil.Direction.SOUTH:
			return PipeUtil.Direction.NORTH
		PipeUtil.Direction.EAST:
			return PipeUtil.Direction.WEST
		PipeUtil.Direction.WEST:
			return PipeUtil.Direction.EAST
		_:
			return PipeUtil.Direction.NORTH

# Check if this pipe can connect to another pipe
func can_connect_to(other_pipe: Pipe2D, connection_dir: PipeUtil.Direction) -> bool:
	var my_output = self.end_direction
	var their_input = other_pipe.get_reverse_direction(connection_dir)
	
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Handle any per-frame updates if needed
	pass
