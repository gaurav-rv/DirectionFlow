extends Node2D

# Board configuration
const BOARD_SIZE = 3
const TILE_SIZE = 64
const TILE_SPACING = 8  # Gap between tiles

# Preload pipe scene
const PipeScene = preload("res://scenes/pipe_2d.tscn")
const PipeUtil = preload("res://scripts/pipe_util.gd")

# This will hold all the pipe nodes - using Node2D to avoid container layout interference
@onready var pipe_container = $PipeContainer 
 
# 2D array to store pipe references
var pipes: Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_board()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var spacing_offset = TILE_SIZE + TILE_SPACING
	var grid_position = Vector2(floor(mouse_pos.x / spacing_offset), floor(mouse_pos.y / spacing_offset))
	print("Mouse Grid Position: ", grid_position)
	pass

func generate_board() -> void:
	# Initialize the 2D array
	pipes.resize(BOARD_SIZE)
	for row in BOARD_SIZE:
		pipes[row] = []
		pipes[row].resize(BOARD_SIZE)
	
	# Create pipes for each grid position
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			create_pipe_at(x, y)

func create_pipe_at(x: int, y: int) -> void:
	var pipe: Pipe2D
	
	# Try to instantiate from scene, fallback to creating manually
	if PipeScene:
		pipe = PipeScene.instantiate() as Pipe2D
	else:
		pipe = preload("res://scripts/pipe_2d.gd").new() as Pipe2D
		# Add a sprite for visualization
		var sprite = Sprite2D.new()
		pipe.add_child(sprite)
		pipe.sprite = sprite
	
	# Set grid position
	pipe.x_pos = x
	pipe.y_pos = y
	
	# Set world position with spacing
	var spacing_offset = TILE_SIZE + TILE_SPACING
	pipe.position = Vector2(x * spacing_offset, y * spacing_offset)
	
	# Connect pipe signals first
	pipe.pipe_clicked.connect(_on_pipe_clicked)
	pipe.rotation_completed.connect(_on_pipe_rotation_completed)
	
	# Add to pipe container and store reference
	pipe_container.add_child(pipe)
	
	# Ensure position is set after adding to container (some containers reset position)
	pipe.position = Vector2(x * spacing_offset, y * spacing_offset)
	
	# Randomly choose pipe type
	var random_pipe_type = randi() % 2  # 0 = STRAIGHT, 1 = CURVED
	var pipe_type = PipeUtil.PipeType.STRAIGHT if random_pipe_type == 0 else PipeUtil.PipeType.CURVED
	
	# Setup the pipe with random type
	pipe.setup_pipe(pipe_type)
	
	# Random initial rotation (0, 90, 180, or 270 degrees)
	var rotations = [0.0, 90.0, 180.0, 270.0]
	pipe.orientation = rotations[randi() % rotations.size()]
	
	# Apply the rotation visually
	if pipe.sprite:
		pipe.sprite.rotation_degrees = pipe.orientation
	
	pipes[y][x] = pipe

# Signal handlers
func _on_pipe_clicked(pipe: Pipe2D) -> void:
	print("Pipe clicked at position (%d, %d)" % [pipe.x_pos, pipe.y_pos])

func _on_pipe_rotation_completed(pipe: Pipe2D) -> void:
	print("Pipe rotation completed at position (%d, %d)" % [pipe.x_pos, pipe.y_pos])
