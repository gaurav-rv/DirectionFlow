extends Node2D
class_name Pipe2D

# Enums for directions
enum Direction {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

# Enums for pipe states
enum PipeState {
	UTILIZED = 0,
	NOT_UTILIZED = 1
}

# Pipe attributes as specified in ReadMe
@export var start_direction: Direction = Direction.NORTH
@export var end_direction: Direction = Direction.SOUTH
@export var state: PipeState = PipeState.NOT_UTILIZED
@export var x_pos: int = 0 # Relative to grid
@export var y_pos: int = 0 # Relative to grid
@export var orientation: float = 0.0 # 0, 90, 180, 270 degrees

# Animation and visual properties
@export var tile_size: Vector2 = Vector2(64, 64)
@export var rotation_duration: float = 0.3
@export var state_transition_duration: float = 0.2

# Internal components
var sprite: Sprite2D
var tween: Tween

# Signals for game logic
signal pipe_clicked(pipe: Pipe2D)
signal rotation_completed(pipe: Pipe2D)
signal state_changed(pipe: Pipe2D, new_state: PipeState)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_pipe(Direction.NORTH, Direction.SOUTH)
	setup_input_handling()

func setup_pipe(start_direction: Direction, end_direction: Direction) -> void:
	# Create sprite component if not already present
	if not sprite:
		sprite = Sprite2D.new()
		add_child(sprite)
	
	self.start_direction = start_direction
	self.end_direction = end_direction
	setImageBasedOnDirection(start_direction, end_direction)

	# Set initial position based on grid coordinates
	position = Vector2(x_pos * tile_size.x, y_pos * tile_size.y)
	
	# Set initial rotation
	rotation_degrees = orientation
	
	# Update visual representation based on state
	update_visual_state()

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
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	var target_rotation = orientation + 90.0
	if target_rotation >= 360.0:
		target_rotation = 0.0
	
	tween.tween_method(set_visual_rotation, orientation, target_rotation, rotation_duration)
	await tween.finished
	
	orientation = target_rotation
	update_directions_after_rotation()
	rotation_completed.emit(self)

func set_visual_rotation(angle: float) -> void:
	rotation_degrees = angle

func update_directions_after_rotation() -> void:
	# Rotate directions clockwise by one step
	start_direction = ((start_direction + 1) % 4) as Direction
	end_direction = ((end_direction + 1) % 4) as Direction

# Set the pipe state with animation
func set_pipe_state(new_state: PipeState) -> void:
	if state != new_state:
		var old_state = state
		state = new_state
		animate_state_transition(old_state, new_state)
		state_changed.emit(self, new_state)

setImageBasedOnDirection(start_direction, end_direction) -> void:
	# Placeholder: Set the sprite texture based on start and end directions
	# In a real implementation, you would load different textures for different pipe types
	if(start_direction == Direction.NORTH and end_direction == Direction.SOUTH) :
		var texture_path = "res://assets/top_to_bottom_dir.png"
	elif(start_direction == Direction.NORTH and end_direction == Direction.EAST) :
		var texture_path = "res://assets/top_to_right_dir.png"
	elif(start_direction == Direction.NORTH and end_direction == Direction.WEST) :
		var texture_path = "res://assets/top_to_left_dir.png"
	elif(start_direction == Direction.EAST and end_direction == Direction.SOUTH) :
		var texture_path = "res://assets/right_to_bottom_dir.png"
	elif(start_direction == Direction.EAST and end_direction == Direction.WEST) :
		var texture_path = "res://assets/right_to_left_dir.png"
	elif(start_direction == Direction.EAST and end_direction == Direction.NORTH) :
		var texture_path = "res://assets/right_to_top_dir.png"
	elif(start_direction == Direction.SOUTH and end_direction == Direction.WEST) :
		var texture_path = "res://assets/bottom_to_left_dir.png"
	elif(start_direction == Direction.SOUTH and end_direction == Direction.EAST) :
		var texture_path = "res://assets/bottom_to_right_dir.png"
	elif(start_direction == Direction.SOUTH and end_direction == Direction.NORTH) :
		var texture_path = "res://assets/bottom_to_top_dir.png"
	elif(start_direction == Direction.WEST and end_direction == Direction.NORTH) :
		var texture_path = "res://assets/left_to_top_dir.png"
	elif(start_direction == Direction.WEST and end_direction == Direction.SOUTH) :
		var texture_path = "res://assets/left_to_bottom_dir.png"
	elif(start_direction == Direction.WEST and end_direction == Direction.EAST) :
		var texture_path = "res://assets/left_to_right_dir.png"
	else:
		var texture_path = "res://assets/top_to_bottom_dir.png" # Fallback
	var texture = load(texture_path)
	if texture:
		sprite.texture = texture
	else:
		# Fallback texture if specific one not found
		sprite.texture = load("res://assets/pipes/pipe_default.png")

func animate_state_transition(_from_state: PipeState, to_state: PipeState) -> void:
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Animate scale or modulate based on state
	match to_state:
		PipeState.UTILIZED:
			tween.parallel().tween_property(self, "modulate", Color.GREEN, state_transition_duration)
			tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), state_transition_duration * 0.5)
			tween.tween_property(self, "scale", Vector2.ONE, state_transition_duration * 0.5)
		PipeState.NOT_UTILIZED:
			tween.tween_property(self, "modulate", Color.WHITE, state_transition_duration)

func update_visual_state() -> void:
	# Update visual representation based on current state
	match state:
		PipeState.UTILIZED:
			modulate = Color.GREEN
		PipeState.NOT_UTILIZED:
			modulate = Color.WHITE

# Set grid position and update world position
func set_grid_position(x: int, y: int) -> void:
	x_pos = x
	y_pos = y
	position = Vector2(x_pos * tile_size.x, y_pos * tile_size.y)

# Get the direction this pipe connects to from a given input direction
func get_output_direction(input_dir: Direction) -> Direction:
	if input_dir == get_reverse_direction(start_direction):
		return end_direction
	elif input_dir == get_reverse_direction(end_direction):
		return start_direction
	else:
		return Direction.NORTH # Invalid connection

func get_reverse_direction(dir: Direction) -> Direction:
	match dir:
		Direction.NORTH:
			return Direction.SOUTH
		Direction.SOUTH:
			return Direction.NORTH
		Direction.EAST:
			return Direction.WEST
		Direction.WEST:
			return Direction.EAST
		_:
			return Direction.NORTH

# Check if this pipe can connect to another pipe
func can_connect_to(other_pipe: Pipe2D, connection_dir: Direction) -> bool:
	var my_output = self.end_direction
	var their_input = other_pipe.get_reverse_direction(connection_dir)
	
	return my_output == connection_dir and other_pipe.get_output_direction(their_input) == get_reverse_direction(connection_dir)

# Get string representation for debugging
func get_debug_string() -> String:
	return "Pipe[%d,%d] Start:%s End:%s Orient:%.0f State:%s" % [
		x_pos, y_pos,
		Direction.keys()[start_direction],
		Direction.keys()[end_direction],
		orientation,
		PipeState.keys()[state]
	]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Handle any per-frame updates if needed
	pass
